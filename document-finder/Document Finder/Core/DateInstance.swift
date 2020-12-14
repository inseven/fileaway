//
//  DateInstance.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import Combine
import SwiftUI

class DateInstance: VariableInstance, ObservableObject, VariableProvider {

    @Published var date: Date

    var textRepresentation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    init(variable: Variable, initialValue: Date) {
        _date = Published(initialValue: initialValue)
        super.init(variable: variable)
    }

    func observe(_ onChange: @escaping () -> Void) -> AnyCancellable {
        self.objectWillChange.sink(receiveValue: onChange)
    }

}
