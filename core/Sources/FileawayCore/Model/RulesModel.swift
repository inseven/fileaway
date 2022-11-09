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

public class RulesModel: ObservableObject {

    public let rootUrl: URL
    public let url: URL

    @Published public var rules: [Rule]
    @Published public var mutableRules: [RuleModel]

    var rulesSubscription: Cancellable?

    public static func load(url: URL) throws -> [Rule] {
        let rootUrl = url.deletingLastPathComponent()
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let configurations = try decoder.decode([String: Configuration].self, from: data)
        let rules = configurations.map { (name, configuration) -> Rule in
            return Rule(rootUrl: rootUrl, name: name, configuration: configuration)
            }.sorted { $0.name < $1.name }
        return rules
    }

    public init(url: URL) {
        self.rootUrl = url
        self.url = url.appendingPathComponent("Rules.fileaway")
        let rules: [Rule]
        do {
            rules = try Self.load(url: self.url)
        } catch {
            // TODO: Propagate this error!
            print("Failed to load rules with error \(error).")
            rules = []
        }
        self.rules = rules
        self.mutableRules = rules.map { rule in
            RuleModel(rule, rootUrl: url)
        }
        updateSubscription()
    }

    // TODO: Consider removing this.
    public func updateSubscription() {
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
    public func contains(ruleNamed name: String) -> Bool {
        let names = Set(mutableRules.map { $0.name })
        return names.contains(name)
    }

    /**
     Generate a guaranteed unique name based on a preferred name by appending an incrementing instance number to the
     name in the case that the preferred name is not found to be unique. This is intended to match the behaviour of
     duplication in Finder.
     */
    private func uniqueRuleName(preferredName: String) -> String {
        var name = preferredName
        var index = 2
        while contains(ruleNamed: name) {
            name = "\(preferredName) \(index)"
            index = index + 1
        }
        return name
    }

    public func add(_ rule: RuleModel) throws {
        guard !contains(ruleNamed: rule.name) else {
            throw FileawayError.duplicateRuleName
        }
        mutableRules.append(rule)
        var rules = Array(self.rules)
        rules.append(Rule(rule))
        self.rules = rules.sorted { $0.name < $1.name }
        updateSubscription()
        try save()
    }

    public func new(preferredName: String) throws -> RuleModel {
        let name = uniqueRuleName(preferredName: preferredName)
        let rule = RuleModel(id: UUID(),
                             rootUrl: rootUrl,
                             name: name,
                             variables: [VariableModel(name: "Date", type: .date(hasDay: true))],
                             destination: [
                                ComponentModel(value: "New Folder/", type: .text, variable: nil),
                                ComponentModel(value: "Date", type: .variable, variable: nil),
                                ComponentModel(value: " Description", type: .text, variable: nil)])
        try add(rule)
        return rule
    }

    private func duplicate(_ rule: RuleModel, preferredName: String) throws -> RuleModel {
        let name = uniqueRuleName(preferredName: preferredName)
        let newRule = RuleModel(rule)
        newRule.name = name
        try add(newRule)
        return newRule
    }

    public func duplicate(ids: Set<RuleModel.ID>) throws -> [RuleModel] {
        let rules = mutableRules.filter { ids.contains($0.id) }
        return try rules.map { try duplicate($0, preferredName: "Copy of " + $0.name) }
    }

    public func remove(ids: Set<RuleModel.ID>) throws {
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
