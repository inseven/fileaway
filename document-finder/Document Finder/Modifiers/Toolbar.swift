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
        NSSearchField(frame: .zero)
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
                    SearchField(search: $filter)
                        .frame(minWidth: 100, idealWidth: 200, maxWidth: .infinity)
                }
            }
    }
}
