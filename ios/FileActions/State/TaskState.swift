//
//  TaskState.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 18/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

import FileActionsCore

extension Task {

    init(_ state: TaskState) {
        self.init(name: state.name,
                  configuration: Configuration(variables: state.variables.map { Variable($0) },
                                               destination: state.destination.map { Component($0) }))
    }

}

class TaskState: ObservableObject, Identifiable, BackChannelable, CustomStringConvertible {

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

    init(_ task: TaskState) {
        id = task.id
        name = String(task.name)
        let variables = task.variables.map { VariableState($0) }
        self.variables = variables
        destination = task.destination.map { component in
            ComponentState(component, variable: variables.first { $0.name == component.value } )
        }
    }

    init(task: Task) {
        name = task.name
        let variables = task.configuration.variables.map { VariableState($0) }
        self.variables = variables
        destination = task.configuration.destination.map { component in
            ComponentState(component, variable: variables.first { $0.name == component.value } )
        }
    }

    init(name: String) {
        self.name = name
        self.variables = []
        self.destination = []
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
