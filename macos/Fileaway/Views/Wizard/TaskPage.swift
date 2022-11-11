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
import SwiftUI

import FileawayCore
import Interact

struct TaskPage: View {

    enum FocusableField: Hashable {
        case search
    }

    var manager: ApplicationModel
    var url: URL

    @StateObject var model: TaskPageModel

    @State var activeRuleModel: RuleModel? = nil

    @FocusState private var focus: FocusableField?

    init(manager: ApplicationModel, url: URL) {
        self.manager = manager
        self.url = url
        _model = StateObject(wrappedValue: TaskPageModel(manager: manager))
    }

    func binding(for ruleModel: RuleModel) -> Binding<Bool> {
        Binding {
            self.activeRuleModel == ruleModel
        } set: { value in
            if value {
                self.activeRuleModel = ruleModel
            } else if self.activeRuleModel == ruleModel {
                self.activeRuleModel = nil
            }
        }
    }

    @MainActor func submit() {
        activeRuleModel = model.filteredRules.first(where: { $0.id == model.selection })
    }

    var body: some View {
        VStack(spacing: 0) {
            if let activeRule = activeRuleModel {
                DetailsPage(url: url, ruleModel: activeRule)
            } else {
                List(selection: $model.selection) {
                    ForEach(model.filteredRules) { rule in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(rule.name)
                                Text(rule.rootUrl.displayName)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        .padding()
                    }
                }
                .safeAreaInset(edge: .top) {
                    TextField("Search", text: $model.filter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focus, equals: .search)
                        .onSubmit {
                            submit()
                        }
                        .padding(.bottom)
                        .background(.regularMaterial)
                }
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Spacer()
                        Button("Next") {
                            submit()
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                    .padding(.top)
                    .background(.regularMaterial)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focus = .search
                    }
                }
            }
            HStack {
                Button("Back") {
                    activeRuleModel = nil
                }
                .disabled(activeRuleModel == nil)
            }
        }
        .runs(model)
    }

}
