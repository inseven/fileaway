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

struct RulePicker: View {

    @Environment(\.dismiss) var dismiss

    @StateObject var rulePickerModel: RulePickerModel

    private let url: URL

    init(applicationModel: ApplicationModel, url: URL) {
        self.url = url
        _rulePickerModel = StateObject(wrappedValue: RulePickerModel(applicationModel: applicationModel))
    }

    var body: some View {
        List {
            ForEach(rulePickerModel.filteredRules) { rule in
                NavigationLink {
                    RuleFormView(url: url, ruleModel: rule)
                } label: {
                    Text(rule.name)
                }
            }
        }
        .searchable(text: $rulePickerModel.filter)
        .navigationTitle("Select Rule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            FilePreviewHeader(url: url)

            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .runs(rulePickerModel)
    }

}
