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

import Combine
import SwiftUI

import FileawayCore
import Interact

struct RulePicker: View {

    enum FocusableField: Hashable {
        case search
    }

    private let url: URL

    @StateObject var rulePickerModel: RulePickerModel

    @Binding var activeRuleModel: RuleModel?

    @FocusState private var focus: FocusableField?

    init(applicationModel: ApplicationModel, activeRuleModel: Binding<RuleModel?>, url: URL) {
        _activeRuleModel = activeRuleModel
        self.url = url
        _rulePickerModel = StateObject(wrappedValue: RulePickerModel(applicationModel: applicationModel))
    }

    @MainActor func submit() {
        activeRuleModel = rulePickerModel.filteredRules.first { $0.id == rulePickerModel.selection }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search", text: $rulePickerModel.filter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focus, equals: .search)
                .onSubmit {
                    withAnimation {
                        submit()
                    }
                }
                .padding([.bottom, .leading, .trailing])

            List(selection: $rulePickerModel.selection) {
                Section() {

                }
                if !rulePickerModel.recentRules.isEmpty {
                    Section("Recent") {
                        ForEach(rulePickerModel.recentRules) { ruleModel in
                            RulePickerRow(ruleModel: ruleModel) {
                                withAnimation {
                                    rulePickerModel.selection = ruleModel.id
                                    activeRuleModel = ruleModel
                                }
                            }
                        }
                    }
                }
                Section("All Rules") {
                    ForEach(rulePickerModel.filteredRules) { ruleModel in
                        RulePickerRow(ruleModel: ruleModel) {
                            withAnimation {
                                rulePickerModel.selection = ruleModel.id
                                activeRuleModel = ruleModel
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .onKeyPress(.downArrow) {
            rulePickerModel.selectNext()
            return .handled
        }
        .onKeyPress(.upArrow) {
            rulePickerModel.selectPrevious()
            return .handled
        }
        .onKeyPress(.return) {
            withAnimation {
                submit()
            }
            return .handled
        }
        .showsStackNavigationBar("Select Rule")
        .defaultFocus($focus, .search)
        .runs(rulePickerModel)
    }

}
