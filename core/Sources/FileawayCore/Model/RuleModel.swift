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

import SwiftUI

public class RuleModel: ObservableObject, Identifiable, CustomStringConvertible, Hashable {

    public enum NameFormat {
        case long
        case short
    }

    public let id: UUID
    public let rootUrl: URL

    @Published public var name: String
    @Published public var variables: [VariableModel]
    @Published public var destination: [ComponentModel]

    var variablesBackChannel: BackChannel<VariableModel>?
    var destinationBackChannel: BackChannel<ComponentModel>?

    public var description: String {
        return self.name
    }

    public var folder: ComponentModel {
        get {
            return destination.first ?? ComponentModel(value: "", type: .text)
        }
        set {
            if destination.isEmpty {
                destination.append(newValue)
            } else {
                destination[0] = newValue
            }
        }
    }

    public var filename: [ComponentModel] {
        get {
            return Array(destination[1...])
        }
        set {
            destination = [destination[0]] + newValue
        }
    }

    public init(id: UUID, rootUrl: URL, name: String, variables: [VariableModel], destination: [ComponentModel]) {
        self.id = id
        self.rootUrl = rootUrl
        self.name = name
        self.variables = variables
        self.destination = destination
        for component in destination {
            guard case .variable = component.type else {
                continue
            }
            let variable = variables.first { $0.name == component.value }
            component.variable = variable
        }
        self.establishBackChannel()
    }

    public convenience init(_ ruleModel: RuleModel) {
        self.init(id: ruleModel.id,
                  rootUrl: ruleModel.rootUrl,
                  name: String(ruleModel.name),
                  variables: ruleModel.variables,
                  destination: ruleModel.destination.map { ComponentModel($0, variable: nil) })
    }

    public convenience init(id: UUID, ruleModel: RuleModel) {
        self.init(id: id,
                  rootUrl: ruleModel.rootUrl,
                  name: String(ruleModel.name),
                  variables: ruleModel.variables,
                  destination: ruleModel.destination.map { ComponentModel($0, variable: nil) })
    }

    public convenience init(rootUrl: URL, rule: Rule) {
        self.init(id: rule.id,
                  rootUrl: rootUrl,
                  name: rule.name,
                  variables: rule.variables,
                  destination: rule.destination.map { component in
            ComponentModel(component, variable: rule.variables.first { $0.name == component.value } )
        })
    }

    public func reset(to ruleModel: RuleModel) {
        name = String(ruleModel.name)
        variables = ruleModel.variables
        destination = ruleModel.destination
    }

    public func establishBackChannel() {
        variablesBackChannel = BackChannel(value: variables, publisher: $variables).bind {
            self.objectWillChange.send()
            DispatchQueue.main.async {
                for component in self.destination {
                    component.update()
                }
            }
        }
        destinationBackChannel = BackChannel(value: destination, publisher: $destination).bind {
            self.objectWillChange.send()
        }
    }

    public func remove(componentModel: ComponentModel) {
        destination.removeAll { $0 == componentModel }
    }

    public func remove(variable: VariableModel) {
        variables.removeAll { $0 == variable }
    }

    public func remove(variableOffsets: IndexSet) {
        let remove = variableOffsets.map { variables[$0] }
        for variable in remove {
            destination.removeAll { $0.type == .variable && $0.value == variable.name }
        }
        variables.remove(atOffsets: variableOffsets)
    }

    public func remove(variableIds: Set<VariableModel.ID>) {
        variables.removeAll { variableIds.contains($0.id) }
    }

    public func name(for component: ComponentModel, format: NameFormat = .long) -> String {
        switch component.type {
        case .text:
            return component.value
        case .variable:
            guard let variable = variable(for: component) else {
                return "\(component.value) (Missing)"
            }
            switch (variable.type, format) {
            case (.date(hasDay: true), .long):
                return variable.name + " (YYYY-mm-dd)"
            case (.date(hasDay: true), .short):
                return "YYYY-mm-dd"
            case (.date(hasDay: false), .long):
                return variable.name + " (YYYY-mm)"
            case (.date(hasDay: false), .short):
                return "YYYY-mm"
            case (.string, .long), (.string, .short):
                return variable.name
            }
        }
    }

    public func variable(for component: ComponentModel) -> VariableModel? {
        guard component.type == .variable else {
            return nil
        }
        return variables.first { $0.name == component.value }
    }

    public func color(for component: ComponentModel) -> Color {
        guard let variable = variable(for: component) else {
            return .primary
        }
        return variable.color
    }

    public func validate() -> Bool {
        let names = Set(variables.map { $0.name })
        return names.count == variables.count && !name.isEmpty
    }

    public func createVariable() {
        let names = Set(variables.map { $0.name })
        var index = 1
        var name = ""
        repeat {
            name = "Variable \(index)"
            index = index + 1
        } while names.contains(name)
        self.variables.append(VariableModel(name: name, type: .string))
    }

    public static func == (lhs: RuleModel, rhs: RuleModel) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

extension Rule {

    public init(_ ruleModel: RuleModel) {
        self.init(id: ruleModel.id,
                  name: ruleModel.name,
                  variables: ruleModel.variables,
                  destination: ruleModel.destination.map { Component($0) })
    }

}

extension RuleList {

    init(ruleModels: [RuleModel]) {
        rules = ruleModels
            .map { Rule($0) }
    }

    func models(for rootUrl: URL) -> [RuleModel] {
        return rules
            .map { rule in
                return RuleModel(rootUrl: rootUrl, rule: rule)
            }
            .sorted { $0.name < $1.name }
    }

}
