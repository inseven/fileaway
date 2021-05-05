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

enum SidebarSection {
    case inbox
    case archive
}

extension Alert {

    init(error: Error) {
        self.init(title: Text("Error"), message: Text(error.localizedDescription))
    }

}

struct Sidebar: View {

    enum AlertType {
        case error(error: Error)
    }

    @ObservedObject var manager: Manager
    @State var firstResponder: Bool = false
    @State var alertType: AlertType?

    var body: some View {
        List {
            Section(header: Text("Inboxes")) {
                ForEach(manager.directories.filter({ $0.type == .inbox})) { inbox in
                    NavigationLink(destination: DirectoryView(directoryObserver: inbox)) {
                        MailboxRow(directoryObserver: inbox, title: inbox.name, imageSystemName: "tray")
                    }
                    .contextMenu {
                        LocationMenuItems(manager: manager, directoryObserver: inbox) { error in
                            alertType = .error(error: error)
                        }
                    }
                }
            }
            Section(header: Text("Archives")) {
                ForEach(manager.directories.filter({ $0.type == .archive})) { archive in
                    NavigationLink(destination: DirectoryView(directoryObserver: archive)) {
                        MailboxRow(directoryObserver: archive, title: archive.name, imageSystemName: "archivebox")
                    }
                    .contextMenu {
                        LocationMenuItems(manager: manager, directoryObserver: archive) { error in
                            alertType = .error(error: error)
                        }
                    }
                }
            }
        }
        // TODO: Perhaps there's a better way to propagate this to the top-level of the app?
        .alert(item: $alertType) { alertType in
            switch alertType {
            case .error(let error):
                return Alert(error: error)
            }
        }

    }
    
}

extension Sidebar.AlertType: Identifiable {

    public var id: String {
        switch self {
        case .error(let error):
            return "error-\(String(describing: error))"
        }
    }

}
