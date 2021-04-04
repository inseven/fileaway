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

import FileawayCore

extension Variable {

    init(_ state: VariableState) {
        self.init(name: state.name, type: state.type)
    }
    
}

class VariableState: ObservableObject, Identifiable {

    var id = UUID()
    @Published var name: String
    @Published var type: VariableType

    public init(_ variable: Variable) {
        self.name = variable.name
        self.type = variable.type
    }

    // TODO: This should generate a new ID, and there should be explicit setters if we're setting variables.
    public init(_ variable: VariableState) {
        id = variable.id // TODO: Check why this uses the same id!
        name = String(variable.name)
        type = variable.type
    }

    public init(name: String, type: VariableType) {
        self.name = name
        self.type = type
    }
}
