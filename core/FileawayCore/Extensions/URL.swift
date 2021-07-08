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

import Foundation

public extension URL {

    var displayName: String {
        FileManager.default.displayName(atPath: self.path)
    }

    init(securityScopeBookmarkData: Data) throws {
        var isStale = true
        try self.init(resolvingBookmarkData: securityScopeBookmarkData,
                      options: .withSecurityScope,
                      bookmarkDataIsStale: &isStale)
        if !startAccessingSecurityScopedResource() {
            throw FileawayError.securityScopeAccessError
        }
    }

    func matches(extensions: [String]?) -> Bool {
        guard let extensions = extensions else {
            return true
        }
        return extensions.contains(pathExtension)
    }

    var lastPathComponent: String {
        (path as NSString).lastPathComponent
    }

    var deletingLastPathComponent: URL {
        self.deletingLastPathComponent()
    }

    var pathExtension: String {
        (path as NSString).pathExtension
    }

    // TODO: review this?
    func relativePath(from base: URL) -> String? {

        guard self.isFileURL,
              base.isFileURL else {
            return nil
        }

        let destComponents = self.standardized.resolvingSymlinksInPath().pathComponents
        let baseComponents = base.standardized.resolvingSymlinksInPath().pathComponents

        var i = 0
        while i < destComponents.count && i < baseComponents.count
            && destComponents[i] == baseComponents[i] {
                i += 1
        }

        var relComponents = Array(repeating: "..", count: baseComponents.count - i)
        relComponents.append(contentsOf: destComponents[i...])
        return relComponents.joined(separator: "/")
    }

    func securityScopeBookmarkData() throws -> Data {
        try bookmarkData(options: .withSecurityScope,
                             includingResourceValuesForKeys: nil,
                             relativeTo: nil)
    }

}

extension URL: Identifiable {

    public var id: URL { self }

}
