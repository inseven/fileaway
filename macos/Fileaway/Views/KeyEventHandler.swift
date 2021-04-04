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

import SwiftUI

struct KeyDownHandlersKey: EnvironmentKey {
    static var defaultValue: [(NSEvent) -> Bool] = []
}

struct KeyUpHandlersKey: EnvironmentKey {
    static var defaultValue: [(NSEvent) -> Bool] = []
}

extension EnvironmentValues {

    var keyDownHandlers: [(NSEvent) -> Bool] {
        get { self[KeyDownHandlersKey.self] }
        set { self[KeyDownHandlersKey.self] = newValue }
    }

    var keyUpHandlers: [(NSEvent) -> Bool] {
        get { self[KeyUpHandlersKey.self] }
        set { self[KeyUpHandlersKey.self] = newValue }
    }

}

struct KeyEventHandler: ViewModifier {

    @Environment(\.keyDownHandlers) var environmentKeyDownHandlers
    @Environment(\.keyUpHandlers) var environmentKeyUpHandlers

    var keyDownHandlers: [(NSEvent) -> Bool] = []
    var keyUpHandlers: [(NSEvent) -> Bool] = []

    init(onKeyDown: ((NSEvent) -> Bool)? = nil, onKeyUp: ((NSEvent) -> Bool)? = nil) {
        if let onKeyDown = onKeyDown {
            keyDownHandlers.append(onKeyDown)
        }
        if let onKeyUp = onKeyUp {
            keyUpHandlers.append(onKeyUp)
        }
    }

    func body(content: Content) -> some View {
        content
            .environment(\.keyDownHandlers, keyDownHandlers + environmentKeyDownHandlers)
            .environment(\.keyUpHandlers, keyUpHandlers + environmentKeyUpHandlers)
    }

}

extension View {

    func onKeyDown(handler: @escaping (NSEvent) -> Bool) -> some View {
        modifier(KeyEventHandler(onKeyDown: handler))
    }

    func onKeyUp(handler: @escaping (NSEvent) -> Bool) -> some View {
        modifier(KeyEventHandler(onKeyUp: handler))
    }

    func onKey(_ characters: String, perform: @escaping () -> Void) -> some View {
        modifier(KeyEventHandler(onKeyDown: { event -> Bool in
            guard event.characters == characters else {
                return false
            }
            perform()
            return true
        }, onKeyUp: { event -> Bool in
            guard event.characters == characters else {
                return false
            }
            return true
        }))
    }

    func onKey(_ key: KeyEquivalent, modifiers: EventModifiers = [], perform: @escaping () -> Void) -> some View {
        let matches: (NSEvent) -> Bool = { event in
            let matchesKey = event.characters?.first == key.character
            let modifierFlags = modifiers.modifierFlags
            let matchesModifiers = event.modifierFlags.intersection(modifierFlags) == modifierFlags
            return matchesKey && matchesModifiers
        }
        return modifier(KeyEventHandler(onKeyDown: { event -> Bool in
            guard matches(event) else {
                return false
            }
            perform()
            return true
        }, onKeyUp: { event -> Bool in
            guard matches(event) else {
                return false
            }
            return true
        }))
    }

    func onSelectCommand(perform: @escaping () -> Void) -> some View {
        onKey(" ", perform: perform)
    }

    func onEnterCommand(perform: @escaping () -> Void) -> some View {
        onKey("\r", perform: perform)
    }

    func logKeyEvents() -> some View {
        onKeyDown { event in
            print("key down = \(event)")
            return false
        }

    }

}
