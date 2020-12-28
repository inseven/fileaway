//
//  DestinationList.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import SwiftUI

struct ComponentView: View {

    @State var rule: RuleState
    @ObservedObject var component: ComponentState

    var body: some View {
        VStack {
            switch component.type {
            case .text:
                VStack {
                    TextField("Contents", text: $component.value)
                    Button("Set Folder") {
                        let openPanel = NSOpenPanel()
                        openPanel.canChooseFiles = false
                        openPanel.canChooseDirectories = true
                        guard openPanel.runModal() == NSApplication.ModalResponse.OK,
                              let url = openPanel.url,
                              let relativePath = url.relativePath(from: rule.rootUrl) else {
                            return
                        }
                        component.value = relativePath + "/"
                    }

                }
            case .variable:
                Text("Variable")
            }
        }
    }

}

struct DestinationList: View {

    @ObservedObject var rule: RuleState
    @State var selection: ComponentState?

    var body: some View {
        VStack {
            HStack {
                List(rule.destination, id: \.self, selection: $selection) { component in
                    Text(component.value)
                }
                VStack {
                    if let component = selection {
                        ComponentView(rule: rule, component: component)
                            .id(component)
                    } else {
                        Text("No Component Selected")
                    }
                }
                .frame(width: 200)
            }
            HStack {
                ForEach(rule.variables) { variable in
                    Button(action: {
                        rule.destination.append(ComponentState(value: variable.name, type: .variable, variable: variable))
                    }) {
                        Text(String(describing: variable.name))
                    }
                }
                Button {
                    guard let component = selection else {
                        return
                    }
                    rule.remove(component: component)
                    selection = nil
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selection == nil)
                Button {
                    guard let component = selection else {
                        return
                    }
                    rule.moveUp(component: component)
                } label: {
                    Image(systemName: "arrow.up")
                }
                Button {
                    guard let component = selection else {
                        return
                    }
                    rule.moveDown(component: component)
                } label: {
                    Image(systemName: "arrow.down")
                }
                Spacer()
            }

        }
    }

}
