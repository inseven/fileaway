//
//  StorageManager.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 09/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Foundation

enum StorageManagerError: Error {
    case pathError(_ message: String)
    case accessError(_ message: String)
}

extension URL {

    func prepareForSecureAccess() throws {
        guard startAccessingSecurityScopedResource() else {
            throw StorageManagerError.accessError("Unable to access security scoped resource")
        }
        guard FileManager.default.isReadableFile(atPath: path) else {
            throw StorageManagerError.accessError("Unable to read directory at path")
        }
    }

}

class StorageManager {

    static func documentUrl() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    static func bookmarkUrl() -> URL? {
        return documentUrl()?.appendingPathComponent("Root")
    }

    static func configurationUrl() throws -> URL {
        return try rootUrl().appendingPathComponent("fileaway.json")
    }

    static func setRootUrl(_ url: URL) throws {
        try url.prepareForSecureAccess()
        let bookmarkData = try url.bookmarkData(options: .suitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeTo: nil)
        guard let bookmarkUrl = bookmarkUrl() else {
            throw StorageManagerError.pathError("Unable to get bookmark url")
        }
        try URL.writeBookmarkData(bookmarkData, to: bookmarkUrl)
    }

    static func rootUrl() throws -> URL {
        guard let bookmarkUrl = bookmarkUrl() else {
            throw StorageManagerError.pathError("Unable to get bookmark url")
        }
        
        let bookmarkData = try URL.bookmarkData(withContentsOf: bookmarkUrl)
        var isStale = true
        let rootUrl = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)!
        try rootUrl.prepareForSecureAccess()
        // TODO: Refresh the bookmark if it's stale?
        return rootUrl
    }

}
