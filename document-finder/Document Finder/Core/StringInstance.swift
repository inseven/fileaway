//
//  StringInstance.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import Combine
import SwiftUI

class StringInstance: VariableInstance, ObservableObject, VariableProvider {

    var textRepresentation: String {
        return string
    }

    @Published var string: String

    init(variable: Variable, initialValue: String) {
        _string = Published(initialValue: initialValue)
        super.init(variable: variable)
    }

    func observe(_ onChange: @escaping () -> Void) -> AnyCancellable {
        self.objectWillChange.sink(receiveValue: onChange)
    }

}
