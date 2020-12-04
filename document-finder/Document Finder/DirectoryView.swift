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

struct FileRow: View {

    var file: FileInfo
    var isSelected: Bool

    var body: some View {
        VStack {
            HStack {
                Text(file.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                Spacer()
                if let date = file.date {
                    DateView(date: date)
                        .foregroundColor(isSelected ? .white : .secondary)
                }
            }
            HStack {
                Text(file.url.lastPathComponent)
                    .foregroundColor(isSelected ? .white : .secondary)
                    .font(.subheadline)
                Spacer()
            }
        }
        .padding(.leading)
        .padding(.trailing)
        .padding(6)
        .background(isSelected ? Color.accentColor.cornerRadius(6).eraseToAnyView() : Color(NSColor.textBackgroundColor).eraseToAnyView())
        .padding(.leading)
        .padding(.trailing)
    }

}

struct DirectoryView: View {

    @ObservedObject var directoryObserver: DirectoryObserver
    let qlCoordinator = QLCoordinator()

    @State var selection: URL?

    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(directoryObserver.searchResults) { file in
                    FileRow(file: file, isSelected: file.url == selection)
                    .gesture(
                        TapGesture().onEnded {
                            selection = file.url
                        }
                        .simultaneously(with: TapGesture(count: 2).onEnded {
                            NSWorkspace.shared.open(file.url)
                        }))
                    .contextMenu(ContextMenu(menuItems: {
                        Button("Open") {
                            NSWorkspace.shared.open(file.url)
                        }
                        Button("Open with File Actions") {
                            FileActions.open(urls: [file.url])
                        }
                        Divider()
                        Button("Reveal in Finder") {
                            NSWorkspace.shared.activateFileViewerSelecting([file.url])
                        }
                    }))
                }
            }

        }
        .onTapGesture {
            selection = nil
        }
        .background(Color(NSColor.textBackgroundColor))
        .modifier(Toolbar(selection: selection, filter: directoryObserver.filter, qlCoordinator: qlCoordinator))
        .navigationTitle(directoryObserver.name)
    }

}
