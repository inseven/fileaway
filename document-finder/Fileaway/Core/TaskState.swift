//
//  TaskState.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import SwiftUI

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
