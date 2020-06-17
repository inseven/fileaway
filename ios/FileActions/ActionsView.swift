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
    func reversePages(url: URL, completion: @escaping (Error?) -> Void)
}

struct ActionsView: View {

    weak var delegate: ActionsViewDelegate?
    @ObservedObject var settings: Settings
    @State private var displayReversePages = false
    @State private var displaySettings = false

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
                        self.displayReversePages = true
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .sheet(isPresented: $displayReversePages) {
            ReversePages { url, completion in
                guard let delegate = self.delegate else {
                    return
                }
                delegate.reversePages(url: url, completion: completion)
            }
        }
        .sheet(isPresented: $displaySettings) {
            NavigationView {
                SettingsView(settings: self.settings, tasks: self.settings.tasks)
            }
        }
        .navigationBarTitle("File Actions")
        .navigationBarItems(leading: Button(action: {
            self.displaySettings = true
        }, label: {
            Text("Settings")
        }))
    }

}
