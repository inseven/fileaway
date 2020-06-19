//
//  BackChannel.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 19/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Combine
import SwiftUI

protocol BackChannelable {
    func establishBackChannel()
}

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
