//
//  EditSafeButton.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 19/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct EditSafeButton<Content: View>: View {

    var action: () -> Void
    let content: () -> Content

    var body: some View {
        HStack {
            Button(action: {}) {
                content()
            }
        }
        .onTapGesture(perform: action)
    }

    @inlinable public init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }

}
