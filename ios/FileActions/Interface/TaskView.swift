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

struct DestinationView: View {

    @Binding var variables: [VariableState]
    @Binding var components: [ComponentState]

    func description(for component: ComponentState) -> String {
        switch component.type {
        case .text:
            return component.value
        case .variable:
            guard let variable = (variables.first { $0.name == component.value }) else {
                return "Missing Variable"
            }
            switch variable.type {
            case .date(hasDay: true):
                return "YYYY-mm-dd"
            case .date(hasDay: false):
                return "YYYY-mm"
            case .string:
                return variable.name
            }
        }
    }

    var body: some View {
        HStack {
            components.map {
                Text(self.description(for: $0))
                    .foregroundColor($0.type == .variable ? .blue : .primary)
                    .fontWeight($0.type == .variable ? .bold : .none)
            }
            .reduce( Text(""), + )
        }
    }

}

struct TaskView: View {

    @State private var isEditing = EditMode.inactive
    @ObservedObject var task: TaskState

    var body: some View {
        return VStack {
            List {
                Section(header: Text("Name".uppercased())) {
                    TextField("Task", text: $task.name)
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
            .listStyle(GroupedListStyle())
        }
        .animation(Animation.spring())
        .navigationBarTitle(task.name)
        .navigationBarItems(trailing: Button(action: {
            self.isEditing = self.isEditing == .active ? .inactive : .active
        }) {
            if self.isEditing == .active {
                Text("Save")
            } else {
                Text("Edit")
            }
        })
    }

}
