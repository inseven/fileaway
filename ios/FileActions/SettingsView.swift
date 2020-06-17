//
//  SettingsView.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 15/05/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import MobileCoreServices
import SwiftUI

import FileActionsCore

extension VariableType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .date(let hasDay):
            if hasDay {
                return "YYYY-mm-dd"
            } else {
                return "YYYY-mm"
            }
        case .string:
            return "String"
        }
    }

}

struct VariableView: View {

    @State var variable: Variable

    var body: some View {
        VStack {
            Text(variable.name)
        }
        .navigationBarTitle(variable.name)
    }

}

class TaskState: ObservableObject {

    @State var name: String
    @Published var variables: [Variable]
    @Published var destination: [Component]

    init(task: Task) {
        name = task.name
        variables = task.configuration.variables
        destination = task.configuration.destination
    }

}

struct ComponentItem: View {

    enum ActionType {
        case up
        case down
    }

    @State var component: Component
    @State var value: String

    var body: some View {
        HStack {
            if component.type == .text {
                TextField("Name", text: $value)
            } else {
                Text(component.value)
                .foregroundColor(.secondary)
            }
        }
    }

}

struct TaskView: View {

    @ObservedObject var task: TaskState

    func addVariable() {
        let variable = Variable(name: "Cheese", type: .string)
        task.variables.append(variable)
        print(task.variables)
        print($task.variables)
    }

    var body: some View {
        VStack {
            List {
                Section(header: Text("Name")) {
                    TextField("Name", text: task.$name)
                }
                Section(header: Text("Variables")) {
                    ForEach(task.variables, id: \.name) { variable in
                        NavigationLink(destination: VariableView(variable: variable)) {
                            HStack {
                                Text(variable.name)
                                Spacer()
                                Text(String(describing: variable.type)).foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete { self.task.variables.remove(atOffsets: $0) }
                    Button(action: {
                        print("Add variable...")
                        self.addVariable()
                    }) {
                        Text("New variable...")
                    }
                }
                Section(header: Text("Destination")) {
                    ForEach(task.destination, id: \.value) { component in
                        ComponentItem(component: component, value: component.value)
                    }
                    .onMove { (fromOffsets, toOffset) in
                        self.task.destination.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                    .onDelete { self.task.destination.remove(atOffsets: $0) }
                    Text("File Extension").foregroundColor(.secondary)
                    Button(action: {
                    }) {
                        Text("Add component...")
                    }
                }
            }
        }.navigationBarTitle(task.name)
    }

}

struct TasksView: View {

    @State var tasks: [TaskState]

    var body: some View {
        VStack {
            List {
                Section() {
                    ForEach(tasks, id: \.name) { task in
                        NavigationLink(destination: TaskView(task: task)) {
                            Text(task.name)
                        }
                    }
                    .onDelete { self.tasks.remove(atOffsets: $0) }
                }
            }
        }.navigationBarItems(trailing: Button(action: {
            print("Add")
        }) {
            Text("Add")
        })
        .navigationBarTitle("Tasks")
    }

}

struct SettingsView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var settings: Settings
    @State var tasks: [TaskState]

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Destination".uppercased()), footer: Destination(url: $settings.destination)) {
                    FilePicker(placeholder: "Select...", documentTypes: [kUTTypeFolder as String], url: $settings.destination).lineLimit(1)
                }
                Section() {
                    NavigationLink(destination: TasksView(tasks: tasks)) {
                        Text("Tasks")
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        }))
    }

}
