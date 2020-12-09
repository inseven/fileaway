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

struct RectCorner: OptionSet {

    let rawValue: Int

    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)

    static let all: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

struct RoundedCorner: Shape {

    let radius: CGFloat
    let corners: RectCorner

    func path(in rect: CGRect) -> Path {

        let topLeftRadius: CGFloat = corners.contains(.topLeft) ? radius : 0
        let bottomLeftRadius: CGFloat = corners.contains(.bottomLeft) ? radius : 0
        let bottomRightRadius: CGFloat = corners.contains(.bottomRight) ? radius : 0
        let topRightRadius: CGFloat = corners.contains(.topRight) ? radius : 0

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: topLeftRadius))
        path.addLine(to: CGPoint(x: 0, y: rect.height - bottomLeftRadius))
        path.addArc(center: CGPoint(x: bottomLeftRadius, y: rect.height - bottomLeftRadius),
                    radius: bottomLeftRadius,
                    startAngle: CGFloat.pi,
                    endAngle: (CGFloat.pi / 2),
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.width - bottomRightRadius, y: rect.height))
        path.addArc(center: CGPoint(x: rect.width - bottomRightRadius, y: rect.height - bottomRightRadius),
                    radius: bottomRightRadius,
                    startAngle: (CGFloat.pi / 2),
                    endAngle: 0,
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.width, y: topRightRadius))
        path.addArc(center: CGPoint(x: rect.width - topRightRadius, y: topRightRadius),
                    radius: topRightRadius,
                    startAngle: 0,
                    endAngle: (CGFloat.pi / 2) * 3,
                    clockwise: true)
        path.addLine(to: CGPoint(x: topLeftRadius, y: 0))
        path.addArc(center: CGPoint(x: topLeftRadius, y: topLeftRadius),
                    radius: topLeftRadius,
                    startAngle: (CGFloat.pi / 2) * 3,
                    endAngle: CGFloat.pi,
                    clockwise: true)
        path.closeSubpath()
        return Path(path)
    }
}

extension View {

    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
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

    func cornersForItem(item: FileInfo) -> RectCorner {
        var corners = RectCorner()
        if tracker.beginsSelection(item: item) {
            corners.insert(.topLeft)
            corners.insert(.topRight)
        }
        if tracker.endsSelection(item: item) {
            corners.insert(.bottomLeft)
            corners.insert(.bottomRight)
        }
        return corners
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(tracker.items) { file in
                    FileRow(file: file, isSelected: tracker.isSelected(item: file))
                        .background(tracker.isSelected(item: file) ? highlightColor : Color(NSColor.textBackgroundColor))
                        .cornerRadius(6, corners: cornersForItem(item: file))
                        .padding(.leading)
                        .padding(.trailing)
                        .onDrag { NSItemProvider(object: file.url as NSURL) }
                        .gesture(TapGesture().onEnded {
                            print("click")
                            firstResponder = true
                            tracker.select(item: file)
                        }
                        .simultaneously(with: TapGesture(count: 2).onEnded {
                            print("double click")
                            NSWorkspace.shared.open(file.url)
                        }))
                        .highPriorityGesture(TapGesture(count: 1).modifiers(EventModifiers.command).onEnded {
                            print("command click")
                            firstResponder = true
                            tracker.toggle(item: file)
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
