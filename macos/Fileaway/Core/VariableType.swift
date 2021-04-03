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

public enum VariableType: CaseIterable {

    case string
    case date(hasDay: Bool)

    public static var allCases: [VariableType] { [
        .string,
        .date(hasDay: true),
        .date(hasDay: false)
    ] }
}

extension VariableType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .string:
            return "String"
        case .date(hasDay: true):
            return "Day, Month, Year"
        case .date(hasDay: false):
            return "Month, Year"
        }
    }

}

extension VariableType: Identifiable, Hashable {

    public var id: String {
        switch self {
        case .string:
            return "string"
        case .date(hasDay: false):
            return "date"
        case .date(hasDay: true):
            return "date-day"
        }
    }

    public static func == (lhs: VariableType, rhs: VariableType) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
