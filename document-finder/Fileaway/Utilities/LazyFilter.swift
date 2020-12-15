//
//  LazyFilter.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 11/12/2020.
//

import Combine
import SwiftUI

typealias SortDescriptor<Value> = (_ lhs: Value, _ rhs: Value) -> Bool

class LazyFilter<T>: ObservableObject where T: Hashable {

    let queue = DispatchQueue(label: "LazyFilter.queue")
    var subscription: Cancellable?

    @Published var filter: String = ""
    @Published var sortDescriptor: SortDescriptor<T> = { lhs, rhs in true }
    @Published var items: [T] = []

    init(items: Published<[T]>.Publisher,
         test: @escaping (_ filter: String, _ item: T) -> Bool,
         initialSortDescriptor: @escaping SortDescriptor<T>) {
        _sortDescriptor = Published(initialValue: initialSortDescriptor)
        subscription = items
            .combineLatest($filter, $sortDescriptor)
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .receive(on: queue)
            .map { items, filter, sortDescriptor in
                return items
                    .filter { test(filter, $0) }
                    .sorted(by: sortDescriptor)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
    }

}
