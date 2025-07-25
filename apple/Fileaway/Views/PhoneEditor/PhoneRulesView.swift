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

#if os(iOS)

import Foundation
import SwiftUI

import FileawayCore

public struct PhoneRulesView: View {

    @ObservedObject var rulesModel: RulesModel

    public init(rulesModel: RulesModel) {
        self.rulesModel = rulesModel
    }

    public var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        ForEach(rulesModel.ruleModels) { ruleModel in
                            NavigationLink(destination: PhoneRuleView(rulesModel: self.rulesModel,
                                                                      editingRuleModel: RuleModel(ruleModel),
                                                                      originalRuleModel: ruleModel)) {
                                Text(ruleModel.name)
                            }
                        }
                        .onDelete {
                            self.rulesModel.ruleModels.remove(atOffsets: $0)
                        }
                    }
                }
            }
            .toolbar {

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        _ = try! self.rulesModel.new()
                    } label: {
                        Image(systemName: "plus")
                    }
                }

            }
            .navigationBarTitle("Rules")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

}

#endif
