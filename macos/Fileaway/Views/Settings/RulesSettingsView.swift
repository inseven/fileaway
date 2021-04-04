//
//  RulesSettingsView.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import SwiftUI

import Interact

struct RuleSheet: View {

    @Environment(\.presentationMode) var presentationMode
    @State var rule: RuleState

    var body: some View {
        VStack {
            RuleDetailView(rule: rule)
            HStack {
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Done")
                }
            }
            .padding()
        }
        .background(Color.windowBackgroundColor)
        .frame(minWidth: 600, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
    }

}

struct RulesSettingsView: View {

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
                            .lineLimit(1)
                            .id(rule.id)
                            .onTapGesture(count: 2) {
                                print("Double tapped!")
                                sheet = .rule(rule: rule)
                            }
                            .contextMenu {
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
                                let rule = try rules.new()
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

extension RulesSettingsView.SheetType: Identifiable {

    var id: String {
        switch self {
        case .rule:
            return "rule"
        }
    }

}

extension RulesSettingsView.AlertType: Identifiable {

    public var id: String {
        switch self {
        case .duplicationFailure(let error):
            return "duplicationFailure:\(error)"
        }
    }

}
