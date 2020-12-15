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
            Button("Set Inbox") {
                let openPanel = NSOpenPanel()
                openPanel.canChooseFiles = false
                openPanel.canChooseDirectories = true
                if (openPanel.runModal() ==  NSApplication.ModalResponse.OK) {
                    try! manager.setInboxUrl(openPanel.url!)
                }
            }
            Button("Set Archive") {
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
