//
//  Sidebar.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 04/12/2020.
//

import SwiftUI

struct Sidebar: View {

    @ObservedObject var manager: Manager

    var body: some View {
        VStack {
            List {
                Section(header: Text("Locations")) {
                    if let inbox = manager.inbox {
                        NavigationLink(destination: DirectoryView(directoryObserver: inbox), label: {
                            MailboxRow(directoryObserver: inbox, title: "Inbox", imageSystemName: "tray")
                        })
                    }
                    if let archive = manager.archive {
                        NavigationLink(destination: DirectoryView(directoryObserver: archive), label: {
                            MailboxRow(directoryObserver: archive, title: "Archive", imageSystemName: "archivebox")
                        })
                    }
                }
            }
        }
    }

}
