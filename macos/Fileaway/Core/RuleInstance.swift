// Copyright (c) 2018-2022 InSeven Limited
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

import Combine
import SwiftUI

import FileawayCore

class RuleInstance: ObservableObject {

    var rule: Rule
    var variables: [VariableInstance]
    var subscriptions: [Cancellable]?

    var name: String { rule.name }

    init(rule: Rule) {
        self.rule = rule
        let variables = rule.variables.map { $0.instance() }
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
        let destination = rule.destination.reduce("") { (result, component) -> String in
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
        return self.rule.rootUrl.appendingPathComponent(destination).appendingPathExtension(url.pathExtension)
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
