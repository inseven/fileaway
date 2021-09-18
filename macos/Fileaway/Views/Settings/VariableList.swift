// Copyright (c) 2018-2021 InSeven Limited
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

struct VariableList: View {

    @ObservedObject var rule: RuleState
    @State var selection: VariableState?

    var body: some View {
        VStack {
            HStack {
                List(rule.variables, id: \.self, selection: $selection) { variable in
                    Text("\(variable.name) (\(String(describing: variable.type)))")
                }
                VStack {
                    if let selection = selection {
                        VariableTextField(variable: selection)
                            .id(selection)
                    } else {
                        Text("No Variable Selected")
                    }
                }
                .frame(width: 200)
            }
            HStack {

                ControlGroup {
                    Button {
                        rule.createVariable()
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        guard let variable = selection else {
                            return
                        }
                        rule.remove(variable: variable)
                        selection = nil
                    } label: {
                        Image(systemName: "minus")
                    }
                    .disabled(selection == nil)
                }

                ControlGroup {
                    Button {
                        guard let variable = selection else {
                            return
                        }
                        rule.moveUp(variable: variable)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    Button {
                        guard let variable = selection else {
                            return
                        }
                        rule.moveDown(variable: variable)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                
                Spacer()
                    .layoutPriority(1)

            }

        }
    }

}
