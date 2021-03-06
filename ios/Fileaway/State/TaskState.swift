// Copyright (c) 2018-2022 InSeven Limited
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Combine
import Foundation
import SwiftUI

import FileawayCore

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
    }

    convenience init(_ taskState: TaskState) {
        self.init(id: UUID(),
                  name: String(taskState.name),
                  variables: taskState.variables.map { VariableState($0) },
                  destination: taskState.destination.map { ComponentState($0, variable: nil) })
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
