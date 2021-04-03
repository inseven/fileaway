//
//  VariableInstance.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import Foundation

class VariableInstance: Identifiable {

    public var id: UUID { variable.id }
    var variable: Variable
    var name: String { variable.name }

    init(variable: Variable) {
        self.variable = variable
    }

}
