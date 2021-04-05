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

struct Sidebar: View {

    @ObservedObject var manager: Manager
    @State var firstResponder: Bool = false
    @State var item: Int = 30
    @State var value: String = "SAkdfjh"
    @State var selection: SidebarSection? = .inbox

    var body: some View {
        List {
            Section(header: Text("Locations")) {
                if let inbox = manager.inbox {
                    NavigationLink(destination: DirectoryView(directoryObserver: inbox), tag: .inbox, selection: $selection) {
                        MailboxRow(directoryObserver: inbox, title: "Inbox", imageSystemName: "tray")
                    }
                }
                if let archive = manager.archive {
                    NavigationLink(destination: DirectoryView(directoryObserver: archive), tag: .archive, selection: $selection) {
                        MailboxRow(directoryObserver: archive, title: "Archive", imageSystemName: "archivebox")
                    }
                }
            }
        }
    }
    
}
