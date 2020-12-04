//
//  FileManager.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 03/12/2020.
//

import Foundation

extension FileManager {

    func files(at url: URL, extensions: [String]) -> [URL] {
        var files: [URL] = []
        if let enumerator = enumerator(at: url,
                                       includingPropertiesForKeys: [.isRegularFileKey],
                                       options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                guard fileURL.matches(extensions: extensions) else {
                    continue
                }

                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        files.append(fileURL)
                    }
                } catch { print(error, fileURL) }
            }
        }
        return files
    }

}
