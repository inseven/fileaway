//
//  GeneralSettingsView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 05/12/2020.
//

import SwiftUI

struct GeneralSettingsView: View {

    @ObservedObject var manager: Manager

    var body: some View {
        VStack {
            HStack {
                Text("Inbox")
                    .font(.headline)
                Text(manager.inboxUrl?.path ?? "")
                Button("Choose...") {
                    let openPanel = NSOpenPanel()
                    openPanel.canChooseFiles = false
                    openPanel.canChooseDirectories = true
                    if (openPanel.runModal() ==  NSApplication.ModalResponse.OK) {
                        try! manager.setInboxUrl(openPanel.url!)
                    }
                }
            }
            HStack {
                Text("Archive")
                    .font(.headline)
                Text(manager.archiveUrl?.path ?? "")
                Button("Choose...") {
                    let openPanel = NSOpenPanel()
                    openPanel.canChooseFiles = false
                    openPanel.canChooseDirectories = true
                    if (openPanel.runModal() ==  NSApplication.ModalResponse.OK) {
                        try! manager.setArchiveUrl(openPanel.url!)
                    }
                }
            }
        }
    }

}
