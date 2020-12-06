//
//  AcceptsFirstResponder.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 06/12/2020.
//

import SwiftUI

struct AcceptsFirstResponder: ViewModifier {

    @Binding var isFirstResponder: Bool

    func body(content: Content) -> some View {
        content
            .background(ResponderView(firstResponder: $isFirstResponder))
    }

}

extension View {

    func acceptsFirstResponder(isFirstResponder: Binding<Bool>) -> some View {
        return self
            .modifier(AcceptsFirstResponder(isFirstResponder: isFirstResponder))
    }

}
