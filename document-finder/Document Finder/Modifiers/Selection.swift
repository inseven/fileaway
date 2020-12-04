//
//  Selection.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 03/12/2020.
//

import SwiftUI

struct Selection: ViewModifier {

    var active: Bool

    func body(content: Content) -> some View {
        if active {
            return
                content
                .foregroundColor(.white)
                .background(Color.accentColor.cornerRadius(6))
                .eraseToAnyView()
        } else {
            return
                content
                .eraseToAnyView()
        }
    }
}
