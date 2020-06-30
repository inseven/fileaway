//
//  ActionMenu.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 30/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct ActionMenu<Content: View>: View {

    var content: () -> Content

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            content()
        }
    }

    @inlinable public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

}
