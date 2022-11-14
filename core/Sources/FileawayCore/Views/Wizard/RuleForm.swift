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

public struct RuleForm: View {

    @ObservedObject private var ruleFormModel: RuleFormModel
    private let url: URL
    @StateObject private var dateExtractor: DateExtractor

    public init(_ ruleFormModel: RuleFormModel, url: URL) {
        self.ruleFormModel = ruleFormModel
        self.url = url
        _dateExtractor = StateObject(wrappedValue: DateExtractor(url: url))
    }

    public var body: some View {
        Form {
            Section {
                ForEach(ruleFormModel.variableFieldModels) { variable in
                    if let variable = variable as? DateFieldModel {
                        DateField(variable: variable,
                                  creationDate: FileInfo.creationDate(url: url)?.date,
                                  options: dateExtractor.dates)
                    } else if let variable = variable as? StringFieldModel {
                        StringField(variable: variable)
                    } else {
                        Text("Unknown Variable Type")
                    }
                }
            } footer: {
                Text(ruleFormModel.destinationURL.path)
                    .horizontalSpace(.trailing)
                    .textSelection(.enabled)
            }
        }
        .formStyle(.grouped)
        .runs(ruleFormModel)
        .runs(dateExtractor)
    }

}