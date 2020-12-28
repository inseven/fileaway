//
//  RuleState.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import SwiftUI

class RuleState: ObservableObject, Identifiable, CustomStringConvertible, Hashable {

    enum NameFormat {
        case long
        case short
    }

    var id = UUID()
    let rootUrl: URL
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

    init(id: UUID, rootUrl: URL, name: String, variables: [VariableState], destination: [ComponentState]) {
        self.id = id
        self.rootUrl = rootUrl
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

    convenience init(_ rule: RuleState, rootUrl: URL) {
        self.init(id: rule.id,
                  rootUrl: rootUrl,
                  name: String(rule.name),
                  variables: rule.variables.map { VariableState($0) },
                  destination: rule.destination.map { ComponentState($0, variable: nil) })
    }

    init(_ rule: Rule, rootUrl: URL) {
        name = rule.name
        let variables = rule.configuration.variables.map { VariableState($0) }
        self.variables = variables
        destination = rule.configuration.destination.map { component in
            ComponentState(component, variable: variables.first { $0.name == component.value } )
        }
        self.rootUrl = rootUrl
        self.establishBackChannel()
    }

    // TODO: Check if this is used
    init(rootUrl: URL, name: String) {
        self.rootUrl = rootUrl
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

    func name(for component: ComponentState, format: NameFormat = .long) -> String {
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

    static func == (lhs: RuleState, rhs: RuleState) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

extension Rule {

    convenience init(_ state: RuleState) {
        self.init(name: state.name,
                  configuration: Configuration(variables: state.variables.map { Variable($0) },
                                               destination: state.destination.map { Component($0) }))
    }

}
