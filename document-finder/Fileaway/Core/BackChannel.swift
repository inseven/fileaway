//
//  BackChannel.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import Combine

protocol BackChannelable {
    func establishBackChannel()
}

// TODO: Remove this as it should be unnecessary.
class BackChannel<T> where T: ObservableObject {

    var value: [T] = []
    var publisher: Published<[T]>.Publisher
    var observer: Cancellable?
    var observers: [Cancellable] = []

    init(value: [T], publisher: Published<[T]>.Publisher) {
        self.value = value
        self.publisher = publisher
    }

    func bind(completion: @escaping () -> Void) -> BackChannel<T> {
        observer = publisher.sink { array in
            self.observers = array.map { observable in
                if let backChannelable = observable as? BackChannelable {
                    backChannelable.establishBackChannel()
                }
                return observable.objectWillChange.sink { _ in
                    completion()
                }
            }
        }
        return self
    }

    deinit {
        observer?.cancel()
        for observer in observers {
            observer.cancel()
        }
        observers = []
    }

}
