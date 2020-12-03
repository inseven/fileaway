//
//  Manager.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 02/12/2020.
//

import AppKit
import Foundation
import Combine

class Manager: ObservableObject {

    var settings = Settings()

    @Published var locations: [URL] = []
    @Published var inbox: DirectoryObserver? = nil
    @Published var archive: DirectoryObserver? = nil

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
            guard let inbox = self.inbox else {
                NSApp.dockTile.badgeLabel = ""
                return
            }
            NSApp.dockTile.badgeLabel = "\(inbox.files.count)"
        })

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
