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

    private let archiveURL: URL
    private let fileURL: URL

    @Published public var ruleModels: [RuleModel]

    var rulesSubscription: Cancellable?

    public init(archiveURL: URL) {
        self.archiveURL = archiveURL
        self.fileURL = archiveURL.rulesUrl
        if FileManager.default.fileExists(atPath: self.fileURL.path) {
            do {
                self.ruleModels = try RuleList(url: self.fileURL).models(for: self.archiveURL)
            } catch {
                // TODO: Propagate this error!
                print("Failed to load rules with error \(error).")
                self.ruleModels = []
            }
        } else {
            self.ruleModels = []
        }
        updateSubscription()
    }

    private func updateSubscription() {
        let changes = self.ruleModels.map { $0.objectWillChange }
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
        let names = Set(ruleModels.map { $0.name })
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

    public func add(_ ruleModel: RuleModel) throws {
        guard !contains(ruleNamed: ruleModel.name) else {
            throw FileawayError.duplicateRuleName
        }
        ruleModels.append(ruleModel)
        updateSubscription()
        try save()
    }

    public func new() throws -> RuleModel {
        let name = uniqueRuleName(preferredName: "Rule")
        let rule = RuleModel(id: UUID(),
                             rootUrl: archiveURL,
                             name: name,
                             variables: [VariableModel(name: "Date", type: .date(hasDay: true))],
                             destination: [
                                ComponentModel(value: "Paperwork/", type: .text, variable: nil),
                                ComponentModel(value: "Date", type: .variable, variable: nil),
                                ComponentModel(value: " Description", type: .text, variable: nil)])
        try add(rule)
        return rule
    }

    @MainActor public func replace(ruleModel: RuleModel) {
        guard
            let index = self.ruleModels.firstIndex(where: { $0.id == ruleModel.id }),
            let range = Range(NSRange(location: index, length: 1))else {
            return
        }
        self.ruleModels.replaceSubrange(range, with: [ruleModel])
        assert(validateChildren())
        try! save()
    }

    @MainActor private func validateChildren() -> Bool {
        return self.ruleModels.map { $0.validate() }.reduce(false, { $0 || $1 })
    }

    private func duplicate(_ ruleModel: RuleModel, preferredName: String) throws -> RuleModel {
        let name = uniqueRuleName(preferredName: preferredName)
        let newRuleModel = RuleModel(id: UUID(), ruleModel: ruleModel)
        newRuleModel.name = name
        try add(newRuleModel)
        return newRuleModel
    }

    public func duplicate(ids: Set<RuleModel.ID>) throws -> [RuleModel] {
        let rules = ruleModels.filter { ids.contains($0.id) }
        return try rules.map { try duplicate($0, preferredName: "Copy of " + $0.name) }
    }

    public func remove(ids: Set<RuleModel.ID>) throws {
        ruleModels.removeAll { ids.contains($0.id) }
        try save()
    }

    private func save() throws {
        dispatchPrecondition(condition: .onQueue(.main))
        let configurationList = RuleList(ruleModels: ruleModels)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(configurationList)
        try data.write(to: fileURL)
    }
    
}

extension Rule {

    public init(_ ruleModel: RuleModel) {
        self.init(id: ruleModel.id,
                  name: ruleModel.name,
                  variables: ruleModel.variables,
                  destination: ruleModel.destination.map { Component($0) })
    }

}

extension RuleList {

    init(ruleModels: [RuleModel]) {
        rules = ruleModels
            .map { Rule($0) }
    }

    func models(for rootUrl: URL) -> [RuleModel] {
        return rules
            .map { rule in
                return RuleModel(rootUrl: rootUrl, rule: rule)
            }
            .sorted { $0.name < $1.name }
    }

}
