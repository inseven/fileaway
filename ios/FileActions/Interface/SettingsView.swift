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

struct Selectable<Content: View>: View {

    let isSelected: Bool
    let action: () -> Void
    let content: () -> Content

    var body: some View {
        HStack {
            Button(action: action) {
                content()
            }
            .foregroundColor(.primary)
            if isSelected {
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
    }

    @inlinable public init(isSelected: Bool, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.isSelected = isSelected
        self.action = action
        self.content = content
    }

}

extension VariableType: Identifiable {

    public var id: String {
        String(describing: self)
    }
}

struct VariableView: View {

    @ObservedObject var task: TaskState
    @ObservedObject var variable: VariableState

    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Name", text: $variable.name)
                }
                Section(header: Text("Type".uppercased())) {
                    ForEach(VariableType.allCases) { type in
                        Selectable(isSelected: self.variable.type.id == type.id, action: {
//                            self.task.objectWillChange.send()
                            self.variable.type = type
                        }) {
                            Text(String(describing: type))
                        }
                    }
                }
            }
        }
        .navigationBarTitle(variable.name)
    }

}

struct ComponentItem: View {


    @Environment(\.editMode) var editMode
    @State var component: ComponentState

    var body: some View {
        HStack {
            if component.type == .text {
                EditText("Component", text: $component.value).environment(\.editMode, editMode)
            } else {
                Text(component.value)
                .foregroundColor(.secondary)
            }
        }
        .environment(\.editMode, editMode)
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
        .navigationBarItems(trailing: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Done").bold()
        })
    }

}
