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
    @ObservedObject var taskContainer: Container<TaskState>
    var originalTask: TaskState

    init(tasks: TaskList, task: TaskState) {
        self.tasks = tasks
        self.taskContainer = Container(TaskState(task))
        let taskContainer = Container(TaskState(task))
        taskContainer.object.establishBackChannel()
        self.taskContainer = taskContainer
        self.originalTask = task
    }

    func edit() {
        self.taskContainer.object = TaskState(originalTask)
        self.taskContainer.establishBackChannel()
        self.editMode = .active
    }

    func save() {
        // SwiftUI gets crashy if there's a first responder attached to a TextView when it's hidden.
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        tasks.replace(task: originalTask, with: taskContainer.object)
        self.editMode = .inactive
    }

    func validate() -> Bool {
        return tasks.validate(task: taskContainer.object) && !taskContainer.object.name.isEmpty
    }

    var body: some View {
        return VStack {
            List {
                Section(footer: ErrorText(text: validate() ? nil : "Task names must be unique.")) {
                    EditText("Task", text: $taskContainer.object.name)
                }
                Section(header: Text("Variables".uppercased()), footer: ErrorText(text: taskContainer.object.validate() ? nil : "Variable names must be unique.")) {
                    ForEach(taskContainer.object.variables) { variable in
                        VariableRow(task: self.taskContainer.object, variable: variable)
                    }
                    .onDelete { self.taskContainer.object.remove(variableOffsets: $0) }
                    if self.editMode == .active {
                        EditSafeButton(action: {
                            self.taskContainer.object.createVariable()
                        }) {
                            Text("New variable...")
                        }
                    }
                }
                Section(header: Text("Destination".uppercased()), footer: DestinationFooter(task: taskContainer.object)) {
                    ForEach(taskContainer.object.destination) { component in
                        ComponentItem(task: self.taskContainer.object, component: component)
                    }
                    .onMove { (fromOffsets, toOffset) in
                        self.taskContainer.object.destination.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                    .onDelete { self.taskContainer.object.destination.remove(atOffsets: $0) }
                }
            }
            .environment(\.editMode, $editMode)
            .listStyle(GroupedListStyle())
        }
        .animation(Animation.spring())
        .navigationBarTitle(taskContainer.object.name)
        .navigationBarBackButtonHidden(editMode == .active)
        .navigationBarItems(trailing: Button(action: {
            if (self.editMode == .active) {
                self.save()
            } else {
                self.edit()
            }
        }) {
            if self.editMode == .active {
                Text("Save").bold().disabled(!validate() || !taskContainer.object.validate())
            } else {
                Text("Edit")
            }
        })
    }

}
