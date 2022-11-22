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

import Interact

public class RuleFormModel: ObservableObject, Runnable {

    private let ruleModel: RuleModel
    private let url: URL
    @Published public var variableFieldModels: [VariableFieldModel]

    private var subscriptions: [Cancellable] = []

    @MainActor public var name: String {
        return ruleModel.name
    }

    @MainActor public var destinationURL: URL {
        let destination = ruleModel.destination.reduce("") { (result, component) -> String in
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
        return self.ruleModel.rootUrl.appendingPathComponent(destination).appendingPathExtension(url.pathExtension)
    }

    public init(ruleModel: RuleModel, url: URL) {
        self.ruleModel = ruleModel
        self.url = url
        self.variableFieldModels = ruleModel.variables.map { $0.instance() }
    }

    @MainActor public func start() {
        subscriptions = variableFieldModels
            .map { $0 as! (any Editable) }
            .map { $0.observe { [weak self] in
                dispatchPrecondition(condition: .onQueue(.main))
                guard let self = self else {
                    return
                }
                self.objectWillChange.send()
            } }
    }

    @MainActor public func stop() {
        subscriptions.removeAll()
    }

    @MainActor public func variable(for name: String) -> (any Editable)? {
        guard let variable = variableFieldModels.first(where: { $0.name == name }) else {
            return nil
        }
        return variable as? any Editable
    }

    // TODO: Handle this error within the model.
    @MainActor public func move() throws {
        let destinationUrl = self.destinationURL
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: destinationUrl.deletingLastPathComponent(),
                                        withIntermediateDirectories: true,
                                        attributes: [:])
        try fileManager.moveItem(at: url, to: destinationUrl)
    }

}
