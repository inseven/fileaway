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
        let rootUrl = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
        try rootUrl.prepareForSecureAccess()
        // TODO: Refresh the bookmark if it's stale?
        return rootUrl
    }

}
