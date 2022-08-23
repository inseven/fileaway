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

import AppKit
import Combine
import Quartz
import SwiftUI

import FileawayCore
import Interact

struct DirectoryView: View {

    @Environment(\.openURL) var openURL

    @ObservedObject var directoryObserver: DirectoryObserver

    @StateObject var manager = SelectionManager()

    init(directoryObserver: DirectoryObserver) {
        self.directoryObserver = directoryObserver
    }

    var body: some View {
        List(selection: $manager.selection) {
            ForEach(directoryObserver.searchResults, id: \.self) { file in
                FileRow(file: file)
            }
        }
        .contextMenu(forSelectionType: FileInfo.self) { selection in
            if selection.count == 1, let file = selection.first {

                Button("Rules Wizard") {
                    var components = URLComponents()
                    components.scheme = "fileaway"
                    components.path = file.url.path
                    guard let url = components.url else {
                        return
                    }
                    openURL(url)
                }
                Divider()
                Button("Open") {
                    NSWorkspace.shared.open(file.url)
                }
                Button("Reveal in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting([file.url])
                }
                Divider()
                Button("Quick Look") {
                    QuickLookCoordinator.shared.show(url: file.url)
                }
                Divider()
                Button("Copy name") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(file.name, forType: .string)
                }

            }
        } primaryAction: { selection in
            for file in selection {
                NSWorkspace.shared.open(file.url)
            }
        }
        // Enter to open.
        // Drag-and-drop.
        // .onCutCommand(perform: manager.cut)
        .searchable(text: directoryObserver.filter)
        .toolbar(id: "main") {
            SelectionToolbar(manager: manager)
        }
        .navigationTitle(directoryObserver.name)
    }

}
