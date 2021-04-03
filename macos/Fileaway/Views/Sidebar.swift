//
//  Sidebar.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 04/12/2020.
//

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
