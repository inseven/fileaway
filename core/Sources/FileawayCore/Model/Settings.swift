// Copyright (c) 2018-2025 Jason Morley
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

import Collections

public class Settings: ObservableObject {

    static let maximumRecentRuleCount = 3

    enum Key: String {
        case inboxUrls = "inbox-urls"
        case archiveUrls = "archive-urls"
        case fileTypes = "file-types"
        case recentRuleIds = "recent-rule-ids"
        case selectedFolderURL = "selected-folder-url"
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
    @Published public var inboxURLs: [URL] = []
    @Published public var archiveURLs: [URL] = []

    @Published public var fileTypes: Set<UTType> = [] {
        didSet {
            try? defaults.setCodable(fileTypes, for: .fileTypes)
        }
    }

    @Published public var recentRuleIds: OrderedSet<RuleModel.ID> = [] {
        didSet {
            try? defaults.setCodable(recentRuleIds, for: .recentRuleIds)
        }
    }

    @Published public var selectedFolderURL: URL? {
        didSet {
            guard let selectedFolderURL = selectedFolderURL else {
                defaults.removeObject(for: .selectedFolderURL)
                return
            }
            defaults.set(selectedFolderURL.absoluteString, for: .selectedFolderURL)
        }
    }

    private let defaults: SafeUserDefaults<Key> = SafeUserDefaults(defaults: UserDefaults.standard)

    public init() {
        inboxURLs = (try? defaults.securityScopeURLs(for: .inboxUrls)) ?? []
        archiveURLs = (try? defaults.securityScopeURLs(for: .archiveUrls)) ?? []
        fileTypes = (try? defaults.codable(Set<UTType>.self, for: .fileTypes)) ?? Self.defaultFileTypes
        recentRuleIds = (try? defaults.codable(OrderedSet<RuleModel.ID>.self, for: .recentRuleIds)) ?? []
        recentRuleIds.truncate(Settings.maximumRecentRuleCount)

        if let selectedFolderString = defaults.string(for: .selectedFolderURL) {
            selectedFolderURL = URL(string: selectedFolderString)
        }

    }

    public func setInboxUrls(_ urls: [URL]) throws {
        try defaults.setSecurityScopeURLs(urls, for: .inboxUrls)
    }

    public func setArchiveUrls(_ urls: [URL]) throws {
        try defaults.setSecurityScopeURLs(urls, for: .archiveUrls)
    }

}
