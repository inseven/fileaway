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

struct TaskPage: View {

    var manager: Manager

    @StateObject var filter: LazyFilter<Task>

    @State var isShowingChild: Bool = false
    @State var firstResponder: Bool = true

    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    init(manager: Manager) {
        self.manager = manager
        self._filter = StateObject(wrappedValue: LazyFilter(items: manager.$tasks, test: { filter, item in
            filter.isEmpty ? true : item.name.localizedCaseInsensitiveContains(filter)
        }, initialSortDescriptor: { lhs, rhs in return true }))
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
                    ForEach(filter.items) { task in
                        PageLink(isActive: $isShowingChild, destination: DetailsPage()) {
                            HStack {
                                Text(task.name)
                                Spacer()
                                Image(systemName: "chevron.forward")
                            }
                            .padding()
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
        .onMoveCommand { direction in
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
