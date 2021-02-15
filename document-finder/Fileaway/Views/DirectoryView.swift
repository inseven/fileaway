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

import Interact

struct RightClickableSwiftUIView: NSViewRepresentable {

    var onRightClickFocusChange: (Bool) -> Void

    class Coordinator: NSObject, RightClickObservingViewDelegate {

        var parent: RightClickableSwiftUIView

        init(_ parent: RightClickableSwiftUIView) {
            self.parent = parent
        }

        func rightClickFocusDidChange(focused: Bool) {
            // TODO: Remove repeated entries here? Maybe this could be a publisher?
            print("\(self) rightClickFocusDidChange: \(focused)")
            parent.onRightClickFocusChange(focused)
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> RightClickObservingView {
        let view = RightClickObservingView()
        view.delegate = context.coordinator
        return view
    }

    func updateNSView(_ view: RightClickObservingView, context: NSViewRepresentableContext<RightClickableSwiftUIView>) {
        view.delegate = context.coordinator
    }

}

protocol RightClickObservingViewDelegate: NSObject {

    func rightClickFocusDidChange(focused: Bool)

}

class RightClickObservingView : NSView {

    weak var delegate: RightClickObservingViewDelegate?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        let recognizer = ObservingGestureRecognizer { [weak self] in
            self?.delegate?.rightClickFocusDidChange(focused: true)
        }
        addGestureRecognizer(recognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification),
                                               name: NSNotification.Name(rawValue: "NSMenuDidCompleteInteractionNotification"),
                                               object: nil)
    }

    @objc func didReceiveNotification(_ notification: NSNotification) {
        delegate?.rightClickFocusDidChange(focused: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

struct ContextMenuFocusable<MenuItems>: ViewModifier where MenuItems : View {

    let menuItems: () -> MenuItems
    let onContextMenuChange: (Bool) -> Void

    @State var isShowingContextMenu: Bool = false

    func body(content: Content) -> some View {
        ZStack {
            RightClickableSwiftUIView { showingContextMenu in
                isShowingContextMenu = showingContextMenu
                onContextMenuChange(showingContextMenu)
            }
            content
                .allowsHitTesting(false)
        }
        .contextMenu(menuItems: menuItems)
        .environment(\.hasContextMenuFocus, isShowingContextMenu)
    }

}

// TODO: Consider the naming for this.
struct ContextMenuFocusKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {

    var hasContextMenuFocus: Bool {
        get { self[ContextMenuFocusKey.self] }
        set { self[ContextMenuFocusKey.self] = newValue }
    }

}


extension View {

    func onClick(_ click: @escaping () -> Void, doubleClick: @escaping () -> Void) -> some View {
        return gesture(TapGesture()
                        .onEnded(click)
                        .simultaneously(with: TapGesture(count: 2)
                                            .onEnded(doubleClick)))
    }

    func onShiftClick(_ action: @escaping () -> Void) -> some View {
        return highPriorityGesture(TapGesture(count: 1)
                                    .modifiers(EventModifiers.shift).onEnded(action))
    }

    func onCommandClick(_ action: @escaping () -> Void) -> some View {
        return highPriorityGesture(TapGesture(count: 1)
                                    .modifiers(EventModifiers.command).onEnded(action))
    }

}

struct DirectoryView: View {

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
                            Button("Open") {
                                NSWorkspace.shared.open(file.url)
                            }
                            Divider()
                            Button("Reveal in Finder") {
                                NSWorkspace.shared.activateFileViewerSelecting([file.url])
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
                        } doubleClick: { // TODO: Perhaps there's a better way to do this with environment variables?
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
