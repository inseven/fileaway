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
import UniformTypeIdentifiers

struct DestinationTable: View {

    @ObservedObject var ruleModel: RuleModel
    @State var selection: ComponentModel.ID?

    var selectedComponentModel: ComponentModel? {
        return ruleModel.destination
            .first{ $0.id == selection }
    }

    var body: some View {
        VStack {

            HStack {

                Table(selection: $selection) {
                    TableColumn("Component") { componentModel in
                        if componentModel.type == .text {
                            HStack {
                                ComponentValueTextField(componentModel: componentModel)
                                SetFolderButton(ruleModel: ruleModel, componentModel: componentModel)
                            }
                        } else {
                            Text(ruleModel.name(for: componentModel))
                                .foregroundColor(.secondary)
                        }
                    }
                } rows: {
                    ForEach(ruleModel.destination) { componentModel in
                        TableRow(componentModel)
                            .itemProvider(componentModel.id, as: .component)
                    }
                    .onInsert(ComponentModel.ID.self, as: .component) { index, ids in
                        self.ruleModel.destination.move(ids: ids, toOffset: index)
                    }
                }
                .frame(minWidth: 500, minHeight: 200)

                VStack {
                    VStack {
                        Button {
                            guard let componentModel = selectedComponentModel else {
                                return
                            }
                            ruleModel.remove(componentModel: componentModel)
                            selection = nil
                        } label: {
                            Text("Remove")
                                .frame(width: 80)
                        }
                        .disabled(selection == nil)
                        Spacer()
                    }
                }

            }

            DestinationPreview(ruleModel: ruleModel)
            VariablePicker(ruleModel: ruleModel)

        }
    }

}