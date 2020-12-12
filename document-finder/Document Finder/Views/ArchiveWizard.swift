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
                        PageLink(destination: DetailsPage(task: task)) {
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


class VariableInstance: ObservableObject, Identifiable {

    public var id: UUID { variable.id }

    var variable: Variable

    var name: String { variable.name }

    init(variable: Variable) {
        self.variable = variable
    }

}

class DateInstance: VariableInstance {

    @Published var date: Date

    init(variable: Variable, initialValue: Date) {
        _date = Published(initialValue: initialValue)
        super.init(variable: variable)
    }

}

class StringInstance: VariableInstance {

    @Published var string: String

    init(variable: Variable, initialValue: String) {
        _string = Published(initialValue: initialValue)
        super.init(variable: variable)
    }

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

class TaskInstance: ObservableObject {

    var task: Task
    var variables: [VariableInstance]

    var name: String { task.name }

    init(task: Task) {
        self.task = task
        self.variables = task.configuration.variables.map { $0.instance() }
    }

}

struct VariableDateView: View {

    @StateObject var date: DateInstance

    var body: some View {
        HStack {
            Text(date.name)
            Spacer()
            DatePicker("", selection: $date.date, displayedComponents: [.date])
        }
    }

}

struct DetailsPage: View {

    @StateObject var task: TaskInstance

    @State var date: Date = Date()
    @State var year = "2020"

    init(task: Task) {
        _task = StateObject(wrappedValue: TaskInstance(task: task))
    }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(task.variables) { variable in
                    HStack {
                        if let variable = variable as? DateInstance {
                            VariableDateView(date: variable)
                        } else {
                            Text(variable.name)
                            Spacer()
                            Text("Unsupported")
                        }
                    }
                    .padding()
                }
            }
        }
        .pageTitle(task.name)
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
