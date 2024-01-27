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

import SwiftUI

extension Array where Element: Identifiable {

    public mutating func move(ids: [Element.ID], toOffset offset: Int) {
        let indexes = ids.compactMap { id in
            return firstIndex(where: { $0.id == id })
        }
        move(fromOffsets: IndexSet(indexes), toOffset: offset)
    }

    public func applying(_ other: [Element], onInsert: (Element) -> Void, onRemove: (Element) -> Void) -> [Element] {

        let enumeratedIds = enumerated().reduce(into: [Element.ID: Int]()) {
            $0[$1.1.id] = $1.0
        }
        var result: [Element] = []
        for element in other {
            if let current = enumeratedIds[element.id] {
                result.append(self[current])
            } else {
                result.append(element)
                onInsert(element)
            }
        }
        let ids = Set(self.map { $0.id })
        let otherIds = Set(other.map { $0.id })
        let removals = ids.subtracting(otherIds)
        for removal in removals {
            let index = enumeratedIds[removal]!
            onRemove(self[index])
        }

        return result
    }

}
