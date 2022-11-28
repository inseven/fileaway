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

struct SetFolderButton: View {

    private var ruleModel: RuleModel
    @ObservedObject private var componentModel: ComponentModel

    init(ruleModel: RuleModel, componentModel: ComponentModel) {
        self.ruleModel = ruleModel
        self.componentModel = componentModel
    }

    var body: some View {
        Button {
            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = true
            var isDirectory = ObjCBool(true)
            let currentDirectory = ruleModel.archiveURL.appendingPathComponent(componentModel.value)
            if FileManager.default.fileExists(atPath: currentDirectory.path,
                                              isDirectory: &isDirectory) && isDirectory.boolValue {
                openPanel.directoryURL = currentDirectory
            } else {
                openPanel.directoryURL = ruleModel.archiveURL
            }
            guard openPanel.runModal() == NSApplication.ModalResponse.OK,
                  let url = openPanel.url,
                  let relativePath = url.relativePath(from: ruleModel.archiveURL) else {
                return
            }
            componentModel.value = relativePath + "/"
        } label: {
            Image(systemName: "folder")
        }
    }

}

//struct ComponentView: View {
//
//    @State var ruleModel: RuleModel
//    @ObservedObject var component: ComponentModel
//
//    var body: some View {
//        VStack {
//            switch component.type {
//            case .text:
//                VStack {
//                    TextField("Contents", text: $component.value)
//                    SetFolderButton(ruleModel: ruleModel, componentModel: component)
//                }
//            case .variable:
//                Text("Variable")
//            }
//        }
//    }
//
//}
