//
//  Settings.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 02/12/2020.
//

import SwiftUI

enum StorageManagerError: Error {
    case accessError(_ message: String)
}

class Settings: ObservableObject {

    static let inboxUrl = "inbox-url"
    static let archiveUrl = "archive-url"

    func setInboxUrl(_ url: URL) throws {
        let bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: nil)
        UserDefaults.standard.set(bookmarkData, forKey: Self.inboxUrl);
    }

    func inboxUrl() throws -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: Self.inboxUrl) else {
            throw StorageManagerError.accessError("Failed to load inbox url")
        }
        var isStale = true
        let url = try URL(resolvingBookmarkData: bookmarkData,
                          options: .withSecurityScope,
                          bookmarkDataIsStale: &isStale)
        if !url.startAccessingSecurityScopedResource() {
            throw StorageManagerError.accessError("Failed access inbox url with security scope")
        }
        return url
    }

    func setArchiveUrl(_ url: URL) throws {
        let bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: nil)
        UserDefaults.standard.set(bookmarkData, forKey: Self.archiveUrl);
    }

    func archiveUrl() throws -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: Self.archiveUrl) else {
            throw StorageManagerError.accessError("Failed to load inbox url")
        }
        var isStale = true
        let url = try URL(resolvingBookmarkData: bookmarkData,
                          options: .withSecurityScope,
                          bookmarkDataIsStale: &isStale)
        if !url.startAccessingSecurityScopedResource() {
            throw StorageManagerError.accessError("Failed access inbox url with security scope")
        }
        return url
    }

}
