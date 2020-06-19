//
//  TaskState.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 18/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

import FileActionsCore

extension Task {

    init(_ state: TaskState) {
        self.init(name: state.name,
                  configuration: Configuration(variables: state.variables.map { Variable($0) },
                                               destination: state.destination.map { Component($0) }))
    }

}

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

class TaskState: ObservableObject, Identifiable, BackChannelable {

    var id = UUID()
    @Published var name: String

    @Published var variables: [VariableState]
    var variablesBackChannel: BackChannel<VariableState>?
    
    @Published var destination: [ComponentState]
    var destinationBackChannel: BackChannel<ComponentState>?

    func establishBackChannel() {
        variablesBackChannel = BackChannel(value: variables, publisher: $variables).bind {
            self.objectWillChange.send()
        }
        destinationBackChannel = BackChannel(value: destination, publisher: $destination).bind {
            self.objectWillChange.send()
        }
    }

    init(task: Task) {
        name = task.name
        variables = task.configuration.variables.map { VariableState($0) }
        destination = task.configuration.destination.map { ComponentState($0) }
    }

}
