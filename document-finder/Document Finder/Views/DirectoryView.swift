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

extension NSEvent.ModifierFlags {

    var summary: String {

        var names: [String] = []

        for modifierFlag: NSEvent.ModifierFlags in [.shift, .command, .option, .function, .capsLock, .control, .numericPad, .help] {
            guard contains(modifierFlag) else { continue }
            switch modifierFlag {
            case .shift:
                names.append("shift")
            case .command:
                names.append("command")
            case .option:
                names.append("option")
            case .function:
                names.append("function")
            case .capsLock:
                names.append("caps lock")
            case .control:
                names.append("control")
            case .numericPad:
                names.append("numeric pad")
            case .help:
                names.append("help")
            default:
                print("ignoring modifier \(modifierFlag)")
            }
        }
        return names.joined(separator: ", ")

    }

}

extension EventModifiers {

    var modifierFlags: NSEvent.ModifierFlags {
        var modifierFlags = NSEvent.ModifierFlags()
        for eventModifier in Array(arrayLiteral: self) {
            switch eventModifier {
            case .capsLock:
                modifierFlags.insert(.capsLock)
            case .shift:
                modifierFlags.insert(.shift)
            case .control:
                modifierFlags.insert(.control)
            case .option:
                modifierFlags.insert(.option)
            case .command:
                modifierFlags.insert(.command)
            case .numericPad:
                modifierFlags.insert(.numericPad)
            case .function:
                modifierFlags.insert(.function)
            default:
                print("ignoring modifier \(eventModifier)")
            }
        }
        return modifierFlags
    }

}

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

    var highlightColor: Color {
        firstResponder ? Color.selectedContentBackgroundColor : Color.unemphasizedSelectedContentBackgroundColor
    }

    var body: some View {
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
            .padding(.top)
        }
        .background(Color(NSColor.textBackgroundColor))
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .onTapGesture {
            tracker.clear()
            firstResponder = true
        }
        .onSelectCommand {
            guard let selection = tracker.selection.first else {
                return
            }
            QuickLookCoordinator.shared.show(url: selection.url)
        }
        .onEnterCommand {
            manager.open()
        }
        .onKey(.upArrow, modifiers: .shift, perform: tracker.handleShiftDirectionUp)
        .onKey(.downArrow, modifiers: .shift, perform: tracker.handleShiftDirectionDown)
        .onKey("a", modifiers: .command) {
            print("select all")
            tracker.selectAll()
        }
        .onMoveCommand { direction in
            switch direction {
            case .up:
                tracker.handleDirectionUp()
            case .down:
                tracker.handleDirectionDown()
            default:
                return
            }
        }
        .onCutCommand(perform: manager.cut)
        .modifier(Toolbar(manager: manager, filter: directoryObserver.filter))
        .navigationTitle(directoryObserver.name)
    }

}
