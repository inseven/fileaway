//
//  Selectable.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/02/2021.
//

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
