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

extension View {

    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

}

struct DirectoryView: View {

    @ObservedObject var directoryObserver: DirectoryObserver

    @State var firstResponder: Bool = false

    @StateObject var tracker: SelectionTracker<FileInfo>
    @StateObject var manager: SelectionManager

    init(directoryObserver: DirectoryObserver) {
        self.directoryObserver = directoryObserver
        let tracker = Deferred(SelectionTracker(items: directoryObserver.$searchResults))
        _tracker = StateObject(wrappedValue: tracker.get())
        _manager = StateObject(wrappedValue: SelectionManager(tracker: tracker.get()))
    }

    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    var highlightColor: Color {
        firstResponder ? Color.selectedContentBackgroundColor : Color.unemphasizedSelectedContentBackgroundColor
    }

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(tracker.items) { file in
                        FileRow(file: file, isSelected: tracker.isSelected(item: file))
                            .background(tracker.isSelected(item: file) ? highlightColor : Color(NSColor.textBackgroundColor))
                            .cornerRadius(6, corners: tracker.corners(for: file))
                            .padding(.leading)
                            .padding(.trailing)
                            .onDrag {
                                NSItemProvider(object: file.url as NSURL)
                            }
                            .gesture(TapGesture().onEnded {
                                print("click")
                                firstResponder = true
                                tracker.handleClick(item: file)
                            }
                            .simultaneously(with: TapGesture(count: 2).onEnded {
                                print("double click")
                                NSWorkspace.shared.open(file.url)
                            }))
                            .highPriorityGesture(TapGesture(count: 1).modifiers(EventModifiers.command).onEnded {
                                print("command click")
                                firstResponder = true
                                tracker.handleCommandClick(item: file)
                            })
                            .highPriorityGesture(TapGesture(count: 1).modifiers(EventModifiers.shift).onEnded {
                                print("shift click")
                                firstResponder = true
                                tracker.handleShiftClick(item: file)
                            })
                            .focusable(true) { focus in
                                print("FOCUS = \(focus)")
                            }
                            .contextMenu {
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
                            }
                            .id(file.id)
                    }
                }
                .padding(.top)
            }
            .acceptsFirstResponder(isFirstResponder: $firstResponder)
            .onTapGesture {
                tracker.clear()
                firstResponder = true
            }
            .onKey(.space, perform: manager.preview)
            .onEnterCommand(perform: manager.open)
            .onKey(.upArrow, modifiers: .shift) {
                guard let previous = tracker.handleShiftDirectionUp() else {
                    return
                }
                scrollView.scrollTo(previous.id)
            }
            .onKey(.downArrow, modifiers: .shift) {
                guard let next = tracker.handleShiftDirectionDown() else {
                    return
                }
                scrollView.scrollTo(next.id)
            }
            .onKey("a", modifiers: .command, perform: tracker.selectAll)
            .onMoveCommand { direction in
                switch direction {
                case .up:
                    guard let previous = tracker.handleDirectionUp() else {
                        return
                    }
                    scrollView.scrollTo(previous.id)
                case .down:
                    guard let next = tracker.handleDirectionDown() else {
                        return
                    }
                    scrollView.scrollTo(next.id)
                    print(next.name)
                default:
                    return
                }
            }
            .onCutCommand(perform: manager.cut)
        }
        .background(Color(NSColor.textBackgroundColor))
        .modifier(Toolbar(manager: manager, filter: directoryObserver.filter))
        .navigationTitle(directoryObserver.name)
    }

}
