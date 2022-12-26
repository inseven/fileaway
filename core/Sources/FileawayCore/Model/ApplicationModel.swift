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

import Interact

extension Array where Element == DirectoryModel {

    @MainActor func refresh() {
        for directoryModel in self {
            directoryModel.refresh()
        }
    }

}

public class ApplicationModel: ObservableObject {

    public let settings = Settings()

    @MainActor @Published public var inboxes: [DirectoryModel] = [] {
        didSet {
            try? settings.setInboxUrls(inboxes.map { $0.url })
        }
    }

    @MainActor @Published public var archives: [DirectoryModel] = [] {
        didSet {
            try? settings.setArchiveUrls(archives.map { $0.url })
        }
    }

    @Published public var rules: [RuleModel] = []

    var countObservers: [DirectoryModel.ID: Cancellable] = [:]
    var countSubscription: Cancellable?
    var rulesSubscription: Cancellable?

    @MainActor private var directories: [DirectoryModel] {
        return inboxes + archives
    }

    @MainActor public init() {
        self.start()
    }

    @MainActor public func start() {
        dispatchPrecondition(condition: .onQueue(.main))
        for url in settings.inboxURLs {
            addDirectoryObserver(type: .inbox, url: url)
        }
        for url in settings.archiveURLs {
            addDirectoryObserver(type: .archive, url: url)
        }
    }

    @MainActor private func updateCountSubscription() {

        dispatchPrecondition(condition: .onQueue(.main))
        let update: () -> Void = {
            dispatchPrecondition(condition: .onQueue(.main))
            let count = self
                .inboxes
                .map { $0.count }
                .reduce(0) { result, count in result + count }
            Application.setBadgeNumber(count)
        }

        let directoryChanges = self
            .inboxes
            .map { $0.objectWillChange }
        countSubscription = Publishers.MergeMany(directoryChanges).receive(on: DispatchQueue.main).sink { _ in
            update()
        }
        update()
    }

    @MainActor private func updateRuleSetSubscription() {
        dispatchPrecondition(condition: .onQueue(.main))
        let update: () -> Void = {
            dispatchPrecondition(condition: .onQueue(.main))
            self.rules = self.directories.map { $0.ruleSet.ruleModels }.flatMap { $0 }
        }
        let changes = directories.map { $0.ruleSet.objectWillChange }
        rulesSubscription = Publishers.MergeMany(changes).receive(on: DispatchQueue.main).sink { _ in
            update()
        }
        update()
    }

    @MainActor public func addLocation(type: DirectoryModel.DirectoryType, url: URL) throws {
        dispatchPrecondition(condition: .onQueue(.main))
        try url.prepareForSecureAccess()
        addDirectoryObserver(type: type, url: url)
    }

    @MainActor public func removeLocation(url: URL) throws {
        guard let directoryModel = directories.filter({ $0.url == url }).first else {
            return
        }
        try removeDirectoryObserver(directoryObserver: directoryModel)
    }

    @MainActor private func addDirectoryObserver(type: DirectoryModel.DirectoryType, url: URL) {
        dispatchPrecondition(condition: .onQueue(.main))
        let directoryObserver = DirectoryModel(settings: settings, type: type, url: url)
        switch type {
        case .inbox:
            inboxes.append(directoryObserver)
        case .archive:
            archives.append(directoryObserver)
        }
        directoryObserver.start()
        updateCountSubscription()
        updateRuleSetSubscription()
    }

    @MainActor private func removeDirectoryObserver(directoryObserver: DirectoryModel) throws {
        dispatchPrecondition(condition: .onQueue(.main))
        guard directories.contains(directoryObserver) else {
            throw FileawayError.directoryNotFound
        }
        directoryObserver.stop()
        inboxes.removeAll { $0.id == directoryObserver.id }
        archives.removeAll { $0.id == directoryObserver.id }
        updateCountSubscription()
        updateRuleSetSubscription()
    }

    @MainActor public func refresh() {
        inboxes.refresh()
        archives.refresh()
    }

    @MainActor public func storeRecentRule(_ ruleModel: RuleModel) {
        settings.recentRuleIds.insert(ruleModel.id, at: 0)
        settings.recentRuleIds.truncate(Settings.maximumRecentRuleCount)
    }

    @MainActor public func move(_ sourceURL: URL, to destinationURL: URL) throws {

        // Move the file.
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: destinationURL.deletingLastPathComponent(),
                                        withIntermediateDirectories: true,
                                        attributes: [:])
        try fileManager.moveItem(at: sourceURL, to: destinationURL)

        // Update directory models.
        let sourceDirectoryModels = directories.filter { directoryModel in
            directoryModel.url.isParent(of: sourceURL)
        }
        let destinationDirectoryModels = directories.filter { directoryModel in
            directoryModel.url.isParent(of: destinationURL)
        }
        for directoryModel in sourceDirectoryModels {
            directoryModel.remove(sourceURL)
        }
        for directoryModel in destinationDirectoryModels {
            directoryModel.add(destinationURL)
        }
    }

}
