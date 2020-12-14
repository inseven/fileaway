//
//  TaskPage.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import SwiftUI

struct TaskPage: View {

    var manager: Manager
    var url: URL

    @Environment(\.close) var close

    @StateObject var filter: LazyFilter<Task>
    @StateObject var tracker: SelectionTracker<Task>

    @State var firstResponder: Bool = true

    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    init(manager: Manager, url: URL) {
        self.manager = manager
        self.url = url
        let filter = Deferred(LazyFilter(items: manager.$tasks, test: { filter, item in
            item.name.localizedSearchMatches(string: filter)
        }, initialSortDescriptor: { lhs, rhs in lhs.name.lexicographicallyPrecedes(rhs.name) }))
        self._filter = StateObject(wrappedValue: filter.get())
        self._tracker = StateObject(wrappedValue: SelectionTracker(items: filter.get().$items))
    }

    // TODO: Move this into the manager.
    var rootUrl: URL {
        (try? manager.settings.archiveUrl())!
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
                        PageLink(destination: DetailsPage(url: url, rootUrl: rootUrl, task: task)) {
                            HStack {
                                Text(task.name)
                                Spacer()
                                Image(systemName: "chevron.forward")
                            }
                            .padding()
                            .contentShape(Rectangle())
                            .modifier(Highlight(tracker: tracker, item: task))
                        }
                        Divider()
                            .padding(.leading)
                            .padding(.trailing)
                    }
                }
            }
            Button {
                close()
            } label: {
                Text("Close")
            }
        }
        .padding()
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .modifier(TrackerInput(tracker: tracker))
        .pageTitle("Select Task")
    }

}
