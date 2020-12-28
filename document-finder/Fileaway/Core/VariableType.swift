//
//  VariableType.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import Foundation

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

extension VariableType: Identifiable, Hashable {

    public var id: String {
        switch self {
        case .string:
            return "string"
        case .date(hasDay: false):
            return "date"
        case .date(hasDay: true):
            return "date-day"
        }
    }

    public static func == (lhs: VariableType, rhs: VariableType) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
