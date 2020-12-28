//
//  Configuration.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 10/12/2020.
//

import Foundation

struct Configuration: Codable {

    let variables: [Variable]
    let destination: [Component]

    init(variables: [Variable], destination: [Component]) {
        self.variables = variables
        self.destination = destination
    }
    
}

public struct Component: Codable {
    public let type: ComponentType
    public let value: String

    public init(type: ComponentType, value: String) {
        self.type = type
        self.value = value
    }
}
