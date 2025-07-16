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

import MobileCoreServices
import SwiftUI

import FileawayCore

struct PhoneVariableView: View {

    @Environment(\.dismiss) private var dismiss

    @ObservedObject var ruleModel: RuleModel
    @ObservedObject var variable: VariableModel

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Name", text: $variable.name)
                    } footer: {
                        ErrorText(text: ruleModel.validate() ? nil : "Variable names must be unique.")
                    }
                    Section("Type") {
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
            .toolbar {

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .bold()
                            .disabled(!ruleModel.validate())
                    }
                }

            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

}
