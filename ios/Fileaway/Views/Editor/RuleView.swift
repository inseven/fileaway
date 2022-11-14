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

struct RuleView: View {

    @State private var editMode = EditMode.inactive
    @ObservedObject var tasks: TasksModel
    @ObservedObject var editingRuleModel: RuleModel
    var originalRuleModel: RuleModel

    func edit() {
        self.editingRuleModel.establishBackChannel()
        self.editMode = .active
    }

    func save() {
        // SwiftUI gets crashy if there's a first responder attached to a TextView when it's hidden.
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        tasks.update(task: editingRuleModel)
        self.editMode = .inactive
    }

    func validate() -> Bool {
        return tasks.validate(taskModel: editingRuleModel) && !editingRuleModel.name.isEmpty
    }

    var body: some View {
        return VStack {
            Form {
                Section(footer: ErrorText(text: validate() ? nil : "Rule names must be unique.")) {
                    EditText("Rule", text: $editingRuleModel.name)
                }
                Section(header: Text("Variables".uppercased()),
                        footer: ErrorText(text: editingRuleModel.validate() ? nil : "Variable names must be unique.")) {
                    ForEach(editingRuleModel.variables) { variable in
                        VariableRow(ruleModel: self.editingRuleModel, variable: variable)
                    }
                    .onDelete { self.editingRuleModel.remove(variableOffsets: $0) }
                    if self.editMode == .active {
                        EditSafeButton(action: {
                            self.editingRuleModel.createVariable()
                        }) {
                            Text("New variable...")
                        }
                    }
                }
                Section(header: Text("Destination".uppercased()), footer: DestinationFooter(ruleModel: editingRuleModel)) {
                    ForEach(editingRuleModel.destination) { component in
                        ComponentItem(ruleModel: self.editingRuleModel, component: component)
                    }
                    .onMove { (fromOffsets, toOffset) in
                        self.editingRuleModel.destination.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                    .onDelete { self.editingRuleModel.destination.remove(atOffsets: $0) }
                }
            }
            .environment(\.editMode, $editMode)
        }
        .navigationBarTitle(editingRuleModel.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editMode == .active)
        .navigationBarItems(trailing: Button(action: {
            if (self.editMode == .active) {
                self.save()
            } else {
                self.edit()
            }
        }) {
            if self.editMode == .active {
                Text("Save")
                    .bold()
                    .disabled(!validate() || !editingRuleModel.validate())
            } else {
                Text("Edit")
            }
        })
    }

}
