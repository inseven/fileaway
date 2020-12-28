//
//  SettingsView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 05/12/2020.
//

import Combine
import SwiftUI

protocol BackChannelable {
    func establishBackChannel()
}

class BackChannel<T> where T: ObservableObject {

    var value: [T] = []
    var publisher: Published<[T]>.Publisher
    var observer: Cancellable?
    var observers: [Cancellable] = []

    init(value: [T], publisher: Published<[T]>.Publisher) {
        self.value = value
        self.publisher = publisher
    }

    func bind(completion: @escaping () -> Void) -> BackChannel<T> {
        observer = publisher.sink { array in
            self.observers = array.map { observable in
                if let backChannelable = observable as? BackChannelable {
                    backChannelable.establishBackChannel()
                }
                return observable.objectWillChange.sink { _ in
                    completion()
                }
            }
        }
        return self
    }

    deinit {
        observer?.cancel()
        for observer in observers {
            observer.cancel()
        }
        observers = []
    }

}

extension Component {

    init(_ state: ComponentState) {
        self.init(type: state.type, value: state.value)
    }

}

class ComponentState: ObservableObject, Identifiable, Hashable {

    var id = UUID() // TODO: Why doesn't this work if it's a let.
    @Published var value: String
    @Published var type: ComponentType
    var variable: VariableState? = nil

    init(value: String, type: ComponentType, variable: VariableState?) {
        self.value = value
        self.type = type
        self.variable = variable
    }

    init(_ component: Component, variable: VariableState?) {
        value = component.value
        type = component.type
        self.variable = variable
    }

    init(_ component: ComponentState, variable: VariableState?) {
        id = component.id
        value = String(component.value)
        type = component.type
        self.variable = variable
    }

    func update() {
        guard let variable = self.variable else {
            return
        }
        self.value = variable.name
    }

    static func == (lhs: ComponentState, rhs: ComponentState) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}


extension Variable {

    init(_ state: VariableState) {
        self.init(name: state.name, type: state.type)
    }

}

class VariableState: ObservableObject, Identifiable, Hashable {

    var id = UUID()
    @Published var name: String
    @Published var type: VariableType

    public init(_ variable: Variable) {
        self.name = variable.name
        self.type = variable.type
    }

    public init(_ variable: VariableState) {
        id = variable.id
        name = String(variable.name)
        type = variable.type
    }

    public init(name: String, type: VariableType) {
        self.name = name
        self.type = type
    }

    static func == (lhs: VariableState, rhs: VariableState) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}


class TaskState: ObservableObject, Identifiable, CustomStringConvertible {

    enum TaskStateNameFormat {
        case long
        case short
    }

    var id = UUID()
    @Published var name: String

    @Published var variables: [VariableState]
    var variablesBackChannel: BackChannel<VariableState>?

    @Published var destination: [ComponentState]
    var destinationBackChannel: BackChannel<ComponentState>?

    var description: String {
        self.name
    }

    func establishBackChannel() {
        variablesBackChannel = BackChannel(value: variables, publisher: $variables).bind {
            self.objectWillChange.send()
            DispatchQueue.main.async {
                for component in self.destination {
                    component.update()
                }
            }
        }
        destinationBackChannel = BackChannel(value: destination, publisher: $destination).bind {
            self.objectWillChange.send()
        }
    }

    init(id: UUID, name: String, variables: [VariableState], destination: [ComponentState]) {
        self.id = id
        self.name = name
        self.variables = variables
        self.destination = destination
        for component in destination {
            guard case .variable = component.type else {
                continue
            }
            let variable = variables.first { $0.name == component.value }
            component.variable = variable
        }
        self.establishBackChannel()
    }

    convenience init(_ task: TaskState) {
        self.init(id: task.id,
                  name: String(task.name),
                  variables: task.variables.map { VariableState($0) },
                  destination: task.destination.map { ComponentState($0, variable: nil) })
    }

    init(task: Task) {
        name = task.name
        let variables = task.configuration.variables.map { VariableState($0) }
        self.variables = variables
        destination = task.configuration.destination.map { component in
            ComponentState(component, variable: variables.first { $0.name == component.value } )
        }
        self.establishBackChannel()
    }

    init(name: String) {
        self.name = name
        self.variables = []
        self.destination = []
    }

    func remove(component: ComponentState) {
        destination.removeAll { $0 == component }
    }

    func moveUp(component: ComponentState) {
        guard let index = destination.firstIndex(of: component),
              index > 0 else {
            return
        }
        destination.swapAt(index, index - 1)
    }

    func moveDown(component: ComponentState) {
        guard let index = destination.firstIndex(of: component),
              index < destination.count - 1 else {
            return
        }
        destination.swapAt(index, index + 1)
    }

    func remove(variable: VariableState) {
        variables.removeAll { $0 == variable }
    }

    func remove(variableOffsets: IndexSet) {
        let remove = variableOffsets.map { variables[$0] }
        for variable in remove {
            destination.removeAll { $0.type == .variable && $0.value == variable.name }
        }
        variables.remove(atOffsets: variableOffsets)
    }

    func name(for component: ComponentState, format: TaskStateNameFormat = .long) -> String {
        switch component.type {
        case .text:
            return component.value
        case .variable:
            guard let variable = (variables.first { $0.name == component.value }) else {
                return "\(component.value) (Missing)"
            }
            switch (variable.type, format) {
            case (.date(hasDay: true), .long):
                return variable.name + " (YYYY-mm-dd)"
            case (.date(hasDay: true), .short):
                return "YYYY-mm-dd"
            case (.date(hasDay: false), .long):
                return variable.name + " (YYYY-mm)"
            case (.date(hasDay: false), .short):
                return "YYYY-mm"
            case (.string, .long), (.string, .short):
                return variable.name
            }
        }
    }

