//
//  String.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 03/12/2020.
//

import Foundation

extension String {

    var deletingPathExtension: String {
        (self as NSString).deletingPathExtension
    }

    var tokens: [String] {
        components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    func localizedSearchMatches(string: String) -> Bool {
        for token in string.tokens {
            if !localizedStandardContains(token) {
                return false
            }
        }
        return true
    }

}
