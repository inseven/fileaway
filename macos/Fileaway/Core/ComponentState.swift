//
//  ComponentState.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import Foundation

class ComponentState: ObservableObject, Identifiable, Hashable {

    var id = UUID()
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

extension Component {

    init(_ state: ComponentState) {
        self.init(type: state.type, value: state.value)
    }

}
