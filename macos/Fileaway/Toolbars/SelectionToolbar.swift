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

struct SelectionToolbar: CustomizableToolbarContent {

    @Environment(\.openWindow) var openWindow

    @EnvironmentObject private var applicationModel: ApplicationModel
    @ObservedObject var directoryViewModel: DirectoryViewModel

    var body: some CustomizableToolbarContent {
        ToolbarItem(id: "wizard") {
            Button {
                for file in directoryViewModel.selection {
                    openWindow(id: Wizard.windowID, value: file.url)
                }
            } label: {
                Label("Apply Rules", systemImage: "tray.and.arrow.down")
            }
            .help("Move the selected items using the Rules Wizard")
            .keyboardShortcut(KeyboardShortcut(.return, modifiers: .command))
            .disabled(!directoryViewModel.canShowRulesWizard)
        }
        ToolbarItem(id: "preview") {
            Button {
                directoryViewModel.showPreview()
            } label: {
                Label("Preview", systemImage: "eye")
            }
            .help("Show items with Quick Look")
            .keyboardShortcut(.space, modifiers: [])
            .disabled(!directoryViewModel.canPreview)
        }
        ToolbarItem(id: "delete") {
            Button {
                try? directoryViewModel.trash(.selection)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .help("Move the selected items to the Bin")
            .keyboardShortcut(.delete)
            .disabled(!directoryViewModel.canTrash)
        }
    }

}
