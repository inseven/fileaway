// Copyright (c) 2018-2021 InSeven Limited
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

import FileawayCore

extension Component {

    init(_ state: ComponentState) {
        self.init(type: state.type, value: state.value)
    }

}

class ComponentState: ObservableObject, Identifiable {

    var id = UUID() // TODO: Why doesn't this work if it's a let.
    @Published var value: String
    @Published var type: ComponentType
    var variable: VariableState? = nil

    init(value: String, type: ComponentType, variable: VariableState?) {
        self.value = value
        self.type = type
        self.variable = variable
    }

    init(_ component: Component, variable: VariableState?) {
        value = component.value
        type = component.type
        self.variable = variable
    }

    init(_ component: ComponentState, variable: VariableState?) {
        id = component.id
        value = String(component.value)
        type = component.type
        self.variable = variable
    }

    func update() {
        guard let variable = self.variable else {
            return
        }
        self.value = variable.name
    }

}
