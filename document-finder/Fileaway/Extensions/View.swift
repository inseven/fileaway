//
//  View.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/02/2021.
//

import SwiftUI

extension View {

    func contextMenuFocusable<MenuItems>(@ViewBuilder menuItems: @escaping () -> MenuItems, onContextMenuChange: @escaping (Bool) -> Void) -> some View where MenuItems : View {
        return self
            .modifier(ContextMenuFocusable(menuItems: menuItems, onContextMenuChange: onContextMenuChange))
    }

    func contextMenuFocusable<MenuItems>(@ViewBuilder menuItems: @escaping () -> MenuItems) -> some View where MenuItems : View {
        return self.contextMenuFocusable(menuItems: menuItems) { _ in }
    }

}
