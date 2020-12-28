//
//  RuleInstance.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 13/12/2020.
//

import Combine
import SwiftUI

class RuleInstance: ObservableObject {

    var url: URL  // TODO: This should be on the rule
    var rule: Rule
    var variables: [VariableInstance]
    var subscriptions: [Cancellable]?

    var name: String { rule.name }

    init(url: URL, rule: Rule) {
        self.url = url
        self.rule = rule
        let variables = rule.configuration.variables.map { $0.instance() }
        self.variables = variables
        self.subscriptions = variables.map { $0 as! Observable }.map { $0.observe { self.objectWillChange.send() } }
    }

    func variable(for name: String) -> TextProvider? {
        guard let variable = variables.first(where: { $0.name == name }) else {
            return nil
        }
        return variable as? TextProvider
    }

    func destination(for url: URL) -> URL {
        let destination = rule.configuration.destination.reduce("") { (result, component) -> String in
            switch component.type {
            case .text:
                return result.appending(component.value)
            case .variable:
                guard let variable = variable(for: component.value) else {
                    return result
                }
                return result.appending(variable.textRepresentation)
            }
        }
        return self.url.appendingPathComponent(destination).appendingPathExtension(url.pathExtension)
    }

    func move(url: URL) throws {
        let destinationUrl = self.destination(for: url)
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: destinationUrl.deletingLastPathComponent(),
                                        withIntermediateDirectories: true,
                                        attributes: [:])
        try fileManager.moveItem(at: url, to: destinationUrl)
    }

}