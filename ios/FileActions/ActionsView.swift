//
//  ActionsView.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation
import MobileCoreServices
import SwiftUI

protocol ActionsViewDelegate: NSObject {
    func moveFileTapped()
}

enum ActionSheet {
    case none
    case settings
    case reversePages
}

struct ActionsView: View {

    weak var delegate: ActionsViewDelegate?
    @ObservedObject var settings: Settings
    @State private var showSheet = false
    @State private var activeSheet: ActionSheet = .none

    var body: some View {
        VStack {
            List {
                Section(footer: Destination(url: $settings.destination)) {
                    ActionView(text: "Move file...", imageName: "folder") {
                        guard let delegate = self.delegate else {
                            return
                        }
                        delegate.moveFileTapped()
                    }
                }
                Section {
                    ActionView(text: "Reverse pages...", imageName: "doc.on.doc") {
                        self.activeSheet = .reversePages
                        self.showSheet = true
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .sheet(isPresented: $showSheet) {
            if self.activeSheet == .settings {
                NavigationView {
                    SettingsView(settings: self.settings, tasks: self.settings.tasks)
                }
            } else if self.activeSheet == .reversePages {
                ReversePages(task: ReverseTask())
            } else {
                Text("None")
            }
        }
        .navigationBarTitle("File Actions")
        .navigationBarItems(leading: Button(action: {
            self.activeSheet = .settings
            self.showSheet = true
        }, label: {
            Text("Settings")
        }))
    }

}
