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

import CryptoKit
import Foundation
import SwiftUI

extension URL {

    // Stable file URL that can be used to store the URL as bookmark data.
    public var bookmarkURL: URL {
        let identifier = Insecure.MD5.hash(data: self.absoluteString.data(using: .utf8) ?? Data()).map {
            String(format: "%02hhx", $0)
        }.joined()
        let bookmarkURL = FileManager.default.libraryURL.appendingPathComponent(identifier)
        return bookmarkURL
    }

    public var deletingLastPathComponent: URL {
        self.deletingLastPathComponent()
    }

    public var rulesUrl: URL {
        return appendingPathComponent("Rules.fileaway")
    }

    public func matches(extensions: [String]?) -> Bool {
        guard let extensions = extensions else {
            return true
        }
        return extensions.contains(pathExtension)
    }

    // TODO: review this?
    public func relativePath(from base: URL) -> String? {

        guard self.isFileURL,
              base.isFileURL else {
            return nil
        }

        let destComponents = self.pathComponents
        let baseComponents = base.pathComponents

        var i = 0
        while i < destComponents.count && i < baseComponents.count
            && destComponents[i] == baseComponents[i] {
                i += 1
        }

        var relComponents = Array(repeating: "..", count: baseComponents.count - i)
        relComponents.append(contentsOf: destComponents[i...])
        return relComponents.joined(separator: "/")
    }

    public func isParent(of url: URL) -> Bool {
        return url.path.hasPrefix(path + "/")
    }

    public func prepareForSecureAccess() throws {
#if os(macOS)
        let _ = try securityScopeBookmarkData()  // Check that we can access the location.
#else
        guard startAccessingSecurityScopedResource() else {
            throw FileawayError.accessError
        }
        guard FileManager.default.isReadableFile(atPath: path) else {
            throw FileawayError.pathError
        }
#endif
    }


}

extension URL: Identifiable {

    public var id: URL { self }

}

#if os(macOS)

extension URL {

    public init(securityScopeBookmarkData: Data) throws {
        var isStale = true
        try self.init(resolvingBookmarkData: securityScopeBookmarkData,
                      options: .withSecurityScope,
                      bookmarkDataIsStale: &isStale)
        if !startAccessingSecurityScopedResource() {
            throw FileawayError.accessError
        }
    }

    public func securityScopeBookmarkData() throws -> Data {
        try bookmarkData(options: .withSecurityScope,
                             includingResourceValuesForKeys: nil,
                             relativeTo: nil)
    }

}

#endif
