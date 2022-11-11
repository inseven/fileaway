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

import Combine
import Foundation
import SwiftUI

import FileawayCore

struct TaskView: View {

    @State private var editMode = EditMode.inactive
    @ObservedObject var tasks: TasksModel
    @ObservedObject var editingTask: TaskModel
    var originalTask: TaskModel

    func edit() {
        self.editingTask.establishBackChannel()
        self.editMode = .active
    }

    func save() {
        // SwiftUI gets crashy if there's a first responder attached to a TextView when it's hidden.
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        tasks.update(task: editingTask)
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
                Section(header: Text("Variables".uppercased()),
                        footer: ErrorText(text: editingTask.validate() ? nil : "Variable names must be unique.")) {
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
