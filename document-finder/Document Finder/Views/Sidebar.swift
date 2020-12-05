//
//  Sidebar.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 04/12/2020.
//

import SwiftUI

struct Sidebar: View {

    @ObservedObject var manager: Manager
    @State var firstResponder: Bool = false
    @State var item: Int = 30
    @State var value: String = "SAkdfjh"

    var body: some View {
//        VStack {
//            Text("Hello")
//                .padding()
//                .background(firstResponder ? Color.pink : Color.clear)
//                .cornerRadius(6)
//                .background(ResponderView(firstResponder: $firstResponder))
//                .onTapGesture {
//                    firstResponder = true
//                }
//                .focusedValue(\.item, Binding.constant(230))
//            TextField("Title", text: $value)
//                .focusedValue(\.item, Binding.constant(230))
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
//        }
    }

}
