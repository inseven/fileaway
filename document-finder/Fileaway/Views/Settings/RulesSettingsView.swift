//
//  RulesSettingsView.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import SwiftUI

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
        .background(Color(NSColor.windowBackgroundColor))
        .frame(minWidth: 600, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
    }

}

struct RulesSettingsView: View {

    enum SheetType {
        case rule(rule: RuleState)
    }

    @ObservedObject var rules: RuleSet
    @State var selection: RuleState?
    @State var sheet: SheetType?

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
