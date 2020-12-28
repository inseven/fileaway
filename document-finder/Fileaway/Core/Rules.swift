//
//  Rules.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 10/12/2020.
//

import Combine
import SwiftUI

class Rules: ObservableObject {

    let url: URL

    @Published var rules: [Rule]
    @Published var mutableRules: [RuleState]

    var rulesSubscription: Cancellable?

    // TODO: Rename Task to Rule
    static func load(url: URL) throws -> [Rule] {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let configurations = try decoder.decode([String: Configuration].self, from: data)
        let tasks = configurations.map { (name, configuration) -> Rule in
            return Rule(name: name, configuration: configuration)
            }.sorted { (task0, task1) -> Bool in
                return task0.name < task1.name
        }
        return tasks
    }

    init(url: URL) {
        self.url = url.appendingPathComponent("file-actions.json")
        let rules = (try? Self.load(url: self.url)) ?? []
        self.rules = rules
        self.mutableRules = rules.map { rule in
            RuleState(rule)
        }
        updateSubscription()
    }

    // TODO: Consider removing this.
    func updateSubscription() {
        let changes = self.mutableRules.map { $0.objectWillChange }
        rulesSubscription = Publishers.MergeMany(changes).receive(on: DispatchQueue.main).sink { _ in
            self.objectWillChange.send()
            try? self.save()
        }
    }

    func add(_ rule: RuleState) throws {
        mutableRules.append(rule)
        var rules = Array(self.rules)
        rules.append(Rule(rule))
        self.rules = rules.sorted { (task0, task1) -> Bool in
            return task0.name < task1.name
        }
        updateSubscription()
        try save()
    }

    func new() throws -> RuleState {
        let names = Set(mutableRules.map { $0.name })
        var index = 1
        var name = ""
        repeat {
            name = "Rule \(index)"
            index = index + 1
        } while names.contains(name)
        let task = RuleState(id: UUID(),
                             name: name,
                             variables: [VariableState(name: "Date", type: .date(hasDay: true))],
                             destination: [
                                ComponentState(value: "New Folder/", type: .text, variable: nil),
                                ComponentState(value: "Date", type: .variable, variable: nil),
                                ComponentState(value: " Description", type: .text, variable: nil)])
        try add(task)
        return task
    }

    func remove(_ rule: RuleState) throws {
        mutableRules.removeAll { $0 == rule }
        rules.removeAll { $0.id == rule.id }
        try save()
    }

    func save() throws {
        let configuration = mutableRules.map { Rule($0) }.reduce(into: [:]) { result, task in
            result[task.name] = task.configuration
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(configuration)
        try data.write(to: url)
    }
    
}
