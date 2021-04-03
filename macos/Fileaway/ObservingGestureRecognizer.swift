//
//  ObservingGestureRecognizer.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/02/2021.
//

import AppKit

class ObservingGestureRecognizer: NSGestureRecognizer {

    var onRightMouseDown: (() -> Void)?

    init(onRightMouseDown: @escaping () -> Void) {
        super.init(target: nil, action: nil)
        self.onRightMouseDown = onRightMouseDown
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func rightMouseDown(with event: NSEvent) {
        defer { self.state = .failed }
        guard let view = view else {
            return
        }
        let mouseLocation = view.convert(event.locationInWindow, from: nil)
        guard view.bounds.contains(mouseLocation) else {
            return
        }
        if let onRightMouseDown = onRightMouseDown {
            onRightMouseDown()
        }
        super.rightMouseDown(with: event)
    }

}
