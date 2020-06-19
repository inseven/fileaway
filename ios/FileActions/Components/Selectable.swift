//
//  Selectable.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 19/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct Selectable<Content: View>: View {

    let isSelected: Bool
    let action: () -> Void
    let content: () -> Content

    var body: some View {
        HStack {
            Button(action: action) {
                content()
            }
            .foregroundColor(.primary)
            if isSelected {
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
    }

    @inlinable public init(isSelected: Bool, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.isSelected = isSelected
        self.action = action
        self.content = content
    }

}
