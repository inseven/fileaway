//
//  Configuration.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 14/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa

public struct Configuration: Codable {
    public let variables: [Variable]
    public let destination: [Component]
}

public enum ComponentType: String, Codable {
    case text = "text"
    case variable = "variable"
}

public struct Component: Codable {
    public let type: ComponentType
    public let value: String
}

public enum VariableType {
    case string
    case date(hasDay: Bool)
}

public struct Variable {
    public let name: String
    public let type: VariableType
}

extension Variable: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case dateParams
    }

    enum RawType: String, Codable {
        case string
        case date
    }

    struct DateParams: Codable {
        let hasDay: Bool

        init(hasDay: Bool = true) {
            self.hasDay = hasDay
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        switch type {
        case .string:
            try container.encode(RawType.string, forKey: .type)
        case .date(let hasDay):
            try container.encode(RawType.date, forKey: .type)
            try container.encode(DateParams(hasDay: hasDay), forKey: .dateParams)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        let type = try container.decode(RawType.self, forKey: .type)

        switch type {
        case .string:
            self = Variable(name: name, type: .string)
        case .date:
            let dateParams = try container.decodeIfPresent(DateParams.self, forKey: .dateParams)
                ?? DateParams()
            self = Variable(name: name, type: .date(hasDay: dateParams.hasDay))
        }
    }
}

public struct Task {
    public let name: String
    public let configuration: Configuration
}

public func DestinationURL(_ task: Task, variableProvider: VariableProvider) -> URL {
    let destination = task.configuration.destination.reduce("") { (result, component) -> String in
        switch component.type {
        case .text:
            return result.appending(component.value)
        case .variable:
            guard let value = variableProvider.variable(forKey: component.value) else {
                return result
            }
            return result.appending(value)
        }
    }
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
    let documentsDirectory = homeDirectory.appendingPathComponent("Documents")
    let destinationURL = documentsDirectory.appendingPathComponent(destination).appendingPathExtension("pdf")
    return destinationURL
}
