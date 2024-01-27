// Copyright (c) 2018-2024 Jason Morley
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

import Foundation
import SwiftUI

public class ComponentModel: ObservableObject, Identifiable, Hashable {

    public let id: UUID
    @Published public var value: String
    @Published public var type: ComponentType
    public var variable: VariableModel? = nil

    public init(value: String, type: ComponentType, variable: VariableModel? = nil) {
        self.id = UUID()
        self.value = value
        self.type = type
        self.variable = variable
    }

    public init(_ component: Component, variable: VariableModel?) {
        self.id = UUID()
        self.value = component.value
        self.type = component.type
        self.variable = variable
    }

    public init(_ componentModel: ComponentModel, variable: VariableModel?) {
        id = componentModel.id
        value = String(componentModel.value)
        type = componentModel.type
        self.variable = variable
    }

    public func update() {
        guard let variable = self.variable else {
            return
        }
        self.value = variable.name
    }

    public static func == (lhs: ComponentModel, rhs: ComponentModel) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

extension Component {

    public init(_ state: ComponentModel) {
        self.init(type: state.type, value: state.value)
    }

}
