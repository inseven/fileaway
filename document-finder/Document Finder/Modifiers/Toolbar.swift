//
//  Toolbar.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 03/12/2020.
//

import Quartz
import SwiftUI

struct Toolbar: ViewModifier {

    var selection: URL?
    @Binding var filter: String
    let qlCoordinator: QLCoordinator

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Button {
                        print("Preview")
                        let panel = QLPreviewPanel.shared()
                        qlCoordinator.set(path: selection!)
                        panel?.center()
                        panel?.dataSource = self.qlCoordinator
                        panel?.makeKeyAndOrderFront(nil)
                    } label: {
                        Image(systemName: "eye")
                    }
                    .disabled(selection == nil)
                }
                ToolbarItem {
                    Button {
                        FileActions.open(urls: [selection!])
                    } label: {
                        Image(systemName: "archivebox")
                    }
                    .disabled(selection == nil)
                }
                ToolbarItem {
                    Button {
                        try? FileManager.default.removeItem(at: selection!)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(selection == nil)
                }
                ToolbarItem {
                    TextField("Search", text: $filter)
                        .frame(minWidth: 100, idealWidth: 200, maxWidth: .infinity)
                }
            }
    }
}
