//
//  ArchiveWizard.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 09/12/2020.
//

import SwiftUI

import Introspect

extension String: Identifiable {
    public var id: String { self }
}

struct TrackerInput<T>: ViewModifier where T: Hashable {

    var tracker: SelectionTracker<T>

    func body(content: Content) -> some View {
        content
            .onMoveCommand { direction in
                print("tracker = \(tracker), direction = \(direction)")
                switch direction {
                case .up:
                    tracker.handleDirectionUp()
                case .down:
                    tracker.handleDirectionDown()
                default:
                    return
                }
            }
    }

}

struct Highlight<T>: ViewModifier where T: Hashable {

    @ObservedObject var tracker: SelectionTracker<T>
    var item: T

    func body(content: Content) -> some View {
        content
            .background(tracker.isSelected(item: item) ? Color.selectedContentBackgroundColor : Color(NSColor.textBackgroundColor))
            .cornerRadius(6, corners: tracker.corners(for: item))
    }

}

struct TaskPage: View {

    var manager: Manager

    @StateObject var filter: LazyFilter<Task>
    @StateObject var tracker: SelectionTracker<Task>

    @State var isShowingChild: Bool = false
    @State var firstResponder: Bool = true

    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    init(manager: Manager) {
        self.manager = manager

        let filter = Deferred(LazyFilter(items: manager.$tasks, test: { filter, item in
            filter.isEmpty ? true : item.name.localizedCaseInsensitiveContains(filter)
        }, initialSortDescriptor: { lhs, rhs in lhs.name.lexicographicallyPrecedes(rhs.name) }))
        self._filter = StateObject(wrappedValue: filter.get())
        self._tracker = StateObject(wrappedValue: SelectionTracker(items: filter.get().$items))
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $filter.filter)
                    .font(.title)
                    .textFieldStyle(PlainTextFieldStyle())
                if !filter.filter.isEmpty {
                    Button {
                        filter.filter = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(tracker.items) { task in
                        PageLink(isActive: $isShowingChild, destination: DetailsPage()) {
                            HStack {
                                Text(task.name)
                                Spacer()
                                Image(systemName: "chevron.forward")
                            }
                            .padding()
                            .modifier(Highlight(tracker: tracker, item: task))
                        }
                        Divider()
                            .padding(.leading)
                            .padding(.trailing)
                    }
                }
            }
        }
        .padding()
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .modifier(TrackerInput(tracker: tracker))
        .pageTitle("Select Task")
    }

}

struct DonePage: View {

    var body: some View {
        HStack {
            Text("Empty MKII")
        }
        .pageTitle("Empty View")
    }

}

struct DetailsPage: View {

    @State var active: Bool = false

    var body: some View {
        VStack {
            PageLink(isActive: $active, destination: DonePage()) {
                Text("Click me")
            }
            Spacer()
            Text("Empty view")
            Spacer()
        }
        .pageTitle("Details")
        .frame(minWidth: 0, maxWidth: .infinity)
    }

}

struct ArchiveWizard: View {

    @Environment(\.manager) var manager

    @State var url: URL
    var onDismiss: () -> Void

    @State var firstResponder: Bool = true

    var body: some View {
        VStack {
            HStack {
                QuickLookPreview(url: url)
                PageView {
                    TaskPage(manager: manager)
                }
            }
            Button(action: onDismiss) {
                Text("Cancel")
            }
            .padding()
        }
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .padding()
        .frame(minWidth: 800, minHeight: 600, idealHeight: 600)
        .onExitCommand(perform: onDismiss)
    }

}
