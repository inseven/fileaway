// Copyright (c) 2018-2025 Jason Morley
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

import FileawayCore

public struct DirectoryView: View {

#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif

    @EnvironmentObject var sceneModel: SceneModel
    @ObservedObject var directoryViewModel: DirectoryViewModel

    @State var isEditing: Bool = false

    public init(directoryViewModel: DirectoryViewModel) {
        self.directoryViewModel = directoryViewModel
    }

    var selection: Binding<Set<FileInfo>> {
#if os(macOS)
        return $directoryViewModel.selection
#else
        // Selection is disabled on iOS in compact size classes.
        if horizontalSizeClass == .compact && !isEditing {
            return Binding.constant(Set<FileInfo>())
        } else {
            return $directoryViewModel.selection
        }
#endif
    }

    public var body: some View {
        List(selection: selection) {
            ForEach(directoryViewModel.files.values, id: \.self) { file in
                FileRow(file: file)
                    .swipeActions(edge: .leading) {
                        Button {
                            sceneModel.move([file])
                        } label: {
                            Label("Move", systemImage: "tray.and.arrow.down")
                        }
                        .tint(.purple)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            directoryViewModel.trash(.file(file))
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .itemProvider {
                        NSItemProvider(object: file.url as NSURL)
                    }
            }
        }
#if os(iOS)
        .listStyle(.plain)
#endif
        .contextMenu(forSelectionType: FileInfo.self) { selection in
            if !selection.isEmpty, let file = selection.first {

                Button {
                    sceneModel.move(selection)
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
                    Application.setClipboard(file.name)
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
#if os(iOS)
        .toolbar {
            if isEditing {
                CompactSelectionToolbar(directoryViewModel: directoryViewModel)
            }
        }
#endif
        .refreshable {
            self.directoryViewModel.refresh()
        }
        .editable($isEditing)
        .overlay {
            if directoryViewModel.files.isEmpty {
                ContentUnavailableView("No Files",
                                       systemImage: "party.popper",
                                       description: Text("New files will appear here automatically."))
            }
        }
        .progressOverlay(directoryViewModel.isLoading)
        .searchable(text: $directoryViewModel.filter)
        .quickLookPreview($directoryViewModel.previewUrl, in: directoryViewModel.previewUrls)
        .focusedValue(\.directoryViewModel, directoryViewModel)
        .id(directoryViewModel.url)
        .navigationTitle(directoryViewModel.name)
    }

}
