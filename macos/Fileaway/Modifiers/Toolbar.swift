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

import Interact

struct Toolbar: ViewModifier {

    @Environment(\.openURL) var openURL

    @ObservedObject var manager: SelectionManager
    @Binding var filter: String

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Button {
                        guard let file = manager.tracker.selection.first else {
                            return
                        }
                        QuickLookCoordinator.shared.show(url: file.url)
                    } label: {
                        Image(systemName: "eye")
                    }
                    .disabled(!manager.canPreview)
                }
                ToolbarItem {
                    Button {
                        guard let file = manager.tracker.selection.first else {
                            return
                        }
                        var components = URLComponents()
                        components.scheme = "fileaway"
                        components.path = file.url.path
                        guard let url = components.url else {
                            return
                        }
                        openURL(url)
                    } label: {
                        Image(systemName: "archivebox")
                    }
                    .keyboardShortcut(KeyboardShortcut(.return, modifiers: .command))
                }
                ToolbarItem {
                    Button {
                        try? manager.trash()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(!manager.canTrash)
                }
                ToolbarItem {
                    SearchField(search: $filter)
                        .frame(minWidth: 100, idealWidth: 200, maxWidth: .infinity)
                }
            }
    }
}
