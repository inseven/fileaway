//
//  Manager.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 02/12/2020.
//

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
        }
    }

    func setInboxUrl(_ url: URL) throws {
        try settings.setInboxUrl(url)
        self.createInboxObserver(url: url)
    }

    func setArchiveUrl(_ url: URL) throws {
        try settings.setArchiveUrl(url)
        self.createArchiveObserver(url: url)
    }

}
