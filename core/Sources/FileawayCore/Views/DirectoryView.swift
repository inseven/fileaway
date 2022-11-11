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
#endif
                Button("Open") {
                    sceneModel.open(selection)
                }
#if os(macOS)
                Button("Reveal in Finder") {
                    sceneModel.reveal(selection)
                }
#endif
                Divider()
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
            sceneModel.open(selection)

        }
        // Enter to open.
        // Drag-and-drop.
        // .onCutCommand(perform: manager.cut)
        .overlay(directoryViewModel.files.isEmpty ? Placeholder("No Items") : nil)
        .searchable(text: $directoryViewModel.filter)
        .navigationTitle(directoryViewModel.name)
        .quickLookPreview(directoryViewModel.previewUrl, in: directoryViewModel.previewUrls)
        .focusedValue(\.directoryViewModel, directoryViewModel)
        .runs(directoryViewModel)
        .id(directoryViewModel.url)
    }

}
