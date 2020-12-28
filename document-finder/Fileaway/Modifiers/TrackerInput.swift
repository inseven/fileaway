//
//  TrackerInput.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import SwiftUI

struct TrackerInput<T>: ViewModifier where T: Hashable {

    var tracker: SelectionTracker<T>

    func body(content: Content) -> some View {
        content
            .onMoveCommand { direction in
                print("tracker = \(tracker), direction = \(direction)")
                switch direction {
                case .up:
                    _ = tracker.handleDirectionUp()
                case .down:
                    _ = tracker.handleDirectionDown()
                default:
                    return
                }
            }
    }

}
