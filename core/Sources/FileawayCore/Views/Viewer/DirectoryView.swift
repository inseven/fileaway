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
import QuickLook
import SwiftUI

import Interact

public struct DirectoryView: View {

    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var sceneModel: SceneModel

    @ObservedObject var directoryViewModel: DirectoryViewModel

    public init(directoryViewModel: DirectoryViewModel) {
        self.directoryViewModel = directoryViewModel
    }

    @MainActor func move(_ files: Set<FileInfo>) {
#if os(macOS)
        for file in files {
            // TODO: Use Wizard.windowID
            openWindow(id: "wizard-window", value: file.url)
        }
#else
        sceneModel.move(files)
#endif
    }

    public var body: some View {
        List(selection: $directoryViewModel.selection) {
            ForEach(directoryViewModel.files, id: \.self) { file in
                FileRow(file: file)
                    .swipeActions(edge: .leading) {
                        Button {
                            move([file])
                        } label: {
                            Label("Move", systemImage: "tray.and.arrow.down")
                        }
                        .tint(.purple)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            do {
                                try directoryViewModel.trash(.file(file))
                            } catch {
                                // TODO: Handle this error in the directory model!
                                print("Failed to delete file with error \(error).")
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
#if os(iOS)
        .listStyle(.plain)
#endif
        .contextMenu(forSelectionType: FileInfo.self) { selection in
            if !selection.isEmpty, let file = selection.first {

                Button {
                    move(selection)
                } label: {
                    Label("Move", systemImage: "tray.and.arrow.down")
                }
                Divider()

#if os(macOS)
                Button("Open") {
                    sceneModel.open(selection)
                }
                Button("Reveal in Finder") {
                    sceneModel.reveal(selection)
                }
                Divider()
#endif

                Button {
                    directoryViewModel.showPreview(selecting: selection.first)
                } label: {
                    Label("Quick Look", systemImage: "eye")
                }
                .disabled(selection.count != 1)
                Divider()
                Button {
#if os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(file.name, forType: .string)
#else
                    UIPasteboard.general.string = file.name
#endif
                } label: {
                    Label("Copy Name", systemImage: "list.clipboard")
                }
                .disabled(selection.count != 1)

            }
        } primaryAction: { selection in
#if os(macOS)
            sceneModel.open(selection)
#else
            directoryViewModel.showPreview(selecting: selection.first)
#endif
        }
        .refreshable {
            self.directoryViewModel.refresh()
        }
        // TODO: Enter to open
        // TODO: Drag-and-drop
        // TODO: .onCutCommand(perform: manager.cut)
        .placeholderOverlay(directoryViewModel.files.isEmpty, text: "No Files")
        .progressOverlay(directoryViewModel.isLoading)
        .searchable(text: $directoryViewModel.filter)
        .navigationTitle(directoryViewModel.name)
        .quickLookPreview($directoryViewModel.previewUrl, in: directoryViewModel.previewUrls)
        .focusedValue(\.directoryViewModel, directoryViewModel)
        .id(directoryViewModel.url)
    }

}
