//
//  Highlight.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import SwiftUI

import Interact

struct Highlight<T>: ViewModifier where T: Hashable {

    @ObservedObject var tracker: SelectionTracker<T>
    var item: T

    func body(content: Content) -> some View {
        content
            .foregroundColor(tracker.isSelected(item: item) ? .white : .primary)
            .background(tracker.isSelected(item: item) ? Color.selectedContentBackgroundColor : Color.clear)
            .cornerRadius(6, corners: tracker.corners(for: item))
        }

}
