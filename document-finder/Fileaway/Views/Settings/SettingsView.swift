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
