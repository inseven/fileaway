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

import FileawayCore

class TaskPageModel: ObservableObject, Runnable {

    @Published var filter: String = ""
    @Published var filteredRules: [Rule] = []
    @Published var selection: Rule.ID?

    private var manager: ApplicationModel
    private var cancellables: Set<AnyCancellable> = []
    private var queue = DispatchQueue(label: "queue")

    init(manager: ApplicationModel) {
        self.manager = manager
    }

    @MainActor func start() {

        manager
            .$allRules
            .combineLatest($filter)
            .receive(on: queue)
            .map { rules, filter in
                guard !filter.isEmpty else {
                    return rules
                }
                return rules.filter { item in
                    [item.rootUrl.displayName, item.name].joined(separator: " ").localizedSearchMatches(string: filter)
                }
            }
            .map { $0.sorted { lhs, rhs in lhs.name.lexicographicallyPrecedes(rhs.name) } }
            .receive(on: DispatchQueue.main)
            .sink { rules in
                self.filteredRules = rules
                self.selection = rules.first?.id
            }
            .store(in: &cancellables)
    }

    @MainActor func stop() {
        cancellables.removeAll()
    }

}
