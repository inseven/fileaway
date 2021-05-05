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

import SwiftUI

enum StorageManagerError: Error {
    case accessError(_ message: String)
}

// TODO: URL type in here?

extension URL {

    init(securityScopeBookmarkData: Data) throws {
        var isStale = true
        try self.init(resolvingBookmarkData: securityScopeBookmarkData,
                      options: .withSecurityScope,
                      bookmarkDataIsStale: &isStale)
        if !startAccessingSecurityScopedResource() {
            throw StorageManagerError.accessError("Failed access inbox url with security scope")
        }
    }

    func securityScopeBookmarkData() throws -> Data {
        try bookmarkData(options: .withSecurityScope,
                             includingResourceValuesForKeys: nil,
                             relativeTo: nil)
    }

}

extension Data {

    func asSecurityScopeUrl() throws -> URL {
        try URL(securityScopeBookmarkData: self)
    }

}

extension UserDefaults {

    func securityScopeUrls(forKey defaultName: String) throws -> [URL] {
        guard let urls = UserDefaults.standard.array(forKey: defaultName) as? [Data] else {
            // TODO THrow something!
            return []
        }
        return try urls.map { try $0.asSecurityScopeUrl() }
    }

}

class Settings: ObservableObject {

    static let archiveUrl = "archive-url"
    static let inboxUrls = "inbox-urls"
    static let archiveUrls = "archive-urls"

    @Published var inboxUrls: [URL] = []
    @Published var archiveUrls: [URL] = []

    init() {
        inboxUrls = (try? UserDefaults.standard.securityScopeUrls(forKey: Self.inboxUrls)) ?? []
        archiveUrls = (try? UserDefaults.standard.securityScopeUrls(forKey: Self.archiveUrls)) ?? []
    }

    func setInboxUrls(_ urls: [URL]) throws {
        let bookmarks = try urls.map { try $0.securityScopeBookmarkData() }
        UserDefaults.standard.set(bookmarks, forKey: Self.inboxUrls);
    }

    func setArchiveUrls(_ urls: [URL]) throws {
        let bookmarks = try urls.map { try $0.securityScopeBookmarkData() }
        UserDefaults.standard.set(bookmarks, forKey: Self.archiveUrls);
    }

    func setArchiveUrl(_ url: URL) throws {
        UserDefaults.standard.set(try url.securityScopeBookmarkData(), forKey: Self.archiveUrl);
    }

    func archiveUrl() throws -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: Self.archiveUrl) else {
            throw StorageManagerError.accessError("Failed to load inbox url")
        }
        return try bookmarkData.asSecurityScopeUrl()
    }

}
