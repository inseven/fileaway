//
//  Component.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import Foundation

public struct Component: Codable {

    public let type: ComponentType
    public let value: String

    public init(type: ComponentType, value: String) {
        self.type = type
        self.value = value
    }
    
}
