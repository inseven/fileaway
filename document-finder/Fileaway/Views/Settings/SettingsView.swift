//
//  SettingsView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 05/12/2020.
//

import Combine
import SwiftUI

struct VariableTextField: View {

    @ObservedObject var variable: VariableState
    @State var variableType: VariableType = .string

    var body: some View {
        VStack {
            TextField("Name", text: $variable.name)
            Picker(selection: $variable.type, label: Text("Type")) {
                ForEach(VariableType.allCases, id: \.self) { type in
                    Text(String(describing: type))
                }
            }
            Spacer()
        }
    }

}

struct ListButtons: View {

    var add: () -> Void
    var remove: () -> Void

    var body: some View {
        HStack {
            Button(action: add) {
                Image(systemName: "plus")
            }
            Button(action: remove) {
                Image(systemName: "minus")
            }
        }
    }

}

struct SettingsView: View {

    private enum Tabs: Hashable {
        case general
    }

    @ObservedObject var manager: Manager

    var body: some View {
        TabView {
            GeneralSettingsView(manager: manager)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            RulesSettingsView(rules: manager.ruleSet!)
                .tabItem {
                    Label("Rules", systemImage: "tray.and.arrow.down")
                }
        }
        .padding()
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 460, maxHeight: .infinity)
    }

}
