//
//  Rules.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 10/12/2020.
//

import SwiftUI

class Rules: ObservableObject {

    let url: URL

    @Published var rules: [Task]

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
        self.url = url.appendingPathComponent("file-actions.json")
        self.rules = (try? Self.load(url: self.url)) ?? []
    }

    func add(_ rule: Task) throws {
        var rules = Array(self.rules)
        rules.append(rule)
        self.rules = rules.sorted { (task0, task1) -> Bool in
            return task0.name < task1.name
        }
        try save()
    }

    func remove(_ rule: Task) throws {
        rules.removeAll { $0 == rule }
        try save()
    }

    func save() throws {
        let configuration = rules.reduce(into: [:]) { result, task in
            result[task.name] = task.configuration
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(configuration)
        try data.write(to: url)
    }
    
}
