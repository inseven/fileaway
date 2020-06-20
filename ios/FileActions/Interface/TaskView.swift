//
//  TaskView.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 18/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

import FileActionsCore

struct VariableRow : View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.editMode) var editMode
    @State var showSheet: Bool = false

    @ObservedObject var task: TaskState
    @ObservedObject var variable: VariableState

    var body: some View {
        HStack {
            Text(variable.name)
            Spacer()
            Text(String(describing: variable.type)).foregroundColor(editMode?.wrappedValue == .active ? .accentColor : .secondary)
        }
        .sheet(isPresented: $showSheet) {
            VariableView(task: self.task, variable: self.variable)
        }
        .onTapGesture {
            if self.editMode?.wrappedValue == .active {
                self.showSheet = true
            }
        }
    }

}

struct DestinationFooter: View {

    @Environment(\.editMode) var editMode
    @ObservedObject var task: TaskState

    var body: some View {
        VStack {
            if self.editMode?.wrappedValue == .active {
                HStack {
                    Button(action: {
                        self.task.destination.append(ComponentState(value: "Text", type: .text, variable: nil))
                    }) {
                        Text("Text")
                    }
                    .buttonStyle(FilledButton())
                    ForEach(task.variables) { variable in
                        Button(action: {
                            self.task.destination.append(ComponentState(value: variable.name, type: .variable, variable: variable))
                        }) {
                            Text(String(describing: variable.name))
                        }
                        .buttonStyle(FilledButton())
                    }
                }
                .padding()
            } else {
                DestinationView(task: task)
            }
        }
    }

}

class Container<T>: ObservableObject, BackChannelable where T: ObservableObject {

    @ObservedObject var object: T;
    var observer: Cancellable?

    init(_ object: T) {
        self.object = object
    }

    func establishBackChannel() {
        if let backChannelable = object as? BackChannelable {
            backChannelable.establishBackChannel()
        }
        observer = object.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }

    deinit {
        observer?.cancel()
    }

}

struct TaskView: View {

    @State private var editMode = EditMode.inactive
    @ObservedObject var tasks: TaskList
    @ObservedObject var editingTask: TaskState
    var originalTask: TaskState

    func edit() {
        self.editingTask.establishBackChannel()
        self.editMode = .active
    }

    func save() {
        // SwiftUI gets crashy if there's a first responder attached to a TextView when it's hidden.
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        tasks.replace(task: originalTask, with: editingTask)
        self.editMode = .inactive
    }

    func validate() -> Bool {
        return tasks.validate(task: editingTask) && !editingTask.name.isEmpty
    }

    var body: some View {
        return VStack {
            List {
                Section(footer: ErrorText(text: validate() ? nil : "Task names must be unique.")) {
                    EditText("Task", text: $editingTask.name)
                }
                Section(header: Text("Variables".uppercased()), footer: ErrorText(text: editingTask.validate() ? nil : "Variable names must be unique.")) {
                    ForEach(editingTask.variables) { variable in
                        VariableRow(task: self.editingTask, variable: variable)
                    }
                    .onDelete { self.editingTask.remove(variableOffsets: $0) }
                    if self.editMode == .active {
                        EditSafeButton(action: {
                            self.editingTask.createVariable()
                        }) {
                            Text("New variable...")
                        }
                    }
                }
                Section(header: Text("Destination".uppercased()), footer: DestinationFooter(task: editingTask)) {
                    ForEach(editingTask.destination) { component in
                        ComponentItem(task: self.editingTask, component: component)
                    }
                    .onMove { (fromOffsets, toOffset) in
                        self.editingTask.destination.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                    .onDelete { self.editingTask.destination.remove(atOffsets: $0) }
                }
            }
            .environment(\.editMode, $editMode)
            .listStyle(GroupedListStyle())
        }
        .animation(Animation.spring())
        .navigationBarTitle(editingTask.name)
        .navigationBarBackButtonHidden(editMode == .active)
        .navigationBarItems(trailing: Button(action: {
            if (self.editMode == .active) {
                self.save()
            } else {
                self.edit()
            }
        }) {
            if self.editMode == .active {
                Text("Save").bold().disabled(!validate() || !editingTask.validate())
            } else {
                Text("Edit")
            }
        })
    }

}
