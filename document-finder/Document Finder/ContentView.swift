//
//  ContentView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 01/12/2020.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var manager: Manager

    var body: some View {
        NavigationView {
            VStack {
                if manager.inbox == nil {
                    Button("Set Inbox") {
                        let openPanel = NSOpenPanel()
                        openPanel.canChooseFiles = false
                        openPanel.canChooseDirectories = true
                        if (openPanel.runModal() ==  NSApplication.ModalResponse.OK) {
                            try! manager.setInboxUrl(openPanel.url!)
                        }
                    }
                }
                if manager.archive == nil {
                    Button("Set Archive") {
                        let openPanel = NSOpenPanel()
                        openPanel.canChooseFiles = false
                        openPanel.canChooseDirectories = true
                        if (openPanel.runModal() ==  NSApplication.ModalResponse.OK) {
                            try! manager.setArchiveUrl(openPanel.url!)
                        }
                    }
                }
                List {
                    Group {
                        if let inbox = manager.inbox {
                            NavigationLink(destination: DirectoryView(directoryObserver: inbox), label: {
                                Image(systemName: "tray")
                                    .foregroundColor(.accentColor)
                                Text("Inbox")
                            })
                        }
                        if let archive = manager.archive {
                            NavigationLink(destination: DirectoryView(directoryObserver: archive), label: {
                                Image(systemName: "archivebox")
                                    .foregroundColor(.accentColor)
                                Text("Archive")
                            })
                        }
                    }
                }
                EmptyView()
            }
        }
    }
}
