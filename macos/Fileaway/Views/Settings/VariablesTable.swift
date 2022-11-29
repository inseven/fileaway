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

import SwiftUI

import FileawayCore

struct VariablesTable: View {

    @ObservedObject var ruleModel: RuleModel
    @State var selection: Set<VariableModel.ID> = []

    var body: some View {
        VStack {
            HStack {
                Table(ruleModel.variables, selection: $selection) {
                    TableColumn("") { variable in
                        Image(systemName: "circle.fill")
                            .imageScale(.large)
                            .foregroundColor(variable.color)
                    }
                    .width(20)
                    TableColumn("Name") { variableModel in
                        VariableNameTextField(variableModel: variableModel)
                    }
                    TableColumn("Type") { variableModel in
                        VariableTypePicker(variableModel: variableModel)
                    }
                }
                .onDeleteCommand {
                    ruleModel.remove(variableIds: selection)
                }

                VStack {
                    VStack {
                        Button {
                            _ = ruleModel.createVariable()
                        } label: {
                            Text("Add")
                                .frame(width: 80)
                        }
                        Button {
                            ruleModel.remove(variableIds: selection)
                        } label: {
                            Text("Remove")
                                .frame(width: 80)
                        }
                        .disabled(selection.isEmpty)
                        Spacer()
                    }
                }
            }

        }
    }

}
