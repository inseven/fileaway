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

    fileprivate var settings = Settings()

    @Published var locations: [URL] = []
    @Published var directories: [DirectoryObserver] = []
    @Published var allRules: [Rule] = []

    var countObservers: [DirectoryObserver.ID: Cancellable] = [:]

    var countSubscription: Cancellable?
    var rulesSubscription: Cancellable?

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))
        for url in settings.inboxUrls {
            addDirectoryObserver(type: .inbox, url: url)
        }
        for url in settings.archiveUrls {
            addDirectoryObserver(type: .archive, url: url)
        }
    }

    func updateCountSubscription() {
        dispatchPrecondition(condition: .onQueue(.main))
        let update: () -> Void = {
            dispatchPrecondition(condition: .onQueue(.main))
            let count = self.directories
                .filter { $0.type == .inbox }
                .map { $0.count }
                .reduce(0) { result, count in result + count }
            if count == 0 {
                NSApp.dockTile.badgeLabel = nil
            } else {
                NSApp.dockTile.badgeLabel = String(describing: count)
            }
        }
        let directoryChanges = self.directories.map { $0.objectWillChange }
        countSubscription = Publishers.MergeMany(directoryChanges).receive(on: DispatchQueue.main).sink { _ in
            update()
        }
        update()
    }

    func updateRuleSetSubscription() {
        dispatchPrecondition(condition: .onQueue(.main))
        let update: () -> Void = {
            dispatchPrecondition(condition: .onQueue(.main))
            self.allRules = self.directories.map { $0.ruleSet.rules }.flatMap { $0 }
        }
        let changes = self.directories.map { $0.ruleSet.objectWillChange }
        rulesSubscription = Publishers.MergeMany(changes).receive(on: DispatchQueue.main).sink { _ in
            update()
        }
        update()
    }

    func directories(type: DirectoryObserver.DirectoryType) -> [DirectoryObserver] {
        self.directories.filter { directoryObserver in
            directoryObserver.type == type
        }.sorted { lhs, rhs in
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }

    func addDirectoryObserver(type: DirectoryObserver.DirectoryType, url: URL) {
        dispatchPrecondition(condition: .onQueue(.main))
        let directoryObserver = DirectoryObserver(type: type, url: url)
        directories.append(directoryObserver)
        directoryObserver.start()
        updateCountSubscription()
        updateRuleSetSubscription()
    }

    func removeDirectoryObserver(directoryObserver: DirectoryObserver) throws {
        dispatchPrecondition(condition: .onQueue(.main))
        guard directories.contains(directoryObserver) else {
            throw FileawayError.directoryNotFound
        }
        directoryObserver.stop()
        directories.removeAll { $0.id == directoryObserver.id }
        try save()
        updateCountSubscription()
        updateRuleSetSubscription()
    }

    func addLocation(type: DirectoryObserver.DirectoryType, url: URL) throws {
        dispatchPrecondition(condition: .onQueue(.main))
        let _ = try url.securityScopeBookmarkData() // Check that we can access the location.
        addDirectoryObserver(type: type, url: url)
        try save()
    }

    func save() throws {
        try settings.setInboxUrls(self.directories(type: .inbox).map { $0.url })
        try settings.setArchiveUrls(self.directories(type: .archive).map { $0.url })
    }

}
