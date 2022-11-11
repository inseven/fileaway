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

import FileawayCore

struct ComponentView: View {

    @State var ruleModel: RuleModel
    @ObservedObject var component: ComponentModel

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
                        let currentDirectory = ruleModel.rootUrl.appendingPathComponent(component.value)
                        if FileManager.default.fileExists(atPath: currentDirectory.path,
                                                          isDirectory: &isDirectory) && isDirectory.boolValue {
                            openPanel.directoryURL = currentDirectory
                        } else {
                            openPanel.directoryURL = ruleModel.rootUrl
                        }
                        guard openPanel.runModal() == NSApplication.ModalResponse.OK,
                              let url = openPanel.url,
                              let relativePath = url.relativePath(from: ruleModel.rootUrl) else {
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

    @ObservedObject var ruleModel: RuleModel
    @State var selection: ComponentModel?

    var body: some View {
        VStack {
            HStack {
                List(ruleModel.destination, id: \.self, selection: $selection) { component in
                    Text(component.value)
                }
                VStack {
                    if let component = selection {
                        ComponentView(ruleModel: ruleModel, component: component)
                            .id(component)
                    } else {
                        Text("No Component Selected")
                    }
                }
                .frame(width: 200)
            }
            HStack {

                ForEach(ruleModel.variables) { variable in
                    Button(String(describing: variable.name)) {
                        ruleModel.destination.append(ComponentModel(value: variable.name, type: .variable, variable: variable))
                    }
                }

                Button("Text") {
                    ruleModel.destination.append(ComponentModel(value: "Text", type: .text, variable: nil))
                }

                ControlGroup {

                    Button {
                        guard let component = selection else {
                            return
                        }
                        ruleModel.moveUp(component: component)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    .disabled(selection == nil)

                    Button {
                        guard let component = selection else {
                            return
                        }
                        ruleModel.moveDown(component: component)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                    .disabled(selection == nil)

                }

                Button {
                    guard let component = selection else {
                        return
                    }
                    ruleModel.remove(component: component)
                    selection = nil
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selection == nil)

                Spacer()
            }

        }
    }

}
