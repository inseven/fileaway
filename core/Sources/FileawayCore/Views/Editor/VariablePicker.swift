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

public struct VariablePicker: View {

    @ObservedObject private var ruleModel: RuleModel

    public init(ruleModel: RuleModel) {
        self.ruleModel = ruleModel
    }

    public var body: some View {
        HStack {

            Button {
                withAnimation {
                    self.ruleModel.destination.append(ComponentModel(value: "Text", type: .text, variable: nil))
                }
            } label: {
                Text("Text")
            }
            .buttonStyle(.filled)
            .tint(.primary)

            ForEach(ruleModel.variables) { variable in
                Button {
                    withAnimation {
                        self.ruleModel.destination.append(ComponentModel(value: variable.name,
                                                                         type: .variable,
                                                                         variable: variable))
                    }
                } label: {
                    Text(String(describing: variable.name))
                }
                .buttonStyle(.filled)
                .tint(variable.color)
            }

            Spacer()
            
        }

    }
}
