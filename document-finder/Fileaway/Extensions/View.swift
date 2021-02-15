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

    func onClick(_ click: @escaping () -> Void, doubleClick: @escaping () -> Void) -> some View {
        return gesture(TapGesture()
                        .onEnded(click)
                        .simultaneously(with: TapGesture(count: 2)
                                            .onEnded(doubleClick)))
    }

    func onShiftClick(_ action: @escaping () -> Void) -> some View {
        return highPriorityGesture(TapGesture(count: 1)
                                    .modifiers(EventModifiers.shift).onEnded(action))
    }

    func onCommandClick(_ action: @escaping () -> Void) -> some View {
        return highPriorityGesture(TapGesture(count: 1)
                                    .modifiers(EventModifiers.command).onEnded(action))
    }

}
