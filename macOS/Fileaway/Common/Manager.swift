//
//  Manager.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Foundation

class Manager {

    let destinationsPath = "/Users/jbmorley/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/destinations.json"
    var tasks: [Task] = []

    public init() {
        do {
            tasks = try Manager.load(destinationsPath)
        } catch {
            print("\(error)")
        }
    }

    var count: Int {
        get {
            return tasks.count
        }
    }

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

    func task(forIndex index: Int) -> Task {
        return tasks[index]
    }

}
