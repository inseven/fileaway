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

    @Environment(\.openWindow) var openWindow

    @ObservedObject var directoryObserver: DirectoryObserver

    @StateObject var model: SelectionModel

    init(directoryObserver: DirectoryObserver) {
        self.directoryObserver = directoryObserver
        _model = StateObject(wrappedValue: SelectionModel(directory: directoryObserver))
    }

    var body: some View {
        List(selection: $model.selection) {
            ForEach(directoryObserver.searchResults, id: \.self) { file in
                FileRow(file: file)
            }
        }
        .contextMenu(forSelectionType: FileInfo.self) { selection in
            if !selection.isEmpty, let file = selection.first {

                Button("Apply Rules") {
                    for file in selection {
                        openWindow(id: Wizard.windowID, value: file.url)
                    }
                }
                Divider()
                Button("Open") {
                    for file in selection {
                        NSWorkspace.shared.open(file.url)
                    }
                }
                Button("Reveal in Finder") {
                    for file in selection {
                        NSWorkspace.shared.activateFileViewerSelecting([file.url])
                    }
                }
                Divider()
                Button("Quick Look") {
                    QuickLookCoordinator.shared.show(url: file.url)
                }
                .disabled(selection.count != 1)
                Divider()
                Button("Copy name") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(file.name, forType: .string)
                }
                .disabled(selection.count != 1)

            }
        } primaryAction: { selection in
            for file in selection {
                NSWorkspace.shared.open(file.url)
            }
        }
        // Enter to open.
        // Drag-and-drop.
        // .onCutCommand(perform: manager.cut)
        .overlay(directoryObserver.searchResults.isEmpty ? Text("No Items").font(.title).foregroundColor(.secondary) : nil)
        .searchable(text: directoryObserver.filter)
        .toolbar(id: "main") {
            SelectionToolbar(selectionManager: model)
        }
        .navigationTitle(directoryObserver.name)
        .onAppear {
            model.start()
        }
        .onDisappear {
            model.stop()
        }
    }

}
