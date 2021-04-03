//
//  Toolbar.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 03/12/2020.
//

import SwiftUI

struct Toolbar: ViewModifier {

    @Environment(\.openURL) var openURL

    @ObservedObject var manager: SelectionManager
    @Binding var filter: String

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Button {
                        guard let file = manager.tracker.selection.first else {
                            return
                        }
                        QuickLookCoordinator.shared.show(url: file.url)
                    } label: {
                        Image(systemName: "eye")
                    }
                    .disabled(!manager.canPreview)
                }
                ToolbarItem {
                    Button {
                        guard let file = manager.tracker.selection.first else {
                            return
                        }
                        var components = URLComponents()
                        components.scheme = "fileaway"
                        components.path = file.url.path
                        guard let url = components.url else {
                            return
                        }
                        openURL(url)
                    } label: {
                        Image(systemName: "archivebox")
                    }
                    .keyboardShortcut(KeyboardShortcut(.return, modifiers: .command))
                }
                ToolbarItem {
                    Button {
                        try? manager.trash()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(!manager.canTrash)
                }
                ToolbarItem {
                    SearchField(search: $filter)
                        .frame(minWidth: 100, idealWidth: 200, maxWidth: .infinity)
                }
            }
    }
}
