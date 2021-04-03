//
//  ArchiveWizard.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 09/12/2020.
//

import Combine
import SwiftUI

import Introspect

protocol TextProvider {
    var textRepresentation: String { get }
}

protocol Observable {
    func observe(_ onChange: @escaping () -> Void) -> AnyCancellable
}

protocol VariableProvider: TextProvider, Observable, ObservableObject {

}

extension Variable {

    func instance() -> VariableInstance {
        switch self.type {
        case .string:
            return StringInstance(variable: self, initialValue: "")
        case .date:
            return DateInstance(variable:self, initialValue: Date())
        }
    }

}

struct VariableDateView: View {

    @ObservedObject var variable: DateInstance

    var body: some View {
        DatePicker("", selection: $variable.date, displayedComponents: [.date])
            .padding(.leading, -8)
            .frame(maxWidth: .infinity)
    }

}

struct VariableStringView: View {

    @StateObject var variable: StringInstance
    @State var string: String = ""

    var body: some View {
        TextField("", text: $variable.string)
    }

}
