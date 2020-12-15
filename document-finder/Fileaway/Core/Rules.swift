//
//  Rules.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 10/12/2020.
//

import SwiftUI

class Rules {

    let url: URL
    var tasks: [Task]

    // TODO: Rename Task to Rule
    static func load(url: URL) throws -> [Task] {
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

    init(url: URL) {
        self.url = url
        self.tasks = (try? Self.load(url: self.url.appendingPathComponent("file-actions.json"))) ?? []
    }
    
}
