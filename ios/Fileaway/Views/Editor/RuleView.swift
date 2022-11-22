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
    @ObservedObject var rulesModel: RulesModel
    @ObservedObject var editingRuleModel: RuleModel
    var originalRuleModel: RuleModel

    func edit() {
        self.editingRuleModel.establishBackChannel()
        self.editMode = .active
    }

    func save() {
        // SwiftUI gets crashy if there's a first responder attached to a TextView when it's hidden.
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        rulesModel.replace(ruleModel: editingRuleModel)
        self.editMode = .inactive
    }

    func cancel() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        editingRuleModel.reset(to: originalRuleModel)
        self.editMode = .inactive
    }

    var body: some View {
        return VStack {
            Form {

                Section {
                    EditText("Rule", text: $editingRuleModel.name)
                }

                Section {
                    ForEach(editingRuleModel.variables) { variable in
                        VariableRow(ruleModel: self.editingRuleModel, variable: variable)
                    }
                    .onDelete { self.editingRuleModel.remove(variableOffsets: $0) }
                    if self.editMode == .active {
                        Button {
                            withAnimation {
                                self.editingRuleModel.createVariable()
                            }
                        } label: {
                            Text("New Variable...")
                        }
                    }
                } header: {
                    Text("Variables")
                } footer: {
                    ErrorText(text: editingRuleModel.validate() ? nil : "Variable names must be unique.")
                }

                Section("Destination") {
                    ComponentItem(ruleModel: self.editingRuleModel, component: self.editingRuleModel.folder)
                }

                Section {
                    ForEach(editingRuleModel.filename) { component in
                        ComponentItem(ruleModel: self.editingRuleModel, component: component)
                    }
                    .onMove { (fromOffsets, toOffset) in
                        self.editingRuleModel.filename.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                    .onDelete { self.editingRuleModel.filename.remove(atOffsets: $0) }
                } header: {
                    Text("Filename")
                } footer: {
                    DestinationFooter(ruleModel: editingRuleModel)
                }

            }
            .environment(\.editMode, $editMode)
        }
        .navigationBarTitle(editingRuleModel.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editMode == .active)
        .interactiveDismissDisabled(editMode == .active)
        .toolbar {

            if editMode == .active {

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            self.cancel()
                        }
                    } label: {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            self.save()
                        }
                    } label: {
                        Text("Save")
                            .bold()
                            .disabled(!editingRuleModel.validate())
                    }
                }

            } else {

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            self.edit()
                        }
                    } label: {
                        Text("Edit")
                    }
                }

            }

        }

    }

}
