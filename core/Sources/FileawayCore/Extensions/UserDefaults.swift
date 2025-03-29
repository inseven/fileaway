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

import CryptoKit
import Foundation

extension UserDefaults {

    public func securityScopeURLs(forKey defaultName: String) throws -> [URL] {
#if os(macOS)
        guard let urls = UserDefaults.standard.array(forKey: defaultName) as? [Data] else {
            throw FileawayError.corruptSettings
        }
        return try urls.map { try $0.asSecurityScopeUrl() }
#else
        guard let values = UserDefaults.standard.array(forKey: defaultName) as? [String] else {
            throw FileawayError.corruptSettings
        }
        let urls = try values.map { value in
            let originalURL = URL(string: value)!
            let data = try URL.bookmarkData(withContentsOf: originalURL.bookmarkURL)
            var isStale = true
            let url = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
            try url.prepareForSecureAccess()
            return url
        }
        return urls
#endif
    }

    public func setSecurityScopeURLs(_ urls: [URL], forKey defaultName: String) throws {
#if os(macOS)
        let bookmarks = try urls.map { try $0.securityScopeBookmarkData() }
        UserDefaults.standard.set(bookmarks, forKey: defaultName)
#else
        for url in urls {
            let data = try url.bookmarkData(options: .suitableForBookmarkFile,
                                            includingResourceValuesForKeys: nil,
                                            relativeTo: nil)
            try URL.writeBookmarkData(data, to: url.bookmarkURL)
        }
        UserDefaults.standard.set(urls.map { $0.absoluteString }, forKey: defaultName)
#endif
    }

    public func setCodable(_ codable: Codable, forKey defaultName: String) throws {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(codable) {
            set(encoded, forKey: defaultName)
        }
    }

    public func codable<T: Codable>(_ type: T.Type, forKey defaultName: String) throws -> T? {
        guard let object = object(forKey: defaultName) as? Data else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: object)
    }

}
