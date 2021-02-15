//
//  ContextMenuFocusable.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/02/2021.
//

import SwiftUI

struct ContextMenuFocusKey: EnvironmentKey {

    static var defaultValue: Bool = false

}

extension EnvironmentValues {

    var hasContextMenuFocus: Bool {
        get { self[ContextMenuFocusKey.self] }
        set { self[ContextMenuFocusKey.self] = newValue }
    }

}

struct ContextMenuFocusable<MenuItems>: ViewModifier where MenuItems : View {

    let menuItems: () -> MenuItems
    let onContextMenuChange: (Bool) -> Void

    @State var isShowingContextMenu: Bool = false

    func body(content: Content) -> some View {
        ZStack {
            RightClickableSwiftUIView { showingContextMenu in
                isShowingContextMenu = showingContextMenu
                onContextMenuChange(showingContextMenu)
            }
            content
                .allowsHitTesting(false)
        }
        .contextMenu(menuItems: menuItems)
        .environment(\.hasContextMenuFocus, isShowingContextMenu)
    }

}

