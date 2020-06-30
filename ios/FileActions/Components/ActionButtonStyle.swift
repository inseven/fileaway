//
//  ActionButtonStyle.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 30/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {

    let backgroundColor: Color
    let foregroundColor: Color

    init(backgroundColor: Color? = nil, foregroundColor: Color? = nil) {
        self.backgroundColor = backgroundColor != nil ? backgroundColor! : .accentColor
        self.foregroundColor = foregroundColor != nil ? foregroundColor! : .primary
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(backgroundColor.brightness(configuration.isPressed ? 0.2 : 0.0))
            .foregroundColor(self.foregroundColor)
            .cornerRadius(8.0)
    }
}
