//
//  View.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 14/02/2021.
//

import SwiftUI

import Interaction

extension View {

    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

}
