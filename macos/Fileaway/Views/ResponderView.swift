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

struct ResponderView: NSViewRepresentable {

    class Coordinator: NSObject {
        var parent: ResponderView

        init(_ parent: ResponderView) {
            self.parent = parent
        }

        func didBecomeFirstResponder() { self.parent.firstResponder = true }
        func didResignFirstResponder() { self.parent.firstResponder = false }
        func shouldBeFirstResponder() -> Bool { self.parent.firstResponder }
        func keyDown(with event: NSEvent) -> Bool { return self.parent.keyDown(with: event) }
        func keyUp(with event: NSEvent) -> Bool { return self.parent.keyUp(with: event) }
    }

    class KeyboardView: NSView {

        weak var delegate: Coordinator?
        var isFirstResponder: Bool = false

        override var acceptsFirstResponder: Bool { return true }

        func updateResponder() {
            guard let window = window,
                  let delegate = delegate else {
                print("ignoring responder update for orphan view")
                return
            }
            let shouldBeFirstResponder = delegate.shouldBeFirstResponder()
            guard isFirstResponder != shouldBeFirstResponder else {
                return
            }
            if shouldBeFirstResponder {
                window.makeFirstResponder(self)
            } else {
                window.resignFirstResponder()
            }
        }

        override func becomeFirstResponder() -> Bool {
            isFirstResponder = true
            if let delegate = delegate {
                delegate.didBecomeFirstResponder()
            }
            return true
        }

        override func resignFirstResponder() -> Bool {
            isFirstResponder = false
            if let delegate = delegate {
                delegate.didResignFirstResponder()
            }
            return true
        }

        override func keyDown(with event: NSEvent) {
            guard let delegate = delegate else {
                super.keyDown(with: event)
                return
            }
            if !delegate.keyDown(with: event) {
                super.keyDown(with: event)
            }
        }

        override func keyUp(with event: NSEvent) {
            guard let delegate = delegate else {
                super.keyUp(with: event)
                return
            }
            if !delegate.keyUp(with: event) {
                super.keyUp(with: event)
            }
        }
    }

    @Environment(\.keyDownHandlers) var keyDownHandlers;
    @Environment(\.keyUpHandlers) var keyUpHandlers;
    @Binding var firstResponder: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> KeyboardView {
        let keyboardView = KeyboardView(frame: .zero)
        keyboardView.delegate = context.coordinator
        return keyboardView
    }

    func updateNSView(_ view: KeyboardView, context: Context) {
        DispatchQueue.main.async {
            view.updateResponder()
        }
    }

    func keyDown(with event: NSEvent) -> Bool {
        for handler in keyDownHandlers {
            if handler(event) {
                return true
            }
        }
        return false
    }

    func keyUp(with event: NSEvent) -> Bool {
        for handler in keyUpHandlers {
            if handler(event) {
                return true
            }
        }
        return false
    }

}
