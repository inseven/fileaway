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

    @Environment(\.applicationModel) var manager
    @Environment(\.openWindow) var openWindow

    @ObservedObject var selectionModel: SelectionModel

    var body: some CustomizableToolbarContent {
        ToolbarItem(id: "wizard") {
            Button {
                for file in selectionModel.selection {
                    openWindow(id: Wizard.windowID, value: file.url)
                }
            } label: {
                Label("Apply Rules", systemImage: "tray.and.arrow.down")
            }
            .help("Move the selected items using the Rules Wizard")
            .keyboardShortcut(KeyboardShortcut(.return, modifiers: .command))
            .disabled(!selectionModel.canMove)
        }
        ToolbarItem(id: "preview") {
            Button {
                guard let file = selectionModel.selection.first else {
                    return
                }
                QuickLookCoordinator.shared.show(url: file.url)
            } label: {
                Label("Preview", systemImage: "eye")
            }
            .help("Show items with Quick Look")
            .keyboardShortcut(.space, modifiers: [])
            .disabled(!selectionModel.canPreview)
        }
        ToolbarItem(id: "delete") {
            Button {
                try? selectionModel.trash()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .help("Move the selected items to the Bin")
            .keyboardShortcut(.delete)
            .disabled(!selectionModel.canTrash)
        }
    }

}
