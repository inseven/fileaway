//
//  Configuration.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 14/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa

struct Configuration: Codable {
    let variables: [Variable]
    let destination: [Component]
}

enum ComponentType: String, Codable {
    case text = "text"
    case variable = "variable"
}

struct Component: Codable {
    let type: ComponentType
    let value: String
}

enum VariableType: String, Codable {
    case string = "string"
}

struct Variable: Codable {
    let name: String
    let type: VariableType
}

struct Task {
    let name: String
    let configuration: Configuration

    static func load(_ path: String) throws -> [Task] {
        let data = try Data.init(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        let configurations = try decoder.decode([String: Configuration].self, from: data)
        let tasks = configurations.map { (name, configuration) -> Task in
            return Task(name: name, configuration: configuration)
            }.sorted { (task0, task1) -> Bool in
                return task0.name < task1.name
        }
        return tasks
    }
}
