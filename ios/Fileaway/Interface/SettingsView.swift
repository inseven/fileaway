// Copyright (c) 2018-2022 InSeven Limited
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import MobileCoreServices
import SwiftUI

import FileawayCore

struct VariableView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var task: TaskState
    @ObservedObject var variable: VariableModel

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

struct SettingsView: View {

    enum SheetType: Identifiable {

        var id: Self { self }

        case about
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var settings: Settings

    @State private var sheet: SheetType? = nil

    var body: some View {
        VStack {
            Form {
                Section("Destination") {
                    FilePicker(placeholder: "Select...", documentTypes: [.folder], url: $settings.destination)
                        .lineLimit(1)
                }
                Section {
                    NavigationLink(destination: TasksView(tasks: settings.tasks)) {
                        Text("Tasks")
                        Spacer()
                        Text("\(settings.tasks.count)").foregroundColor(.secondary)
                    }
                }
                Section {
                    Button("About Fileaway...") {
                        sheet = .about
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Done").bold()
        })
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .about:
                AboutView()
            }
        }
    }

}

