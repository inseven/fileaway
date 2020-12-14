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
            .background(tracker.isSelected(item: item) ? Color.selectedContentBackgroundColor : Color.clear)
            .cornerRadius(6, corners: tracker.corners(for: item))
        }

}

struct TaskPage: View {

    var manager: Manager
    var url: URL

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

class DateInstance: VariableInstance, ObservableObject, Observable, TextProvider {

    @Published var date: Date

    var textRepresentation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    init(variable: Variable, initialValue: Date) {
        _date = Published(initialValue: initialValue)
        super.init(variable: variable)
    }

    func observe(_ onChange: @escaping () -> Void) -> AnyCancellable {
        self.objectWillChange.sink(receiveValue: onChange)
    }

}

class StringInstance: VariableInstance, ObservableObject, Observable, TextProvider {

    var textRepresentation: String {
        return string
    }

    @Published var string: String

    init(variable: Variable, initialValue: String) {
        _string = Published(initialValue: initialValue)
        super.init(variable: variable)
    }

    func observe(_ onChange: @escaping () -> Void) -> AnyCancellable {
        self.objectWillChange.sink(receiveValue: onChange)
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

struct DetailsPage: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.manager) var manager

    var url: URL
    @StateObject var task: TaskInstance

    @State var date: Date = Date()
    @State var year = "2020"

    init(url: URL, rootUrl: URL, task: Task) {
        self.url = url
        _task = StateObject(wrappedValue: TaskInstance(url: rootUrl, task: task))
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(task.variables) { variable in
                        HStack {
                            if let variable = variable as? DateInstance {
                                VariableDateView(variable: variable)
                            } else if let variable = variable as? StringInstance {
                                VariableStringView(variable: variable)
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
            Text(task.destinationUrl.path)
                .lineLimit(1)
                .truncationMode(.head)
                .help(task.destinationUrl.path)
            Button {
                print("moving to \(task.destinationUrl)...")
                do {
                    try task.move(url: url)
                } catch {
                    print("Failed to move file with error \(error)")
                }

                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Move")
            }
        }
        .pageTitle(task.name)
        .frame(minWidth: 0, maxWidth: .infinity)
    }

}

struct ArchiveWizardContainer: View {

    @State var url: URL?

    var body: some View {
        HStack {
            if let url = url {
                ArchiveWizard(url: url)
            } else {
                Text("No File Selected")
            }
        }
        .onOpenURL { url in
            self.url = URL(fileURLWithPath: url.path)
        }
        .frame(minWidth: 800, minHeight: 600, idealHeight: 600)
    }

}

struct ArchiveWizard: View {

    @Environment(\.manager) var manager

    @State var url: URL

    @State var firstResponder: Bool = true

    var body: some View {
        VStack {
            HStack {
                QuickLookPreview(url: url)
                PageView {
                    TaskPage(manager: manager, url: url)
                }
            }
        }
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .padding()
        .frame(minWidth: 800, minHeight: 600, idealHeight: 600)
//        .onExitCommand(perform: onDismiss)
    }

}
