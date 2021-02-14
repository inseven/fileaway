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

class ObservingGestureRecognizer: NSGestureRecognizer {

    var onRightMouseDown: (() -> Void)?

    init(onRightMouseDown: @escaping () -> Void) {
        super.init(target: nil, action: nil)
        self.onRightMouseDown = onRightMouseDown
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func rightMouseDown(with event: NSEvent) {
        print("rightMouseDown")
        defer { self.state = .failed }
        guard let view = view else {
            return
        }
        let mouseLocation = view.convert(event.locationInWindow, from: nil)
        guard view.bounds.contains(mouseLocation) else {
            return
        }
        if let onRightMouseDown = onRightMouseDown {
            onRightMouseDown()
        }
        super.rightMouseDown(with: event)
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

extension View {
    func trackingMouse(onContextMenuFocusChange: @escaping (Bool) -> Void) -> some View {
        TrackinAreaView(onContextMenuFocusChange: onContextMenuFocusChange) { self }
    }
}

struct TrackinAreaView<Content>: View where Content : View {
    let onContextMenuFocusChange: (Bool) -> Void
    let content: () -> Content

    init(onContextMenuFocusChange: @escaping (Bool) -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.onContextMenuFocusChange = onContextMenuFocusChange
        self.content = content
    }

    var body: some View {
        TrackingAreaRepresentable(onContextMenuFocusChange: onContextMenuFocusChange, content: self.content())
    }
}

struct TrackingAreaRepresentable<Content>: NSViewRepresentable where Content: View {
    let onContextMenuFocusChange: (Bool) -> Void
    let content: Content

    func makeNSView(context: Context) -> NSHostingView<Content> {
        return TrackingNSHostingView(onContextMenuFocusChange: onContextMenuFocusChange, rootView: self.content)
    }

    func updateNSView(_ nsView: NSHostingView<Content>, context: Context) {
    }
}

class TrackingNSHostingView<Content>: NSHostingView<Content> where Content : View {
    let onContextMenuFocusChange: (Bool) -> Void

    init(onContextMenuFocusChange: @escaping (Bool) -> Void, rootView: Content) {
        self.onContextMenuFocusChange = onContextMenuFocusChange
        super.init(rootView: rootView)
//        let recognizer = ObservingGestureRecognizer { [weak self] in
//            self?.onContextMenuFocusChange(true)
//        }
//        addGestureRecognizer(recognizer)
//        NotificationCenter.default.addObserver(self, selector: #selector(menuDidComplete),
//                                               name: NSNotification.Name(rawValue: "NSMenuDidCompleteInteractionNotification"),
//                                               object: nil)
    }

//    @objc func menuDidComplete(_ notification: NSNotification) {
//        onContextMenuFocusChange(false)
//    }

    required init(rootView: Content) {
        fatalError("init(rootView:) has not been implemented")
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//
//    override func hitTest(_ point: NSPoint) -> NSView? {
//        return self
//    }

}

struct Selectable<Content: View>: View {

    var isFocused: Bool  // TODO: Environment variable?
    var isSelected: Bool
    var radius: CGFloat
    var corners: RectCorner
    private let content: () -> Content
    @Environment(\.hasContextMenuFocus) var hasContextMenuFocus

    var borderWidth: CGFloat { isSelected ? 2 : 3 }
    var borderColor: Color { isSelected ? Color.white : highlightColor }
    var borderPadding: CGFloat { isSelected ? 2 : 0 }
    var borderRadius: CGFloat { radius + (borderWidth / 2) - borderPadding }
    var highlightColor: Color { isFocused ? Color.selectedContentBackgroundColor : Color.unemphasizedSelectedContentBackgroundColor }
    var activeCorners: RectCorner { isSelected ? corners : RectCorner.all }

    init(isFocused: Bool, isSelected: Bool, radius: CGFloat, corners: RectCorner, @ViewBuilder _ content: @escaping () -> Content) {
        self.isFocused = isFocused
        self.isSelected = isSelected
        self.radius = radius
        self.corners = corners
        self.content = content
    }

    var body: some View {
        ZStack {
            if isSelected { highlightColor
            }
            content()
            if hasContextMenuFocus {
                RoundedRectangle(cornerRadius: borderRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
                    .padding(borderPadding)
            }
        }
        .cornerRadius(radius, corners: activeCorners)
        .contentShape(Rectangle())
        .onChange(of: hasContextMenuFocus) { hasContextMenuFocus in
            print("focus = \(hasContextMenuFocus)")
        }
    }
}


struct ContextMenuFocusable<MenuItems>: ViewModifier where MenuItems : View {

    let menuItems: () -> MenuItems
    let onContextMenuChange: (Bool) -> Void

    @State var isShowingContextMenu: Bool = false

    func body(content: Content) -> some View {
        ZStack {
            RightClickableSwiftUIView { isShowingContextMenu = $0 }
            content
                .allowsHitTesting(false)
        }
//        .trackingMouse { isShowingContextMenu = $0 }
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

    func contextMenuTrackingFocus<MenuItems>(@ViewBuilder menuItems: @escaping () -> MenuItems, onContextMenuChange: @escaping (Bool) -> Void) -> some View where MenuItems : View {
        return self
            .modifier(ContextMenuFocusable(menuItems: menuItems, onContextMenuChange: onContextMenuChange))
    }

    func contextMenuTrackingFocus<MenuItems>(@ViewBuilder menuItems: @escaping () -> MenuItems) -> some View where MenuItems : View {
        return self.contextMenuTrackingFocus(menuItems: menuItems) { _ in }
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
                        .contextMenuTrackingFocus {
                            Button("Open") {
                                NSWorkspace.shared.open(file.url)
                            }
                            Divider()
                            Button("Reveal in Finder") {
                                NSWorkspace.shared.activateFileViewerSelecting([file.url])
                            }
                        }
                        .onDrag {
                            NSItemProvider(object: file.url as NSURL)
                        }
                        .onClick {
                            firstResponder = true
                            tracker.handleClick(item: file)
                        } doubleClick: { // TODO: Perhaps there's a better way to do this with environment variables?
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
                        .padding(.leading)
                        .padding(.trailing)

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
