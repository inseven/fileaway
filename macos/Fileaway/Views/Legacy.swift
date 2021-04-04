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

import Combine
import SwiftUI

import Introspect

protocol TextProvider {
    var textRepresentation: String { get }
}

protocol Observable {
    func observe(_ onChange: @escaping () -> Void) -> AnyCancellable
}

protocol VariableProvider: TextProvider, Observable, ObservableObject {

}

extension Variable {

    func instance() -> VariableInstance {
        switch self.type {
        case .string:
            return StringInstance(variable: self, initialValue: "")
        case .date:
            return DateInstance(variable:self, initialValue: Date())
        }
    }

}

struct VariableDateView: View {

    @ObservedObject var variable: DateInstance

    var body: some View {
        DatePicker("", selection: $variable.date, displayedComponents: [.date])
            .padding(.leading, -8)
            .frame(maxWidth: .infinity)
    }

}

struct VariableStringView: View {

    @StateObject var variable: StringInstance
    @State var string: String = ""

    var body: some View {
        TextField("", text: $variable.string)
    }

}
