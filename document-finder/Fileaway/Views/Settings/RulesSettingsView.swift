//
//  RulesSettingsView.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import SwiftUI

struct RulesSettingsView: View {

    @ObservedObject var rules: Rules
    @State var selection: Task?
    @State var newSelection: Task?

    var body: some View {
        HStack {
            VStack {
                ScrollViewReader { scrollView in
                    List(rules.rules, id: \.self, selection: $selection) { rule in
                        Text(rule.name)
                            .lineLimit(1)
                            .id(rule.id)
                    }
                    HStack {
                        ListButtons {
                            let rule = Task(name: "New rule")
                            do {
                                try rules.add(rule)
                                selection = rule
                                newSelection = rule
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
                        Spacer()
                    }
                    .onChange(of: newSelection) { rule in
                        guard let rule = rule else {
                            return
                        }
                        scrollView.scrollTo(rule.id)
                    }
                }
            }
            VStack {
                if let rule = selection {
                    RuleDetailView(rule: rule)
                        .id(rule)
                } else {
                    Text("No Item Selected")
                }
            }
            .padding(.leading)
            .frame(maxWidth: .infinity)
        }
    }

}
