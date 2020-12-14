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
                    tracker.handleDirectionUp()
                case .down:
                    tracker.handleDirectionDown()
                default:
                    return
                }
            }
    }

}
