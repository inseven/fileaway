//
//  ResponderView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 05/12/2020.
//

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
                print("no changes to be made")
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
