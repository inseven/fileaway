//
//  StorageManager.swift
//  File Actions
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
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: documentsUrl.path) {
            try! fileManager.createDirectory(at: documentsUrl, withIntermediateDirectories: true, attributes: nil)
        }
        return documentsUrl
    }

    static func bookmarkUrl() -> URL? {
        return documentUrl()?.appendingPathComponent("Root")
    }

    static func configurationUrl() throws -> URL {
        return try rootUrl().appendingPathComponent("file-actions.json")
    }

    static func setRootUrl(_ url: URL) throws {
        try url.prepareForSecureAccess()
        let bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: nil)
        UserDefaults.standard.set(bookmarkData, forKey: "root");
    }

    static func rootUrl() throws -> URL {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "root") else {
            throw StorageManagerError.accessError("No data!")
        }
        var isStale = true
        let rootUrl = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)!
        try rootUrl.prepareForSecureAccess()
        // TODO: Refresh the bookmark if it's stale?
        return rootUrl
    }

}
