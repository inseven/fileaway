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

import Interact

import FileawayCore

struct RulesEditor: View {

    enum SheetType: Identifiable {

        case rule(RuleModel)

        var id: String {
            switch self {
            case .rule(let ruleModel):
                return "rule-\(ruleModel.id)"
            }
        }

    }

    enum AlertType {
        case duplicationFailure(error: Error)
        case error(error: Error)
    }

    @ObservedObject var rulesModel: RulesModel
    @State var selection: Set<RuleModel.ID> = Set()
    @State var sheet: SheetType?
    @State var alert: AlertType?

    @MainActor private func rules(for ids: Set<RuleModel.ID>) -> Set<RuleModel> {
        return Set(rulesModel.ruleModels.filter { ids.contains($0.id) })
    }

    @MainActor private func add() {
        do {
            let rule = try rulesModel.new()
            selection = [rule.id]
            sheet = .rule(rule)
        } catch {
            alert = .error(error: error)
        }
    }

    @MainActor private func edit(ids: Set<RuleModel.ID>) {
        guard ids.count == 1,
              let ruleModel = rules(for: ids).first
        else {
            return
        }
        sheet = .rule(ruleModel)
    }

    @MainActor private func delete(ids: Set<RuleModel.ID>) {
        do {
            try rulesModel.remove(ids: ids)
            selection = selection.filter { !ids.contains($0) }
        } catch {
            alert = .error(error: error)
        }
    }

    @MainActor private func duplicate(ids: Set<RuleModel.ID>) {
        do {
            let newRules = try rulesModel.duplicate(ids: ids)
            selection = Set(newRules.map({ $0.id }))
        } catch {
            alert = .duplicationFailure(error: error)
        }
    }

    var body: some View {
        HStack {
            VStack {
                List(rulesModel.ruleModels, selection: $selection) { rule in
                    Text(rule.name)
                        .lineLimit(1)
                }
                .contextMenu(forSelectionType: RuleModel.ID.self) { items in

                    Button("Edit") {
                        edit(ids: items)
                    }
                    .disabled(items.count != 1)

                    Button("Duplicate") {
                        duplicate(ids: items)
                    }
                    .disabled(items.count < 1)

                    Button("Delete") {
                        delete(ids: items)
                    }
                    .disabled(items.count < 1)

                } primaryAction: { items in
                    edit(ids: selection)
                }

                HStack {

                    ControlGroup {

                        Button {
                            add()
                        } label: {
                            Image(systemName: "plus")
                        }

                        Button {
                            delete(ids: selection)
                        } label: {
                            Image(systemName: "minus")
                        }
                        .disabled(selection.count < 1)
                        .keyboardShortcut(.delete)

                    }

                    Button("Edit") {
                        edit(ids: selection)
                    }
                    .disabled(selection.count != 1)

                    Spacer()
                }

            }
            .frame(maxWidth: .infinity)
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .rule(let rule):
                    RuleSheet(ruleModel: rule)
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
