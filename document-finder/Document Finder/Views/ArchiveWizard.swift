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

//class Tasks: ObservableObject {
//
//    @Published var items = [
//        "1Password Invoice",
//        "Adobe Illustrator Subscription",
//        "Amazon Web Services Invoice",
//        "Apple Card Statement",
//        "Bank Statement",
//        "Phone Bill",
//    ]
//
//}

// TODO: High level filtered list?

struct TaskPage: View {

    @Environment(\.manager) var manager
    @State var isShowingChild: Bool = false

//    @ObservedObject var tasks = Tasks()

    @State var firstResponder: Bool = true
    @State var filter: String = ""
//    @StateObject var tracker: SelectionTracker<String>

    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    init() {
//        let tasks = Tasks()
//        let tracker = SelectionTracker(items: tasks.$items)
//        self.tasks = tasks
//        _tracker = StateObject(wrappedValue: tracker)
    }


    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $filter)
                    .font(.title)
                    .textFieldStyle(PlainTextFieldStyle())
                if !filter.isEmpty {
                    Button {
                        filter = ""
//                        tracker.clear()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            ScrollView {
                if let rules = manager.rules.first {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(rules.tasks) { task in
                            PageLink(isActive: $isShowingChild, destination: DetailsPage()) {
                                HStack {
                                    Text(task.name)
                                    Spacer()
                                    Image(systemName: "chevron.forward")
                                }
                                .padding()
//                                .background(tracker.isSelected(item: task) ? Color.selectedControlColor : Color(NSColor.textBackgroundColor))
//                                .cornerRadius(6, corners: tracker.corners(for: task))
                            }
                            Divider()
                                .padding(.leading)
                                .padding(.trailing)
                        }
                    }
                } else {
                    EmptyView()
                }
            }
        }
        .padding()
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .onMoveCommand { direction in
        }
        .onChange(of: filter) { filter in
            print("filter = \(filter)")
            guard !filter.isEmpty else {
                return
            }
//            try? tracker.selectFirst()
        }
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

    @State var url: URL
    var onDismiss: () -> Void

    @State var firstResponder: Bool = true

    var body: some View {
        VStack {
            HStack {
                QuickLookPreview(url: url)
                PageView {
                    TaskPage()
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
