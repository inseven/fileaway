//
//  DirectoryView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 02/12/2020.
//

import AppKit
import Combine
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

enum SelectionTrackerError: Error {
    case outOfRange
}

class SelectionTracker<T>: ObservableObject where T: Hashable {

    var publisher: Published<[T]>.Publisher
    var subscription: Cancellable? = nil

    @Published var items: [T] = []
    @Published var selection: Set<T> = []

    init(items: Published<[T]>.Publisher) {
        publisher = items
        subscription = publisher.assign(to: \.items, on: self)
    }

    func clear() {
        selection.removeAll()
    }

    func select(item: T) {
        selection.removeAll()
        selection.insert(item)
    }

    func isSelected(item: T) -> Bool {
        return selection.contains(item)
    }

    func index(of item: T) -> Int? {
        items.firstIndex { $0 == item }
    }

    var indexes: [Int] {
        selection.compactMap { item in index(of: item) }
    }

    func next() throws {
        var index = self.indexes.last ?? -1
        index += 1
        if index >= items.count {
            throw SelectionTrackerError.outOfRange
        }
        select(item: items[index])
    }

    func previous() throws {
        var index = self.indexes.first ?? items.count
        index -= 1
        if index < 0 || items.count < 1 {
            throw SelectionTrackerError.outOfRange
        }
        select(item: items[index])
    }

}

class SelectionManager: ObservableObject {

    var tracker: SelectionTracker<FileInfo>
    var cancellable: AnyCancellable? = nil

    init(tracker: SelectionTracker<FileInfo>) {
        self.tracker = tracker
        cancellable = tracker.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    var urls: [URL] {
        tracker.selection.map { $0.url }
    }

    var canPreview: Bool { !tracker.selection.isEmpty }

    var canArchive: Bool { !tracker.selection.isEmpty }

    func archive() {
        FileActions.open(urls: urls)
    }

    var canCut: Bool { !tracker.selection.isEmpty }

    func cut() -> [NSItemProvider] {
        urls.map { NSItemProvider(object: $0 as NSURL) }
    }

    var canTrash: Bool { !tracker.selection.isEmpty }

    func trash() throws {
        try urls.forEach { try FileManager.default.trashItem(at: $0, resultingItemURL: nil) }
    }

}

struct DirectoryView: View {

    @ObservedObject var directoryObserver: DirectoryObserver

    let qlCoordinator = QLCoordinator()

    @State var firstResponder: Bool = false

    @StateObject var tracker: SelectionTracker<FileInfo>
    @State var manager: SelectionManager

    init(directoryObserver: DirectoryObserver) {
        self.directoryObserver = directoryObserver
        let tracker = SelectionTracker(items: directoryObserver.$searchResults)
        _tracker = StateObject(wrappedValue: tracker)
        _manager = State(initialValue: SelectionManager(tracker: tracker))
    }

    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(tracker.items) { file in
                    FileRow(file: file, isSelected: tracker.isSelected(item: file))
                        .onDrag { NSItemProvider(object: file.url as NSURL) }
                        .gesture(
                            TapGesture().onEnded {
                                firstResponder = true
                                tracker.select(item: file)
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
        .background(Color(NSColor.textBackgroundColor))
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .onTapGesture {
            tracker.clear()
            firstResponder = true
        }
        .onMoveCommand { direction in
            switch direction {
            case .up:
                try? tracker.previous()
            case .down:
                try? tracker.next()
            default:
                return
            }
        }
        .onCutCommand(perform: manager.cut)
        .modifier(Toolbar(manager: manager, filter: directoryObserver.filter, qlCoordinator: qlCoordinator))
        .navigationTitle(directoryObserver.name)
    }

}
