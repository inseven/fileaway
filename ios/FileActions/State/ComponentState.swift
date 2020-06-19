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

    let id = UUID()
    @Published var value: String
    @Published var type: ComponentType

    init(value: String, type: ComponentType) {
        self.value = value
        self.type = type
    }

    init(_ component: Component) {
        value = component.value
        type = component.type
    }

}
