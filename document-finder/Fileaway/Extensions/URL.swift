//
//  URL.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 02/12/2020.
//

import Foundation

extension URL {

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

}

extension URL: Identifiable {

    public var id: URL { self }
    
}
