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

import SwiftUI

public class Settings: ObservableObject {

    static let inboxUrls = "inbox-urls"
    static let archiveUrls = "archive-urls"

    @Published public var inboxUrls: [URL] = []
    @Published public var archiveUrls: [URL] = []

    public init() {
        inboxUrls = (try? UserDefaults.standard.securityScopeUrls(forKey: Self.inboxUrls)) ?? []
        archiveUrls = (try? UserDefaults.standard.securityScopeUrls(forKey: Self.archiveUrls)) ?? []
    }

    public func setInboxUrls(_ urls: [URL]) throws {
        let bookmarks = try urls.map { try $0.securityScopeBookmarkData() }
        UserDefaults.standard.set(bookmarks, forKey: Self.inboxUrls);
    }

    public func setArchiveUrls(_ urls: [URL]) throws {
        let bookmarks = try urls.map { try $0.securityScopeBookmarkData() }
        UserDefaults.standard.set(bookmarks, forKey: Self.archiveUrls);
    }

}
