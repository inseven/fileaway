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

