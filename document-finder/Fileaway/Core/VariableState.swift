//
//  VariableState.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import Foundation

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

extension Variable {

    init(_ state: VariableState) {
        self.init(name: state.name, type: state.type)
    }

}
