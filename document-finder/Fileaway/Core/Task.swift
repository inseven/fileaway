//
//  Task.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import Foundation

class Task: Identifiable, Hashable {

    var id = UUID()
    let name: String
    let configuration: Configuration

    init(name: String) {
        self.name = name
        self.configuration = Configuration(variables: [], destination: [])
    }

    init(name: String, configuration: Configuration) {
        self.name = name
        self.configuration = configuration
    }

    // TODO: Flesh these out

    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
