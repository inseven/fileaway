// Copyright (c) 2018-2021 InSeven Limited
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import AppKit
import Combine
import Quartz
import SwiftUI

import FileawayCore
import Interact

struct DirectoryView: View {

    @Environment(\.openURL) var openURL

    @State var backgroundColor: Color = .clear
    @ObservedObject var directoryObserver: DirectoryObserver

    @State var firstResponder: Bool = false

    @StateObject var tracker: SelectionTracker<FileInfo>  // TODO: Could the selection tracker take a binding to a set to expose a simple API?
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

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(tracker.items) { file in
                        Selectable(isFocused: firstResponder, isSelected: tracker.isSelected(item: file), radius: 6, corners: tracker.corners(for: file)) {
                            FileRow(file: file, isSelected: tracker.isSelected(item: file))
                        }
                        .contextMenuFocusable {
                            Button("Rules Wizard") {
                                var components = URLComponents()
                                components.scheme = "fileaway"
                                components.path = file.url.path
                                guard let url = components.url else {
                                    return
                                }
                                openURL(url)
                            }
                            Divider()
                            Button("Open") {
                                NSWorkspace.shared.open(file.url)
                            }
                            Button("Reveal in Finder") {
                                NSWorkspace.shared.activateFileViewerSelecting([file.url])
                            }
                            Divider()
                            Button("Quick Look") {
                                QuickLookCoordinator.shared.show(url: file.url)
                            }
                            Divider()
                            Button("Copy name") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(file.name, forType: .string)
                            }
                        } onContextMenuChange: { focused in
                            guard focused else {
                                return
                            }
                            firstResponder = true
                        }
                        .onDrag {
                            NSItemProvider(object: file.url as NSURL)
                        }
                        .onClick {
                            firstResponder = true
                            tracker.handleClick(item: file)
                        } doubleClick: {
                            firstResponder = true
                            NSWorkspace.shared.open(file.url)
                        }
                        .onCommandClick {
                            firstResponder = true  // TODO: Do this with a globally observing view / gesture recognizer?
                            tracker.handleCommandClick(item: file)
                        }
                        .onShiftClick {
                            firstResponder = true
                            tracker.handleShiftClick(item: file)
                        }
                        Divider()
                            .padding(.leading)
                            .padding(.trailing)
                    }
                }
                .padding(.top)
                .padding(.leading)
                .padding(.trailing)
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
            .onKey(.downArrow, modifiers: .command, perform: manager.open)
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
                default:
                    return
                }
            }
            .onCutCommand(perform: manager.cut)
        }
        .background(Color.textBackgroundColor)
        .modifier(Toolbar(manager: manager, filter: directoryObserver.filter))
        .navigationTitle(directoryObserver.name)
    }

}
