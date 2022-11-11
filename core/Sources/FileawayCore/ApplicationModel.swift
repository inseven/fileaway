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
import Foundation
import SwiftUI

#if os(macOS)
import AppKit
#endif

public struct ApplicationModelKey: EnvironmentKey {
    public static var defaultValue: ApplicationModel = ApplicationModel()
}

extension EnvironmentValues {

    public var applicationModel: ApplicationModel {
        get { self[ApplicationModelKey.self] }
        set { self[ApplicationModelKey.self] = newValue }
    }

}

public class ApplicationModel: ObservableObject {

    private var settings = Settings()

    @Published public var directories: [DirectoryModel] = []
    @Published public var allRules: [RuleModel] = []

    var countObservers: [DirectoryModel.ID: Cancellable] = [:]
    var countSubscription: Cancellable?
    var rulesSubscription: Cancellable?

    public init() {
        self.start()
    }

    public func start() {
        dispatchPrecondition(condition: .onQueue(.main))
        for url in settings.inboxUrls {
            addDirectoryObserver(type: .inbox, url: url)
        }
        for url in settings.archiveUrls {
            addDirectoryObserver(type: .archive, url: url)
        }
    }

    private func updateCountSubscription() {
#if os(macOS)
        // TODO: Icon badge for iOS
        dispatchPrecondition(condition: .onQueue(.main))
        let update: () -> Void = {
            dispatchPrecondition(condition: .onQueue(.main))
            let count = self.directories
                .filter { $0.type == .inbox }
                .map { $0.count }
                .reduce(0) { result, count in result + count }
            if count == 0 {
                NSApplication.shared.dockTile.badgeLabel = nil
            } else {
                NSApplication.shared.dockTile.badgeLabel = String(describing: count)
            }
        }
        let directoryChanges = self.directories.map { $0.objectWillChange }
        countSubscription = Publishers.MergeMany(directoryChanges).receive(on: DispatchQueue.main).sink { _ in
            update()
        }
        update()
#endif
    }

    private func updateRuleSetSubscription() {
        dispatchPrecondition(condition: .onQueue(.main))
        let update: () -> Void = {
            dispatchPrecondition(condition: .onQueue(.main))
            self.allRules = self.directories.map { $0.ruleSet.ruleModels }.flatMap { $0 }
        }
        let changes = self.directories.map { $0.ruleSet.objectWillChange }
        rulesSubscription = Publishers.MergeMany(changes).receive(on: DispatchQueue.main).sink { _ in
            update()
        }
        update()
    }

    public func directories(type: DirectoryModel.DirectoryType) -> [DirectoryModel] {
        self.directories.filter { directoryObserver in
            directoryObserver.type == type
        }.sorted { lhs, rhs in
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }

    public func addLocation(type: DirectoryModel.DirectoryType, url: URL) throws {
        dispatchPrecondition(condition: .onQueue(.main))
#if os(macOS)
        let _ = try url.securityScopeBookmarkData() // Check that we can access the location.
        addDirectoryObserver(type: type, url: url)
        try save()
#else
        precondition(url.startAccessingSecurityScopedResource())
        precondition(FileManager.default.isReadableFile(atPath: url.path))
        addDirectoryObserver(type: type, url: url)
#endif
    }

    @MainActor public func removeLocation(url: URL) throws {
        guard let directoryModel = directories.filter({ $0.url == url }).first else {
            return
        }
        try removeDirectoryObserver(directoryObserver: directoryModel)
    }

    private func addDirectoryObserver(type: DirectoryModel.DirectoryType, url: URL) {
        dispatchPrecondition(condition: .onQueue(.main))
        let directoryObserver = DirectoryModel(type: type, url: url)
        directories.append(directoryObserver)
        directoryObserver.start()
        updateCountSubscription()
        updateRuleSetSubscription()
    }

    private func removeDirectoryObserver(directoryObserver: DirectoryModel) throws {
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

    private func save() throws {
        try settings.setInboxUrls(self.directories(type: .inbox).map { $0.url })
        try settings.setArchiveUrls(self.directories(type: .archive).map { $0.url })
    }

}
