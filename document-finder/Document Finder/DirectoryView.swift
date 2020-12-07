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

struct DirectoryView: View {

    @ObservedObject var directoryObserver: DirectoryObserver

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
                        .background(tracker.isSelected(item: file) ? Color.accentColor.cornerRadius(6).eraseToAnyView() : Color(NSColor.textBackgroundColor).eraseToAnyView())
                        .padding(.leading)
                        .padding(.trailing)
                        .onDrag { NSItemProvider(object: file.url as NSURL) }
                        .gesture(TapGesture().onEnded {
                            print("click")
                            firstResponder = true
                            tracker.select(item: file)
                        }
                        .simultaneously(with: TapGesture(count: 2).onEnded {
                            NSWorkspace.shared.open(file.url)
                        }))
                        .highPriorityGesture(TapGesture(count: 1).modifiers(EventModifiers.command).onEnded {
                            print("command click")
                            firstResponder = true
                            tracker.add(item: file)
                        })
                        .highPriorityGesture(TapGesture(count: 1).modifiers(EventModifiers.shift).onEnded {
                            print("shift click")
                            firstResponder = true
                            try? tracker.extend(to: file)
                        })
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
        .modifier(Toolbar(manager: manager, filter: directoryObserver.filter))
        .navigationTitle(directoryObserver.name)
    }

}
