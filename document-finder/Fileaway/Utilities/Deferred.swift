//
//  Deferred.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 12/12/2020.
//

import Foundation

class Deferred<T> {

    var constructor: () -> T
    var instance: T?

    init(_ constructor: @autoclosure @escaping () -> T) {
        self.constructor = constructor
    }

    func get() -> T {
        if let instance = instance {
            return instance
        }
        let instance = constructor()
        self.instance = instance
        return instance
    }

}
