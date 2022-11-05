// Copyright (c) 2018-2022 InSeven Limited
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Combine
import SwiftUI

import FileawayCore

enum RuleSetError: Error {
    case duplicateName
}

extension RuleSetError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .duplicateName:
            return "Name already exists in Rule Set."
        }
    }

}

class RuleSet: ObservableObject {

    let rootUrl: URL
    let url: URL

    @Published var rules: [Rule]
    @Published var mutableRules: [RuleState]

    var rulesSubscription: Cancellable?

    static func load(url: URL) throws -> [Rule] {
        let rootUrl = url.deletingLastPathComponent()
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let configurations = try decoder.decode([String: Configuration].self, from: data)
        let rules = configurations.map { (name, configuration) -> Rule in
            return Rule(rootUrl: rootUrl, name: name, configuration: configuration)
            }.sorted { $0.name < $1.name }
        return rules
    }

    init(url: URL) {
        self.rootUrl = url
        self.url = url.appendingPathComponent("file-actions.json")
        let rules = (try? Self.load(url: self.url)) ?? []
        self.rules = rules
        self.mutableRules = rules.map { rule in
            RuleState(rule, rootUrl: url)
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

    /**
     Check to see if a rule name already exists in the rule set.

     This is necessary because, for the time being at least, rules must have unique names. Right now, it's a technical
     limitation due to the way the rules file is stored (with the name as the key into a dictionary), but it probably
     makes sense to prevent users from creating identically named rules.
     */
    func contains(ruleNamed name: String) -> Bool {
        let names = Set(mutableRules.map { $0.name })
        return names.contains(name)
    }

    /**
     Generate a guaranteed unique name based on a preferred name by appending an incrementing instance number to the
     name in the case that the preferred name is not found to be unique. This is intended to match the behaviour of
     duplication in Finder.
     */
    fileprivate func uniqueRuleName(preferredName: String) -> String {
        var name = preferredName
        var index = 2
        while contains(ruleNamed: name) {
            name = "\(preferredName) \(index)"
            index = index + 1
        }
        return name
    }

    func add(_ rule: RuleState) throws {
        guard !contains(ruleNamed: rule.name) else {
            throw RuleSetError.duplicateName
        }
        mutableRules.append(rule)
        var rules = Array(self.rules)
        rules.append(Rule(rule))
        self.rules = rules.sorted { $0.name < $1.name }
        updateSubscription()
        try save()
    }

    func new(preferredName: String) throws -> RuleState {
        let name = uniqueRuleName(preferredName: preferredName)
        let rule = RuleState(id: UUID(),
                             rootUrl: rootUrl,
                             name: name,
                             variables: [VariableModel(name: "Date", type: .date(hasDay: true))],
                             destination: [
                                ComponentState(value: "New Folder/", type: .text, variable: nil),
                                ComponentState(value: "Date", type: .variable, variable: nil),
                                ComponentState(value: " Description", type: .text, variable: nil)])
        try add(rule)
        return rule
    }

    private func duplicate(_ rule: RuleState, preferredName: String) throws -> RuleState {
        let name = uniqueRuleName(preferredName: preferredName)
        let newRule = RuleState(rule)
        newRule.name = name
        try add(newRule)
        return newRule
    }

    func duplicate(ids: Set<RuleState.ID>) throws -> [RuleState] {
        let rules = mutableRules.filter { ids.contains($0.id) }
        return try rules.map { try duplicate($0, preferredName: "Copy of " + $0.name) }
    }

    func remove(ids: Set<RuleState.ID>) throws {
        mutableRules.removeAll { ids.contains($0.id) }
        rules.removeAll { ids.contains($0.id) }
        try save()
    }

    private func save() throws {
        dispatchPrecondition(condition: .onQueue(.main))
        rules = mutableRules.map { Rule($0) }
        let configuration = rules.reduce(into: [:]) { result, rule in
            result[rule.name] = rule.configuration
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(configuration)
        try data.write(to: url)
    }
    
}
