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

import Interact

struct RulesEditor: View {

    enum SheetType {
        case rule(rule: RuleState)
    }

    enum AlertType {
        case duplicationFailure(error: Error)
    }

    @ObservedObject var rules: RuleSet
    @State var selection: RuleState?
    @State var sheet: SheetType?
    @State var alert: AlertType?

    var body: some View {
        HStack {
            VStack {
                ScrollViewReader { scrollView in
                    List(rules.mutableRules, id: \.self, selection: $selection) { rule in
                        Text(rule.name)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .lineLimit(1)
                            .contentShape(Rectangle())
                            .onClick {
                                selection = rule
                            } doubleClick: {
                                sheet = .rule(rule: rule)
                            }
                            .contextMenu {
                                Button("Edit") {
                                    sheet = .rule(rule: rule)
                                }
                                Button("Duplicate") {
                                    do {
                                        let _ = try rules.duplicate(rule, preferredName: "Copy of " + rule.name)
                                    } catch {
                                        alert = .duplicationFailure(error: error)
                                    }
                                }
                            }
                    }
                    HStack {
                        ListButtons {
                            do {
                                let rule = try rules.new(preferredName: "Rule")
                                selection = rule
                                sheet = .rule(rule: rule)
                            } catch {
                                print("Failed to add rule with error \(error).")
                            }
                        } remove: {
                            guard let rule = selection else {
                                return
                            }
                            do {
                                try rules.remove(rule)
                                selection = nil
                            } catch {
                                print("Failed to remove rule with error \(error).")
                            }
                        }
                        Button {
                            guard let rule = selection else {
                                return
                            }
                            sheet = .rule(rule: rule)
                        } label: {
                            Text("Edit")
                        }
                        .disabled(selection == nil)
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .rule(let rule):
                    RuleSheet(rule: rule)
                }
            }
            .alert(item: $alert) { alert in
                switch alert {
                case .duplicationFailure(let error):
                    return Alert(title: Text("Duplicate Rule Failed"), message: Text(error.localizedDescription))
                }
            }
        }
    }

}

extension RulesEditor.SheetType: Identifiable {

    var id: String {
        switch self {
        case .rule:
            return "rule"
        }
    }

}

extension RulesEditor.AlertType: Identifiable {

    public var id: String {
        switch self {
        case .duplicationFailure(let error):
            return "duplicationFailure:\(error)"
        }
    }

}
