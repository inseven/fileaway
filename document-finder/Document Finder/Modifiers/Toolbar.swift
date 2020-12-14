//
//  Toolbar.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 03/12/2020.
//

import SwiftUI

struct Toolbar: ViewModifier {

    enum SheetType {
        case wizard(url: URL)
    }

    @ObservedObject var manager: SelectionManager
    @Binding var filter: String
    @State var sheetType: SheetType?

    func sheet(sheetType: SheetType) -> some View {
        switch sheetType {
        case .wizard(let url):
            return ArchiveWizard(url: url) {
                self.sheetType = nil
            }
        }
    }

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
                        sheetType = .wizard(url: file.url)
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
            .sheet(item: $sheetType, onDismiss: {
                sheetType = nil
            }, content: sheet)
    }
}

extension Toolbar.SheetType: Identifiable {
    public var id: String {
        switch self {
        case .wizard(let url):
            return "wizard-\(url)"
        }
    }
}
