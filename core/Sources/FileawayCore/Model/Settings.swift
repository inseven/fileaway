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
import UniformTypeIdentifiers

public class Settings: ObservableObject {

    enum Key: String {
        case inboxUrls = "inbox-urls"
        case archiveUrls = "archive-urls"
        case fileTypes = "file-types"
    }

    private static let defaultFileTypes: Set<UTType> = [
        .commaSeparatedText,
        .doc,
        .docx,
        .numbers,
        .pages,
        .pdf,
        .rtf,
        .xls,
        .xlsx,
    ]

    // TODO: These are never updated during the run of the app.
    @Published public var inboxUrls: [URL] = []
    @Published public var archiveUrls: [URL] = []

    @Published public var types: Set<UTType> = [] {
        didSet {
            try? defaults.setCodable(types, for: .fileTypes)
        }
    }

    private let defaults: SafeUserDefaults<Key> = SafeUserDefaults(defaults: UserDefaults.standard)

    public init() {
        inboxUrls = (try? defaults.securityScopeURLs(for: .inboxUrls)) ?? []
        archiveUrls = (try? defaults.securityScopeURLs(for: .archiveUrls)) ?? []
        types = (try? defaults.codable(Set<UTType>.self, for: .fileTypes)) ?? Self.defaultFileTypes
    }

    public func setInboxUrls(_ urls: [URL]) throws {
        try defaults.setSecurityScopeURLs(urls, for: .inboxUrls)
    }

    public func setArchiveUrls(_ urls: [URL]) throws {
        try defaults.setSecurityScopeURLs(urls, for: .archiveUrls)
    }

}