    func validate() -> Bool {
        let names = Set(variables.map { $0.name })
        return names.count == variables.count
    }

    func createVariable() {
        let names = Set(variables.map { $0.name })
        var index = 1
        var name = ""
        repeat {
            name = "Variable \(index)"
            index = index + 1
        } while names.contains(name)
        self.variables.append(VariableState(name: name, type: .string))
    }

}

extension VariableType: Identifiable, Hashable {

    public var id: String {
        switch self {
        case .string:
            return "string"
        case .date(hasDay: false):
            return "date"
        case .date(hasDay: true):
            return "date-day"
        }
    }

    public static func == (lhs: VariableType, rhs: VariableType) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

struct VariableTextField: View {

    @ObservedObject var variable: VariableState
    @State var variableType: VariableType = .string

    var body: some View {
        VStack {
            TextField("Name", text: $variable.name)
            Picker(selection: $variable.type, label: Text("Type")) {
                ForEach(VariableType.allCases, id: \.self) { type in
                    Text(String(describing: type))
                }
            }
            Spacer()
        }
    }

}

struct VariableList: View {

    @ObservedObject var rule: TaskState
    @State var selection: VariableState?

    var body: some View {
        VStack {
            HStack {
                List(rule.variables, id: \.self, selection: $selection) { variable in
                    Text("\(variable.name) (\(String(describing: variable.type)))")
                }
                if let selection = selection {
                    VariableTextField(variable: selection)
                        .id(selection)
                }
            }
            HStack {
                Button {
                    rule.createVariable()
                } label: {
                    Image(systemName: "plus")
                }
                Button {
                    guard let variable = selection else {
                        return
                    }
                    rule.remove(variable: variable)
                    selection = nil
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selection == nil)
                Spacer()
            }

        }
    }

}

struct DestinationList: View {

    @ObservedObject var rule: TaskState
    @State var selection: ComponentState?

    var body: some View {
        VStack {
            HStack {
                List(rule.destination, id: \.self, selection: $selection) { component in
                    Text(component.value)
                }
//                if let selection = selection {
//                    VariableTextField(variable: selection)
//                        .id(selection)
//                }
            }
            HStack {
                ForEach(rule.variables) { variable in
                    Button(action: {
                        rule.destination.append(ComponentState(value: variable.name, type: .variable, variable: variable))
                    }) {
                        Text(String(describing: variable.name))
                    }
                }
                Button {
                    guard let component = selection else {
                        return
                    }
                    rule.remove(component: component)
                    selection = nil
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selection == nil)
                Button {
                    guard let component = selection else {
                        return
                    }
                    rule.moveUp(component: component)
                } label: {
                    Image(systemName: "arrow.up")
                }
                Button {
                    guard let component = selection else {
                        return
                    }
                    rule.moveDown(component: component)
                } label: {
                    Image(systemName: "arrow.down")
                }
                Spacer()
            }

        }
    }

}

struct RuleDetailView: View {

    @ObservedObject var rule: TaskState

    init(rule: Task) {
        _rule = ObservedObject(initialValue: TaskState(task: rule))
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                TextField("Title", text: $rule.name)
                Text("Variables")
                    .font(.headline)
                VariableList(rule: rule)
                Text("Destination")
                    .font(.headline)
                DestinationList(rule: rule)
                Spacer()
            }
            .padding()
        }
    }

}

struct ListButtons: View {

    var add: () -> Void
    var remove: () -> Void

    var body: some View {
        HStack {
            Button(action: add) {
                Image(systemName: "plus")
            }
            Button(action: remove) {
                Image(systemName: "minus")
            }
        }
    }

}

struct RulesSettingsView: View {

    @ObservedObject var rules: Rules
    @State var selection: Task?
    @State var newSelection: Task?

    var body: some View {
        HStack {
            VStack {
                ScrollViewReader { scrollView in
                    List(rules.rules, id: \.self, selection: $selection) { rule in
                        Text(rule.name)
                            .lineLimit(1)
                            .id(rule.id)
                    }
                    HStack {
                        ListButtons {
                            let rule = Task(name: "New rule")
                            do {
                                try rules.add(rule)
                                selection = rule
                                newSelection = rule
//                                let deadlineTime = DispatchTime.now() + .seconds(1)
//                                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//                                    print("test")
//                                    scrollView.scrollTo(selection)
//                                scrollView.scrollTo(rules.rules[0].id)
//                                }
                            } catch {
                                print("Failed to add rule with error \(error).")
                            }
                        } remove: {
                            guard let rule = selection else {
                                return
                            }
                            do {
                                try rules.remove(rule)
                                selection = nil
                            } catch {
                                print("Failed to remove rule with error \(error).")
                            }
                        }
                        Spacer()
                    }
                    .onChange(of: newSelection) { rule in
                        guard let rule = rule else {
                            return
                        }
                        scrollView.scrollTo(rule.id)
                    }
                }
            }
            VStack {
                if let rule = selection {
                    RuleDetailView(rule: rule)
                        .id(rule)
                } else {
                    Text("No Item Selected")
                }
            }
            .padding(.leading)
            .frame(maxWidth: .infinity)
        }
    }

}

struct SettingsView: View {

    private enum Tabs: Hashable {
        case general
    }

    @ObservedObject var manager: Manager

    var body: some View {
        TabView {
            GeneralSettingsView(manager: manager)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            RulesSettingsView(rules: manager.rules!)
                .tabItem {
                    Label("Rules", systemImage: "tray.and.arrow.down")
                }
        }
        .padding()
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 460, maxHeight: .infinity)
    }

}
