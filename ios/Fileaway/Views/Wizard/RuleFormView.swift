// Copyright (c) 2018-2023 InSeven Limited
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

struct RuleFormView: View {

    @EnvironmentObject var wizardModel: WizardModel

    @ObservedObject var ruleModel: RuleModel

    @StateObject var ruleFormModel: RuleFormModel
    @State private var isHeaderVisible: Bool = true

    var url: URL

    init(applicationModel: ApplicationModel, url: URL, ruleModel: RuleModel) {
        self.url = url
        self.ruleModel = ruleModel
        _ruleFormModel = StateObject(wrappedValue: RuleFormModel(applicationModel: applicationModel,
                                                                 ruleModel: ruleModel,
                                                                 url: url))
    }

    var body: some View {
        Form {
            DocumentPreviewHeader($isHeaderVisible, url: url)
            RuleFormSection(ruleFormModel, url: url)
        }
        .navigationTitle(ruleFormModel.name)
        .conditionalTitle(!isHeaderVisible) {
            DocumentPreviewButton(url: url, size: .navigationBarIcon)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Move") {
                    do {
                        try ruleFormModel.move()
                        wizardModel.complete()
                    } catch {
                        // TODO: Present this error to the user.
                        print("Failed to move file with error \(error).")
                    }
                }
            }
        }
    }

}
