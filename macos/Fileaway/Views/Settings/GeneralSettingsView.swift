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

struct GeneralSettingsView: View {

    @ObservedObject var manager: Manager

    @State var inboxSelection: UUID?

    var body: some View {
        VStack {
            Text("Archive")
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Text(manager.archiveUrl?.path ?? "")
                Spacer()
                Button("Choose...") {
                    let openPanel = NSOpenPanel()
                    openPanel.canChooseFiles = false
                    openPanel.canChooseDirectories = true
                    openPanel.canCreateDirectories = true
                    if (openPanel.runModal() ==  NSApplication.ModalResponse.OK) {
                        try! manager.setArchiveUrl(openPanel.url!)
                    }
                }
            }
            Text("Inboxes")
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                List(selection: $inboxSelection) {
                    ForEach(manager.directories.filter { $0.type == .inbox }) { directory in
                        Text(directory.location.lastPathComponent)
                            .contextMenu {
                                Button("Reveal in Finder") {
                                    NSWorkspace.shared.activateFileViewerSelecting([directory.location])
                                }
                                Divider()
                                Button("Remove") {
                                    // TODO: Handle the error here.
                                    try? manager.removeDirectoryObserver(directoryObserver: directory)
                                }
                            }
                    }
                }
                VStack {
                    Button {
                        let openPanel = NSOpenPanel()
                        openPanel.canChooseFiles = false
                        openPanel.canChooseDirectories = true
                        openPanel.canCreateDirectories = true
                        guard openPanel.runModal() ==  NSApplication.ModalResponse.OK,
                              let url = openPanel.url else {
                            return
                        }
                        // TODO: Report an error.
                        try? manager.addLocation(type: .inbox, url: url)
                    } label: {
                        Text("Add")
                            .frame(maxWidth: .infinity)
                    }
                    Button("Remove") {
                        guard let directory = manager.directories.first(where: { $0.id == inboxSelection }) else {
                            return
                        }
                        try? manager.removeDirectoryObserver(directoryObserver: directory)
                    }
                    .disabled(inboxSelection == nil)
                    Spacer()

                }
            }
        }
    }

}
