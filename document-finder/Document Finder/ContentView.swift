//
//  ContentView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 01/12/2020.
//

import SwiftUI

struct MailboxRow: View {

    @ObservedObject var directoryObserver: DirectoryObserver
    var title: String
    var imageSystemName: String

    var body: some View {
        HStack {
            Image(systemName: imageSystemName)
                .foregroundColor(.accentColor)
            Text(title)
            Spacer()
            Text(String(directoryObserver.count))
        }
    }

}

struct ContentView: View {

    @ObservedObject var manager: Manager

    var body: some View {
        NavigationView {
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
            EmptyView()
                .modifier(Toolbar(selection: nil, filter: Binding.constant(""), qlCoordinator: QLCoordinator()))
        }
    }
}
