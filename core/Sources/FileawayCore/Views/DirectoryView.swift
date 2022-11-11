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

import Combine
import SwiftUI

import Interact

public struct DirectoryView: View {

    @Environment(\.openWindow) var openWindow

    @ObservedObject var directoryViewModel: DirectoryViewModel

    public init(directoryViewModel: DirectoryViewModel) {
        self.directoryViewModel = directoryViewModel
    }

    public var body: some View {
        List(selection: $directoryViewModel.selection) {
            ForEach(directoryViewModel.files, id: \.self) { file in
                FileRow(file: file)
            }
        }
#if os(iOS)
        .listStyle(.plain)
#endif
        .contextMenu(forSelectionType: FileInfo.self) { selection in
            if !selection.isEmpty, let file = selection.first {

#if os(macOS)
                Button("Apply Rules") {
                    for file in selection {
                        // TODO: Use Wizard.windowID
                        openWindow(id: "wizard-window", value: file.url)
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
#endif

            }
        } primaryAction: { selection in
#if os(macOS)
            for file in selection {
                NSWorkspace.shared.open(file.url)
            }
#endif
        }
        // Enter to open.
        // Drag-and-drop.
        // .onCutCommand(perform: manager.cut)
        .overlay(directoryViewModel.files.isEmpty ? Placeholder("No Items") : nil)
        .searchable(text: $directoryViewModel.filter)
        .navigationTitle(directoryViewModel.name)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .focusedValue(\.directoryViewModel, directoryViewModel)
        .runs(directoryViewModel)
        .id(directoryViewModel.url)
    }

}
