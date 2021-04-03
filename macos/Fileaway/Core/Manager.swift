// Copyright (c) 2018-2021 InSeven Limited
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

import AppKit
import Combine
import Foundation
import SwiftUI

struct ManagerKey: EnvironmentKey {
    static var defaultValue: Manager = Manager()
}

extension EnvironmentValues {

    var manager: Manager {
        get { self[ManagerKey.self] }
        set { self[ManagerKey.self] = newValue }
    }

}

class Manager: ObservableObject {

    var settings = Settings()
    var ruleSet: RuleSet?

    @Published var locations: [URL] = []
    @Published var inbox: DirectoryObserver? = nil
    @Published var archive: DirectoryObserver? = nil
    @Published var rules: [Rule] = []

    var badgeObserver: Cancellable?
    var rulesSubscription: Cancellable?

    func createInboxObserver(url: URL) {
        dispatchPrecondition(condition: .onQueue(.main))
        inbox = DirectoryObserver(name: "Inbox", locations: [url])
        badgeObserver = nil
        guard let inbox = inbox else {
            return
        }
        inbox.start()
        NSApp.dockTile.badgeLabel = "\(inbox.files.count)"
        badgeObserver = inbox.objectWillChange.sink(receiveValue: {
            self.updateBadge()
        })
        updateBadge()
    }

    func updateBadge() {
        DispatchQueue.main.async {
            guard let inbox = self.inbox else {
                print("Unable to get badge count without inbox; clearing")
                NSApp.dockTile.badgeLabel = nil
                return
            }
            print("badge = \(inbox.count)")
            NSApp.dockTile.badgeLabel = inbox.count > 0 ? "\(inbox.count)" : ""
        }
    }

    func createArchiveObserver(url: URL) {
        dispatchPrecondition(condition: .onQueue(.main))
        archive = DirectoryObserver(name: "Archive", locations: [url])
        guard let archive = archive else {
            return
        }
        archive.start()
    }

    func start() {
        if let url = try? settings.inboxUrl() {
            self.createInboxObserver(url: url)
        }
        if let url = try? settings.archiveUrl() {
            self.createArchiveObserver(url: url)
            let ruleSet = RuleSet(url: url)
            self.ruleSet = ruleSet
            self.rules = ruleSet.rules
            rulesSubscription = ruleSet.objectWillChange.receive(on: DispatchQueue.main).sink {
                self.rules = ruleSet.mutableRules.map { Rule($0) }
            }
        }
    }

    var inboxUrl: URL? { try? settings.inboxUrl() }

    func setInboxUrl(_ url: URL) throws {
        try settings.setInboxUrl(url)
        self.createInboxObserver(url: url)
    }

    var archiveUrl: URL? { try? settings.archiveUrl() }

    func setArchiveUrl(_ url: URL) throws {
        try settings.setArchiveUrl(url)
        self.createArchiveObserver(url: url)
    }

}
