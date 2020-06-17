//
//  URL+Utilities.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation

extension URL {

    var lastPathComponent: String {
        get {
            self.absoluteString.lastPathComponent
        }
    }

}
