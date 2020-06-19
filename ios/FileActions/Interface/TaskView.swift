//
//  TaskView.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 18/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation
import SwiftUI

import FileActionsCore

struct EditText: View {

    var name: String
    @Binding var text: String
    @Environment(\.editMode) var editMode

    var body: some View {
        TextField(name, text: $text).disabled(editMode != nil ? editMode!.wrappedValue != .active : false)
    }

    init(_ name: String, text: Binding<String>) {
        self.name = name
        self._text = text
    }

}

struct TaskView: View {

    @State private var editMode = EditMode.inactive
    @ObservedObject var task: TaskState

    var body: some View {
        return VStack {
            List {
                Section {
                    EditText("Task", text: $task.name)
                }
                Section(header: Text("Variables".uppercased())) {
                    ForEach(task.variables) { variable in
                        NavigationLink(destination: VariableView(task: self.task, variable: variable)) {
                            HStack {
                                Text(variable.name)
                                Spacer()
                                Text(String(describing: variable.type)).foregroundColor(.accentColor)
                            }
                        }
                    }
                    .onDelete { self.task.variables.remove(atOffsets: $0) }
                    Button(action: {
                        self.task.variables.append(VariableState(name: "New Variable", type: .string))
                    }) {
                        Text("New variable...")
                    }
                }
                Section(header: Text("Destination".uppercased()), footer: DestinationView(variables: $task.variables, components: $task.destination)) {
                    ForEach(task.destination) { component in
                        ComponentItem(component: component)
                    }
                    .onMove { (fromOffsets, toOffset) in
                        self.task.destination.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                    .onDelete { self.task.destination.remove(atOffsets: $0) }
                    Text("File Extension").foregroundColor(.secondary)
                    Button(action: {
                        self.task.destination.append(ComponentState(value: "Component", type: .text))
                    }) {
                        Text("Add component...")
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .listStyle(GroupedListStyle())
        }
        .animation(Animation.spring())
        .navigationBarTitle(task.name)
        .navigationBarItems(trailing: Button(action: {
            // SwiftUI gets crashy if there's a first responder attached to a TextView when it's hidden.
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            self.editMode = self.editMode == .active ? .inactive : .active

        }) {
            if self.editMode == .active {
                Text("Save").bold()
            } else {
                Text("Edit")
            }
        })
    }

}
