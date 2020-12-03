//
//  DirectoryView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 02/12/2020.
//

import AppKit
import Quartz
import SwiftUI


func loadPreviewItem(with name: String) -> NSURL {

    let file = name.components(separatedBy: ".")
    let path = Bundle.main.path(forResource: file.first!, ofType: file.last!)
    let url = NSURL(fileURLWithPath: path!)

    return url
}

struct MyPreview: NSViewRepresentable {
    var fileName: String

    func makeNSView(context: NSViewRepresentableContext<MyPreview>) -> QLPreviewView {
        let preview = QLPreviewView(frame: .zero, style: .normal)
        preview?.autostarts = true
        preview?.previewItem = loadPreviewItem(with: fileName) as QLPreviewItem
        return preview ?? QLPreviewView()
    }

    func updateNSView(_ nsView: QLPreviewView, context: NSViewRepresentableContext<MyPreview>) {
    }

    typealias NSViewType = QLPreviewView

}

class QLCoordinator: NSObject, QLPreviewPanelDataSource {

    var url: URL?

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return url! as QLPreviewItem
    }

    func numberOfPreviewItems(in controller: QLPreviewPanel) -> Int {
        return 1
    }

    func set(path: URL) {
        self.url = path
    }
}

class FileActions {

    static func open(urls: [URL]) {
        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open(urls,
                                withApplicationAt: URL(fileURLWithPath: "/Applications/File Actions.app"),
                                configuration: configuration) { (application, error) in
            if let error = error {
                print(error)
            }
        }
    }

    static func open() {
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: "/Applications/File Actions.app"),
                                           configuration: NSWorkspace.OpenConfiguration()) { (application, error) in
            if let error = error {
                print(error)
            }
        }
    }

    static func openiOS() {
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: "/Applications/File Actions for iOS.app"),
                                           configuration: NSWorkspace.OpenConfiguration()) { (application, error) in
            if let error = error {
                print(error)
            }
        }
    }

}

struct DirectoryView: View {

    @ObservedObject var directoryObserver: DirectoryObserver
    @State var selectKeeper = Set<URL>()
    let qlCoordinator = QLCoordinator()

    var body: some View {
        List(directoryObserver.searchResults, selection: $selectKeeper) { file in
            Text(file.lastPathComponent)
                .gesture(
                    TapGesture().onEnded {
                        selectKeeper = [file]
                    }
                    .simultaneously(with: TapGesture(count: 2).onEnded {
                        NSWorkspace.shared.open(file)
                    }))
                .contextMenu(ContextMenu(menuItems: {
                    Button("Open") {
                        NSWorkspace.shared.open(file)
                    }
                    Button("Open with File Actions") {
                        FileActions.open(urls: Array(selectKeeper))
                    }
                    Divider()
                    Button("Reveal in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting([file])
                    }
                }))
        }
        .toolbar {
            ToolbarItem {
                Button {
                    print("Preview")
                    let panel = QLPreviewPanel.shared()
                    qlCoordinator.set(path: selectKeeper.first!)
                    panel?.center()
                    panel?.dataSource = self.qlCoordinator
                    panel?.makeKeyAndOrderFront(nil)
                } label: {
                    Image(systemName: "eye")
                }
                .disabled(selectKeeper.count != 1)
            }
            ToolbarItem {
                Button {
                    FileActions.open(urls: Array(selectKeeper))
                } label: {
                    Image(systemName: "archivebox")
                }
                .disabled(selectKeeper.count != 1)
            }
            ToolbarItem {
                TextField("Search", text: directoryObserver.filter)
                    .frame(minWidth: 100, idealWidth: 200, maxWidth: .infinity)
            }
        }
        .navigationTitle(directoryObserver.name)
    }

}
