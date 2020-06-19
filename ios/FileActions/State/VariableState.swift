//
//  VariableState.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 18/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//


import Foundation

import FileActionsCore

extension Variable {

    init(_ state: VariableState) {
        self.init(name: state.name, type: state.type)
    }
    
}

class VariableState: ObservableObject, Identifiable {

    var id = UUID()
    @Published var name: String
    @Published var type: VariableType

    public init(_ variable: Variable) {
        self.name = variable.name
        self.type = variable.type
    }

    public init(name: String, type: VariableType) {
        self.name = name
        self.type = type
    }
}
