// Copyright (c) 2018-2024 Jason Morley
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

class SafeUserDefaults<Key: RawRepresentable<String>> {

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public func removeObject(for key: Key) {
        defaults.removeObject(forKey: key.rawValue)
    }

    public func set(_ value: Any?, for key: Key) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    public func url(for key: Key) -> URL? {
        return defaults.url(forKey: key.rawValue)
    }

    public func string(for key: Key) -> String? {
        return defaults.string(forKey: key.rawValue)
    }

    public func setCodable(_ codable: Codable, for key: Key) throws {
        try defaults.setCodable(codable, forKey: key.rawValue)
    }

    public func codable<T: Codable>(_ type: T.Type, for key: Key) throws -> T? {
        return try defaults.codable(T.self, forKey: key.rawValue)
    }

    public func setSecurityScopeURLs(_ urls: [URL], for key: Key) throws {
        return try defaults.setSecurityScopeURLs(urls, forKey: key.rawValue)
    }

    public func securityScopeURLs(for key: Key) throws -> [URL] {
        return try defaults.securityScopeURLs(forKey: key.rawValue)
    }
}
