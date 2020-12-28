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

public enum ComponentType: String, Codable {
    case text = "text"
    case variable = "variable"
}

public struct Component: Codable {
    public let type: ComponentType
    public let value: String

    public init(type: ComponentType, value: String) {
        self.type = type
        self.value = value
    }
}

public enum VariableType: CaseIterable {

    case string
    case date(hasDay: Bool)

    public static var allCases: [VariableType] { [
        .string,
        .date(hasDay: true),
        .date(hasDay: false)
    ] }
}

extension VariableType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .string:
            return "String"
        case .date(hasDay: true):
            return "Day, Month, Year"
        case .date(hasDay: false):
            return "Month, Year"
        }
    }

}

struct Variable: Identifiable {

    public var id = UUID()

    let name: String
    let type: VariableType

    init(name: String, type: VariableType) {
        self.name = name
        self.type = type
    }

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

class Task: Identifiable, Hashable {

    var id = UUID()
    let name: String
    let configuration: Configuration

    init(name: String) {
        self.name = name
        self.configuration = Configuration(variables: [], destination: [])
    }

    init(name: String, configuration: Configuration) {
        self.name = name
        self.configuration = configuration
    }

    // TODO: Flesh these out

    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
