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
    case interleave
    case fakeDuplex
}

struct ActionsView: View {

    weak var delegate: ActionsViewDelegate?
    @ObservedObject var settings: Settings
    @State private var showSheet = false
    @State private var activeSheet: ActionSheet = .none

    var body: some View {
        ScrollView {
        VStack {
            ActionMenu {
                ActionGroup(footer: Destination(url: self.$settings.destination)) {
                    ActionButton("Move File", systemName: "folder") {
                        guard let delegate = self.delegate else {
                            return
                        }
                        delegate.moveFileTapped()
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: .accentColor, foregroundColor: .white))
                }
                ActionGroup(footer: EmptyView()) {
                    ActionButton("Reverse Pages", systemName: "doc.on.doc") {
                        self.activeSheet = .reversePages
                        self.showSheet = true
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: Color(UIColor.systemFill)))
                    ActionButton("Interleave Pages", systemName: "doc.on.doc") {
                        self.activeSheet = .interleave
                        self.showSheet = true
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: Color(UIColor.systemFill)))
                    ActionButton("Fake Duplex", systemName: "doc.on.doc") {
                        self.activeSheet = .fakeDuplex
                        self.showSheet = true
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: Color(UIColor.systemFill)))
                }
            }
            .padding()
            .frame(maxWidth: 520)
            }
        }
        .sheet(isPresented: $showSheet) {
            if self.activeSheet == .settings {
                NavigationView {
                    SettingsView(settings: self.settings)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else if self.activeSheet == .reversePages {
                ReversePages(task: ReverseTask())
            } else if self.activeSheet == .interleave {
                MergeDocumentsView(task: MergeTask())
            } else if self.activeSheet == .fakeDuplex {
                FakeDuplexView(task: FakeDuplexTask())
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
