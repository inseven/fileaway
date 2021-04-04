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
                return "Date (YYYY-mm-dd)"
            } else {
                return "Date (YYYY-mm)"
            }
        case .string:
            return "String"
        }
    }

}

extension VariableType: Identifiable {

    public var id: String {
        String(describing: self)
    }
}

struct VariableView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var task: TaskState
    @ObservedObject var variable: VariableState

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(footer: ErrorText(text: task.validate() ? nil : "Variable names must be unique.")) {
                        TextField("Name", text: $variable.name)
                    }
                    Section(header: Text("Type".uppercased())) {
                        ForEach(VariableType.allCases) { type in
                            Selectable(isSelected: self.variable.type.id == type.id, action: {
                                self.variable.type = type
                            }) {
                                Text(String(describing: type))
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Edit Variable", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold().disabled(!task.validate())
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

}

struct ComponentItem: View {


    @Environment(\.editMode) var editMode
    @ObservedObject var task: TaskState
    @State var component: ComponentState

    var body: some View {
        HStack {
            if component.type == .text {
                EditText("Component", text: $component.value).environment(\.editMode, editMode)
            } else {
                Text(task.name(for: component))
                .foregroundColor(.secondary)
            }
        }
        .environment(\.editMode, editMode)
    }

}

struct SettingsView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var settings: Settings

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Destination".uppercased()), footer: Destination(url: $settings.destination)) {
                    FilePicker(placeholder: "Select...", documentTypes: [kUTTypeFolder as String], url: $settings.destination).lineLimit(1)
                }
                Section() {
                    NavigationLink(destination: TasksView(tasks: settings.tasks)) {
                        Text("Tasks")
                        Spacer()
                        Text("\(settings.tasks.count)").foregroundColor(.secondary)
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Done").bold()
        })
    }

}
