//
//  PageLink.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 09/12/2020.
//

import SwiftUI

struct PageLink<Destination, Content>: View where Destination: View, Content: View {

    @Environment(\.pageViewStack) var pageViewStack

    let destination: Destination
    let content: Content

    @inlinable public init(destination: Destination,
                           @ViewBuilder content: () -> Content) {
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
