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
