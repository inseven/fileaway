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

extension Set where Element == RuleState {

    func remove(from ruleSet: RuleSet) throws {
        for rule in self {
            try ruleSet.remove(rule)
        }
    }

    func duplicate(in ruleSet: RuleSet) throws {
        for rule in self {
            let _ = try ruleSet.duplicate(rule, preferredName: "Copy of " + rule.name)
        }
    }

}

struct RulesEditor: View {

    enum SheetType {
        case rule(rule: RuleState)
    }

    enum AlertType {
        case duplicationFailure(error: Error)
        case error(error: Error)
    }

    @ObservedObject var ruleSet: RuleSet
    @State var selection: Set<RuleState> = Set()
    @State var sheet: SheetType?
    @State var alert: AlertType?

    func add() {
        do {
            let rule = try ruleSet.new(preferredName: "Rule")
            selection = [rule]
            sheet = .rule(rule: rule)
        } catch {
            alert = .error(error: error)
        }
    }

    func edit(rules: Set<RuleState>) {
        guard rules.count == 1,
              let rule = rules.first else {
            return
        }
        sheet = .rule(rule: rule)
    }

    func delete(rules: Set<RuleState>) {
        do {
            try rules.remove(from: ruleSet)
            selection = selection.filter { !rules.contains($0) }
        } catch {
            alert = .error(error: error)
        }
    }

    func duplicate(rules: Set<RuleState>) {
        do {
            let _ = try rules.duplicate(in: ruleSet)
        } catch {
            alert = .duplicationFailure(error: error)
        }
    }

    var body: some View {
        HStack {
            VStack {
                ScrollViewReader { scrollView in
                    List(ruleSet.mutableRules, id: \.self, selection: $selection) { rule in
                        Text(rule.name)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .lineLimit(1)
                            .contentShape(Rectangle())
                            .handleMouse {
                                selection = [rule]
                            } doubleClick: {
                                selection = [rule]
                                sheet = .rule(rule: rule)
                            }
                            .contextMenu {
                                
                                MenuItem("Edit", selection: $selection, item: rule) { items in
                                    edit(rules: items)
                                }
                                .itemLimit(1)

                                MenuItem("Duplicate", selection: $selection, item: rule) { items in
                                    duplicate(rules: items)
                                }

                                MenuItem("Delete", selection: $selection, item: rule) { items in
                                    delete(rules: items)
                                }

                            }
                    }

                    HStack {

                        ControlGroup {

                            Button {
                                add()
                            } label: {
                                Image(systemName: "plus")
                            }

                            Button {
                                delete(rules: selection)
                            } label: {
                                Image(systemName: "minus")
                            }
                            .disabled(selection.count < 1)

                        }

                        Button {
                            edit(rules: selection)
                        } label: {
                            Text("Edit")
                        }
                        .disabled(selection.count != 1)
                        .layoutPriority(2)

                        Spacer()
                            .layoutPriority(1)

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
                case .error(let error):
                    return Alert(error: error)
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
        case .error(let error):
            return "error:\(String(describing: error))"
        }
    }

}
