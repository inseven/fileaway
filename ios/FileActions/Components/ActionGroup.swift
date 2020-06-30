//
//  ActionButtonGroup.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 30/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct ActionGroup<Content: View, Footer: View>: View {

    var content: () -> Content
    var footer: Footer? = nil

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center, spacing: 4) {
                content()
            }
            footer
            .font(.footnote)
            .foregroundColor(Color.secondary)
        }
    }

    @inlinable public init(footer: Footer? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.footer = footer
        self.content = content
    }

}
