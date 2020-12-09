//
//  PageLink.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 09/12/2020.
//

import SwiftUI

struct PageLink<Destination, Content>: View where Destination: View, Content: View {

    @Environment(\.pageViewStack) var pageViewStack

    @Binding var isActive: Bool

    let destination: Destination
    let content: Content

    @inlinable public init(isActive: Binding<Bool>,
                           destination: Destination,
                           @ViewBuilder content: () -> Content) {
        _isActive = isActive
        self.destination = destination
        self.content = content()
    }

    var body: some View {
        content
            .onTapGesture {
                withAnimation {
                    pageViewStack.pages.append(ViewContainer(AnyView(destination)))
                }
            }
    }

}
