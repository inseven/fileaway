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

import Interact

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
