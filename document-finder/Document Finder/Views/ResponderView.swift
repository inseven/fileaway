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
    }

    class KeyboardView: NSView {

        weak var delegate: Coordinator?
        var isFirstResponder: Bool = false

        required init() {
            super.init(frame: .zero)
        }

        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

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
    }

    @Binding var firstResponder: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> KeyboardView {
        let keyboardView = KeyboardView()
        keyboardView.delegate = context.coordinator
        return keyboardView
    }

    func updateNSView(_ view: KeyboardView, context: Context) {
        DispatchQueue.main.async {
            view.updateResponder()
        }
    }

}
