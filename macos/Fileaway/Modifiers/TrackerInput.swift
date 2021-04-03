//
//  TrackerInput.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import SwiftUI

struct TrackerInput<T>: ViewModifier where T: Hashable, T: Identifiable {

    var tracker: SelectionTracker<T>

    func body(content: Content) -> some View {
        ScrollViewReader { scrollView in
            content
                .onMoveCommand { direction in
                    print("tracker = \(tracker), direction = \(direction)")
                    switch direction {
                    case .up:
                        guard let previous = tracker.handleDirectionUp() else {
                            return
                        }
                        scrollView.scrollTo(previous.id)
                    case .down:
                        guard let next = tracker.handleDirectionDown() else {
                            return
                        }
                        scrollView.scrollTo(next.id)
                    default:
                        return
                    }
                }
        }
    }

}
