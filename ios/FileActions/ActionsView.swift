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
    func settingsTapped()
    func moveFileTapped()
    func reversePages(url: URL, completion: @escaping (Error?) -> Void)
}

struct ActionsView: View {

    weak var delegate: ActionsViewDelegate?
    @ObservedObject var settings: Settings
    @State private var displayModal = false

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
                        self.displayModal = true
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .sheet(isPresented: $displayModal) {
            ReversePages { url, completion in
                guard let delegate = self.delegate else {
                    return
                }
                delegate.reversePages(url: url, completion: completion)
            }
        }
        .navigationBarTitle("File Actions")
        .navigationBarItems(leading: Button(action: {
            print("Settings tapped")
            guard let delegate = self.delegate else {
                return
            }
            delegate.settingsTapped()
        }, label: {
            Text("Settings")
        }))
    }

}
