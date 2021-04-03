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
