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
    case settings
    case reversePages
    case interleave
    case fakeDuplex
}

extension ActionSheet: Identifiable {
    public var id: ActionSheet { self }
}

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}

struct ActionsView: View {

    weak var delegate: ActionsViewDelegate?
    @ObservedObject var settings: Settings
    @State private var activeSheet: ActionSheet?

    func sheet(type: ActionSheet) -> some View {
        switch type {
        case .settings:
            return NavigationView {
                SettingsView(settings: self.settings)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
        case .reversePages:
            return ReversePages(task: ReverseTask())
                .eraseToAnyView()
        case .interleave:
            return MergeDocumentsView(task: MergeTask())
                .eraseToAnyView()
        case .fakeDuplex:
            return FakeDuplexView(task: FakeDuplexTask())
                .eraseToAnyView()
        }
    }

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
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: Color(UIColor.systemFill)))
                    ActionButton("Interleave Pages", systemName: "doc.on.doc") {
                        self.activeSheet = .interleave
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: Color(UIColor.systemFill)))
                    ActionButton("Fake Duplex", systemName: "doc.on.doc") {
                        self.activeSheet = .fakeDuplex
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: Color(UIColor.systemFill)))
                }
            }
            .padding()
            .frame(maxWidth: 520)
            }
        }
        .sheet(item: $activeSheet, onDismiss: {
            self.activeSheet = nil
        }, content: { sheet in
            return self.sheet(type: sheet)
        })
        .navigationBarTitle("File Actions")
        .navigationBarItems(leading: Button(action: {
            self.activeSheet = .settings
        }, label: {
            Text("Settings")
        }))
    }

}
