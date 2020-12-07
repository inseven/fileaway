//
//  SelectionTracker.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 06/12/2020.
//

import Combine
import SwiftUI

enum SelectionTrackerError: Error {
    case outOfRange
}

class SelectionTracker<T>: ObservableObject where T: Hashable {

    var publisher: Published<[T]>.Publisher
    var subscription: Cancellable? = nil

    @Published var items: [T] = []
    @Published var selection: Set<T> = []

    init(items: Published<[T]>.Publisher) {
        publisher = items
        subscription = publisher.assign(to: \.items, on: self)
    }

    func clear() {
        selection.removeAll()
    }

    func select(item: T) {
        selection.removeAll()
        selection.insert(item)
    }

    func isSelected(item: T) -> Bool {
        return selection.contains(item)
    }

    func index(of item: T) -> Int? {
        items.firstIndex { $0 == item }
    }

    var indexes: [Int] {
        selection.compactMap { item in index(of: item) }
    }

    func next() throws {
        var index = self.indexes.last ?? -1
        index += 1
        if index >= items.count {
            throw SelectionTrackerError.outOfRange
        }
        select(item: items[index])
    }

    func previous() throws {
        var index = self.indexes.first ?? items.count
        index -= 1
        if index < 0 || items.count < 1 {
            throw SelectionTrackerError.outOfRange
        }
        select(item: items[index])
    }

}
