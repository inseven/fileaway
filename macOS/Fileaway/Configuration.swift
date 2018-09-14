//
//  Configuration.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 14/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa

struct Configuration: Codable {
    enum CodingKeys: String, CodingKey {
        case destination = "destination"
    }
    let destination: [Component]
}

enum ComponentType: String, Codable {
    case text = "text"
    case variable = "variable"
}

struct Component: Codable {
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case value = "value"
    }
    let type: ComponentType
    let value: String
}

struct Task {
    let name: String
    let configuration: Configuration
}
