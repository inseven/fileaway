//
//  FilledButton.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 19/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct FilledButton: ButtonStyle {

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration
            .label
            .font(.body)
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .padding(12)
            .background(Color.accentColor)
            .cornerRadius(12)
    }
}
