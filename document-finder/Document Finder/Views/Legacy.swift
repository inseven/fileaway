//
//  ArchiveWizard.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 09/12/2020.
//

import Combine
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
            .foregroundColor(tracker.isSelected(item: item) ? .white : .primary)
            .background(tracker.isSelected(item: item) ? Color.selectedContentBackgroundColor : Color.clear)
            .cornerRadius(6, corners: tracker.corners(for: item))
        }

}

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


class VariableInstance: Identifiable {

    public var id: UUID { variable.id }

    var variable: Variable

    var name: String { variable.name }

    init(variable: Variable) {
        self.variable = variable
    }

}

protocol TextProvider {
    var textRepresentation: String { get }
}

protocol Observable {
    func observe(_ onChange: @escaping () -> Void) -> AnyCancellable
}

protocol VariableProvider: TextProvider, Observable, ObservableObject {

}

extension Variable {

    func instance() -> VariableInstance {
        switch self.type {
        case .string:
            return StringInstance(variable: self, initialValue: "")
        case .date:
            return DateInstance(variable:self, initialValue: Date())
        }
    }

}

struct VariableDateView: View {

    @ObservedObject var variable: DateInstance

    var body: some View {
        HStack {
            Text(variable.name)
            Spacer()
            DatePicker("", selection: $variable.date, displayedComponents: [.date])
        }
    }

}

struct VariableStringView: View {

    @StateObject var variable: StringInstance
    @State var string: String = ""

    var body: some View {
        HStack {
            Text(variable.name)
            Spacer()
            TextField("", text: $variable.string)
        }
    }

}
