//
//  ComponentState.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 18/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation
import SwiftUI

import FileActionsCore

extension Component {

    init(_ state: ComponentState) {
        self.init(type: state.type, value: state.value)
    }

}

class ComponentState: ObservableObject, Identifiable {

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

}
