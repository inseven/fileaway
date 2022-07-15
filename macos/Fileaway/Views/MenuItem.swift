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

struct MenuItemItemLimitKey: EnvironmentKey {
    static var defaultValue: Int = 0
}

extension EnvironmentValues {

    var itemLimit: Int {
        get { self[MenuItemItemLimitKey.self] }
        set { self[MenuItemItemLimitKey.self] = newValue }
    }

}

struct MenuItem<Item>: View where Item: Hashable {

    @Environment(\.itemLimit) private var itemLimit

    var label: String
    var selection: Binding<Set<Item>>
    var item: Item
    var perform: (Set<Item>) -> Void

    init(_ label: String, selection: Binding<Set<Item>>, item: Item, perform: @escaping (Set<Item>) -> Void) {
        self.label = label
        self.selection = selection
        self.item = item
        self.perform = perform
    }

    var items: Set<Item> {
        if selection.wrappedValue.contains(item) {
            return selection.wrappedValue
        } else {
            return [item]
        }
    }

    var disabled: Bool {
        return itemLimit > 0 && items.count > itemLimit
    }

    var body: some View {
        Button(label) {
            self.perform(items)
        }
        .disabled(disabled)
    }

}

extension View {

    func itemLimit(_ itemLimit: Int) -> some View {
        self.environment(\.itemLimit, itemLimit)
    }

}
