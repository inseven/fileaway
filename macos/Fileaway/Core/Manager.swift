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

    // TODO: Make this fileprivate
    var settings = Settings()
    var ruleSet: RuleSet?

    @Published var locations: [URL] = []
    @Published var directories: [DirectoryObserver] = []
    @Published var rules: [Rule] = []

    var badgeObservers: [DirectoryObserver.ID: Cancellable] = [:]
    var rulesSubscription: Cancellable?

    func updateBadge() {
        dispatchPrecondition(condition: .onQueue(.main))
        let count = directories.filter { $0.type == .inbox }.map { $0.count }.reduce(0) { result, count in result + count }
        print("badge = \(count)")
        if count == 0 {
            NSApp.dockTile.badgeLabel = nil
        } else {
            NSApp.dockTile.badgeLabel = String(describing: count)
        }
    }

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))
        for url in settings.inboxUrls {
            addDirectoryObserver(type: .inbox, url: url)
        }

        if let url = try? settings.archiveUrl() {
            addDirectoryObserver(type: .archive, url: url)
            let ruleSet = RuleSet(url: url)
            self.ruleSet = ruleSet
            self.rules = ruleSet.rules
            rulesSubscription = ruleSet.objectWillChange.receive(on: DispatchQueue.main).sink {
                self.rules = ruleSet.mutableRules.map { Rule($0) }
            }
        }
    }

    var archiveUrl: URL? { try? settings.archiveUrl() }

    func setArchiveUrl(_ url: URL) throws {
        dispatchPrecondition(condition: .onQueue(.main))
        try settings.setArchiveUrl(url)
        addDirectoryObserver(type: .archive, url: url)
    }

    func addDirectoryObserver(type: DirectoryObserver.DirectoryType, url: URL) {
        dispatchPrecondition(condition: .onQueue(.main))

        // Create the directory observer and start it.
        let directoryObserver = DirectoryObserver(type: type, location: url)
        directories.append(directoryObserver)
        directoryObserver.start()

        // Start observing the counts to update the badge.
        // updateBadge filters the directory observers so it's OK to add both inbox and archive observers here.
        let observer = directoryObserver.objectWillChange.sink(receiveValue: {
            DispatchQueue.main.async {
                self.updateBadge()
            }
        })
        badgeObservers[directoryObserver.id] = observer
        updateBadge()
    }

    func addLocation(type: DirectoryObserver.DirectoryType, url: URL) throws {
        dispatchPrecondition(condition: .onQueue(.main))
        let _ = try url.securityScopeBookmarkData()  // Ensure we can use the bookmark; TODO: Do this elsewhre.
        addDirectoryObserver(type: type, url: url)
        try save()
    }

    func save() throws {
        let inboxUrls = directories.filter { $0.type == .inbox }.map { $0.location }  // TODO: Rename location to URL
        try settings.setInboxUrls(inboxUrls)
    }

    func removeDirectoryObserver(directoryObserver: DirectoryObserver) throws {
        dispatchPrecondition(condition: .onQueue(.main))

        // TODO: Assert that the directory observer is actually in the active set?

        if let badgeObserver = badgeObservers[directoryObserver.id] {
            badgeObserver.cancel()
            badgeObservers.removeValue(forKey: directoryObserver.id)
        }

        directoryObserver.stop()
        directories.removeAll { $0.id == directoryObserver.id }
        try save()
    }

}
