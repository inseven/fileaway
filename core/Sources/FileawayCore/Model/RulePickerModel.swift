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

import Interact

public class RulePickerModel: ObservableObject, Runnable {

    @Published public var filter: String = ""
    @Published public var filteredRules: [RuleModel] = []
    @Published public var recentRules: [RuleModel] = []
    @Published public var selection: RuleModel.ID?

    private var applicationModel: ApplicationModel
    private var cancellables: Set<AnyCancellable> = []
    private var queue = DispatchQueue(label: "queue")

    public init(applicationModel: ApplicationModel) {
        self.applicationModel = applicationModel
    }

    @MainActor public func start() {

        applicationModel
            .$allRules
            .combineLatest($filter)
            .receive(on: queue)
            .map { rules, filter in
                guard !filter.isEmpty else {
                    return (rules, filter)
                }
                let filteredRules = rules.filter { item in
                    [item.archiveURL.displayName, item.name].joined(separator: " ").localizedSearchMatches(string: filter)
                }
                return (filteredRules, filter)
            }
            .map { (filteredRules, filter) in
                (filteredRules.sorted { lhs, rhs in lhs.name.lexicographicallyPrecedes(rhs.name) }, filter)
            }
            .receive(on: DispatchQueue.main)
            .sink { (rules, filter: String) in
                self.filteredRules = rules
                if !filter.isEmpty || self.selection == nil {
                    self.selection = rules.first?.id
                }
            }
            .store(in: &cancellables)

        applicationModel.settings
            .$recentRuleIds
            .combineLatest(applicationModel.$allRules)
            .receive(on: queue)
            .map { recentRuleIds, allRules in
                let rules = allRules.filter { ruleModel in
                    recentRuleIds.contains(ruleModel.id)
                }.reduce(into: [RuleModel.ID:RuleModel]()) { partialResult, ruleModel in
                    partialResult[ruleModel.id] = ruleModel
                }
                let recentRules = recentRuleIds.compactMap { id in
                    return rules[id]
                }
                return recentRules
            }
            .receive(on: DispatchQueue.main)
            .sink { recentRules in
                self.recentRules = recentRules
            }
            .store(in: &cancellables)

    }

    @MainActor public func stop() {
        cancellables.removeAll()
    }

}
