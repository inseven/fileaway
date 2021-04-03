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

import Interact

// TODO: This should be a view modifier.
// TODO: Move to Interact
struct Selectable<Content: View>: View {

    var isFocused: Bool  // TODO: Environment variable?
    var isSelected: Bool
    var radius: CGFloat
    var corners: RectCorner
    private let content: () -> Content
    @Environment(\.hasContextMenuFocus) var hasContextMenuFocus

    var borderWidth: CGFloat { isSelected ? 2 : 3 }
    var borderColor: Color { isSelected ? Color.white : highlightColor }
    var borderPadding: CGFloat { isSelected ? 2 : 0 }
    var borderRadius: CGFloat { radius + (borderWidth / 2) - borderPadding }
    var highlightColor: Color { isFocused ? Color.selectedContentBackgroundColor : Color.unemphasizedSelectedContentBackgroundColor }
    var activeCorners: RectCorner { isSelected ? corners : RectCorner.all }

    init(isFocused: Bool, isSelected: Bool, radius: CGFloat, corners: RectCorner, @ViewBuilder _ content: @escaping () -> Content) {
        self.isFocused = isFocused
        self.isSelected = isSelected
        self.radius = radius
        self.corners = corners
        self.content = content
    }

    var body: some View {
        ZStack {
            if isSelected { highlightColor
            }
            content()
            if hasContextMenuFocus {
                RoundedRectangle(cornerRadius: borderRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
                    .padding(borderPadding)
            }
        }
        .cornerRadius(radius, corners: activeCorners)
        .contentShape(Rectangle())
        .onChange(of: hasContextMenuFocus) { hasContextMenuFocus in
            print("focus = \(hasContextMenuFocus)")
        }
    }
}
