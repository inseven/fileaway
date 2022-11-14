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

class RulesWizardModel: ObservableObject {

    @Published var activeRuleModel: RuleModel? = nil

    func pop() {
        activeRuleModel = nil
    }

}

struct WizardView: View {

    @Environment(\.applicationModel) var manager

    @StateObject var rulesWizardModel = RulesWizardModel()

    @State var url: URL
    @State var firstResponder: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            QuickLookPreview(url: url)
                .onTapGesture(count: 2) {
                    NSWorkspace.shared.open(url)
                }
                .background(.thinMaterial)
                .cornerRadius(6.0)
                .padding([.leading, .top, .bottom])
            HStack {
                VStack {
                    if let activeRule = rulesWizardModel.activeRuleModel {
                        RuleFormPage(url: url, ruleModel: activeRule)
                            .transition(.move(edge: .trailing))
                    } else {
                        RulesPage(manager: manager, activeRuleModel: $rulesWizardModel.activeRuleModel, url: url)
                            .transition(.move(edge: .leading))
                    }
                }
                .clipped()
            }
            .frame(width: 340)
        }
        .navigationTitle(url.displayName)
        .frame(minWidth: 800, minHeight: 600, idealHeight: 600)
        .environmentObject(rulesWizardModel)
    }

}
