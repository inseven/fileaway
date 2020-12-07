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
    var lastSelection: T?

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
        lastSelection = item
    }

    func add(item: T) {
        selection.insert(item)
        lastSelection = item
    }

    func extend(to item: T) throws {
        let indexes = self.indexes
        guard indexes.count > 0,
              let lastSelection = lastSelection else {
            self.select(item: item)
            return
        }
        guard let index = self.index(of: item),
              let lastIndex = self.index(of: lastSelection) else {
            throw SelectionTrackerError.outOfRange
        }
        let bounds = [index, lastIndex].sorted()
        for newIndex in bounds[0]...bounds[1] {
            selection.insert(items[newIndex])
        }
        self.lastSelection = item
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
