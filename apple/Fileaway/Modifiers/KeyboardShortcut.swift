// Copyright (c) 2018-2025 Jason Morley
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

fileprivate struct KeyboardShortcut: ViewModifier {

    private var value: Int
    private var modifiers: EventModifiers

    init(value: Int, modifiers: EventModifiers) {
        self.value = value
        self.modifiers = modifiers
    }

    func body(content: Content) -> some View {
        if value < 10 {
            content.keyboardShortcut(KeyEquivalent(String(value).first!), modifiers: modifiers)
        } else {
            content
        }
    }

}

extension View {

    func keyboardShortcut(_ value: Int, modifiers: EventModifiers) -> some View {
        modifier(KeyboardShortcut(value: value, modifiers: modifiers))
    }

}
