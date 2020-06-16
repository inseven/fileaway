//
//  Manager.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Foundation

public class Manager {

    public var tasks: [Task] = []

    /**
     * Return the URL of the preferred configuration file.
     *
     * This will select the user's local configuration where available, falling back to the
     * destinations.json file in the bundle otherwise.
     */
    func configurationUrl() -> URL {
        return rootUrl.appendingPathComponent("file-actions.json")
    }

    public init(configurationUrl: URL) {
        do {
            print("Loading configuration at '\(configurationUrl.absoluteString)'...")
            tasks = try Manager.load(configurationUrl)
        } catch {
            print("\(error)")
        }
    }

    public var rootUrl: URL {
        return URL(fileURLWithPath: NSString(string: "~/Documents").expandingTildeInPath)
    }

    static func load(_ url: URL) throws -> [Task] {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let configurations = try decoder.decode([String: Configuration].self, from: data)
        let tasks = configurations.map { (name, configuration) -> Task in
            return Task(name: name, configuration: configuration)
            }.sorted { (task0, task1) -> Bool in
                return task0.name < task1.name
        }
        return tasks
    }

    public func destinationUrl(_ task: Task, variableProvider: VariableProvider, rootUrl: URL? = nil) -> URL {
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
        let actualRootUrl = rootUrl ?? self.rootUrl
        return actualRootUrl.appendingPathComponent(destination).appendingPathExtension("pdf")
    }

}
