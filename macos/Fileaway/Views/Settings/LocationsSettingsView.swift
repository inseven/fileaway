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

struct LocationsSettingsView: View {

    enum AlertType {
        case error(error: Error)
    }

    @ObservedObject var manager: Manager

    @State var inboxSelection: UUID?
    @State var alertType: AlertType?

    var body: some View {
        VStack {
            Text("Inboxes")
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                List(selection: $inboxSelection) {
                    ForEach(manager.directories.filter { $0.type == .inbox }) { directory in
                        Text(directory.url.lastPathComponent)
                            .contextMenu {
                                Button("Reveal in Finder") {
                                    NSWorkspace.shared.activateFileViewerSelecting([directory.url])
                                }
                                Divider()
                                Button("Remove") {
                                    do {
                                        try manager.removeDirectoryObserver(directoryObserver: directory)
                                    } catch {
                                        alertType = .error(error: error)
                                    }
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
        }
        .alert(item: $alertType) { alertType in
            switch alertType {
            case .error(let error):
                return Alert(title: Text("Error"), message: Text(error.localizedDescription))
            }
        }
    }

}

extension LocationsSettingsView.AlertType: Identifiable {
    public var id: String {
        switch self {
        case .error(let error):
            return "error-\(String(describing: error))"
        }
    }
}
