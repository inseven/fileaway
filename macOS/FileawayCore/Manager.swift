//
//  Manager.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Foundation

public class Manager {

    let destinationsPath = "~/.fileaway/destinations.json"
    public var tasks: [Task] = []

    public init() {
        do {
            tasks = try Manager.load(destinationsPath)
        } catch {
            print("\(error)")
        }
    }

    public var rootUrl: URL {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let documentsDirectory = homeDirectory.appendingPathComponent("Documents")
        return documentsDirectory
    }

    static func load(_ path: String) throws -> [Task] {
        let destination = NSString(string: path).expandingTildeInPath
        let data = try Data(contentsOf: URL(fileURLWithPath: destination))
        let decoder = JSONDecoder()
        let configurations = try decoder.decode([String: Configuration].self, from: data)
        let tasks = configurations.map { (name, configuration) -> Task in
            return Task(name: name, configuration: configuration)
            }.sorted { (task0, task1) -> Bool in
                return task0.name < task1.name
        }
        return tasks
    }

    public func destinationUrl(_ task: Task, variableProvider: VariableProvider) -> URL {
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
        return rootUrl.appendingPathComponent(destination).appendingPathExtension("pdf")
    }

}
