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
                        openPanel.canCreateDirectories = true
                        var isDirectory = ObjCBool(true)
                        let currentDirectory = rule.rootUrl.appendingPathComponent(component.value)
                        if FileManager.default.fileExists(atPath: currentDirectory.path,
                                                          isDirectory: &isDirectory) && isDirectory.boolValue {
                            openPanel.directoryURL = currentDirectory
                        } else {
                            openPanel.directoryURL = rule.rootUrl
                        }
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
                    Button(String(describing: variable.name)) {
                        rule.destination.append(ComponentState(value: variable.name, type: .variable, variable: variable))
                    }
                    .layoutPriority(2)
                }

                Button("Text") {
                    rule.destination.append(ComponentState(value: "Text", type: .text, variable: nil))
                }
                .layoutPriority(2)

                ControlGroup {
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
                .layoutPriority(2)

                Spacer()
                    .layoutPriority(1)
            }

        }
    }

}
