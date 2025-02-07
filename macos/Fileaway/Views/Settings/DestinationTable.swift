// Copyright (c) 2018-2025 Jason Morley
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
import UniformTypeIdentifiers

import FileawayCore

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
                Table(of: ComponentModel.self, selection: $selection) {
                    TableColumn("Component") { componentModel in
                        if componentModel.type == .text {
                            ComponentValueTextField(componentModel: componentModel)
                        } else {
                            Text(ruleModel.name(for: componentModel))
                                .tokenAppearance()
                                .accentColor(componentModel.variable!.color)
                        }
                    }
                } rows: {
                    ForEach(ruleModel.filename) { componentModel in
                        TableRow(componentModel)
                            .itemProvider(componentModel.id, as: .component)
                    }
                    .onInsert(ComponentModel.ID.self, as: .component) { index, ids in
                        self.ruleModel.filename.move(ids: ids, toOffset: index)
                    }
                }
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

            VariablePicker(ruleModel: ruleModel)
                .padding(.top)

        }
    }

}
