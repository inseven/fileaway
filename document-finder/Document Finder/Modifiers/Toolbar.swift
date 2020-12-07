//
//  Toolbar.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 03/12/2020.
//

import Quartz
import SwiftUI

struct SearchField: NSViewRepresentable {

    class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: SearchField

        init(_ parent: SearchField) {
            self.parent = parent
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let searchField = notification.object as? NSSearchField else {
                print("Unexpected control in update notification")
                return
            }
            self.parent.search = searchField.stringValue
        }

    }

    @Binding var search: String

    func makeNSView(context: Context) -> NSSearchField {
        return NSSearchField(frame: .zero)
    }

    func updateNSView(_ searchField: NSSearchField, context: Context) {
        searchField.stringValue = search
        searchField.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

}

struct Toolbar: ViewModifier {

    @ObservedObject var manager: SelectionManager
    @Binding var filter: String

    let qlCoordinator: QLCoordinator

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Button {
                        guard let file = manager.tracker.selection.first else {
                            return
                        }
                        print("Preview")
                        let panel = QLPreviewPanel.shared()
                        qlCoordinator.set(path: file.url)
                        panel?.center()
                        panel?.dataSource = self.qlCoordinator
                        panel?.makeKeyAndOrderFront(nil)
                    } label: {
                        Image(systemName: "eye")
                    }
                    .disabled(!manager.canPreview)
                }
                ToolbarItem {
                    Button {
                        manager.archive()
                    } label: {
                        Image(systemName: "archivebox")
                    }
                    .disabled(!manager.canArchive)
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
