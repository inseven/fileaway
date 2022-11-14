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

struct FilledButton: ButtonStyle {

    private struct LayoutMetrics {
        static let padding = 4.0
        static let trailingPadding = 8.0
        static let interItemSpcing = 2.0
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack(spacing: LayoutMetrics.interItemSpcing) {
            Image(systemName: "plus.circle")
            configuration
                .label
        }
        .font(.footnote)
        .foregroundColor(configuration.isPressed ? .gray : .white)
        .padding([.leading, .top, .bottom], LayoutMetrics.padding)
        .padding([.trailing], LayoutMetrics.trailingPadding)
        .background(Capsule()
            .fill(.tint))
    }
    
}
