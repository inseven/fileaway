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

}

extension URL: Identifiable {

    public var id: URL { self }
    
}
