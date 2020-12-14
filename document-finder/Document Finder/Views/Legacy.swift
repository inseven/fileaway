//
//  ArchiveWizard.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 09/12/2020.
//

import Combine
import SwiftUI

import Introspect

extension String: Identifiable {
    public var id: String { self }
}

struct TrackerInput<T>: ViewModifier where T: Hashable {

    var tracker: SelectionTracker<T>

    func body(content: Content) -> some View {
        content
            .onMoveCommand { direction in
                print("tracker = \(tracker), direction = \(direction)")
                switch direction {
                case .up:
                    tracker.handleDirectionUp()
                case .down:
                    tracker.handleDirectionDown()
                default:
                    return
                }
            }
    }

}

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
        HStack {
            Text(variable.name)
            Spacer()
            DatePicker("", selection: $variable.date, displayedComponents: [.date])
        }
    }

}

struct VariableStringView: View {

    @StateObject var variable: StringInstance
    @State var string: String = ""

    var body: some View {
        HStack {
            Text(variable.name)
            Spacer()
            TextField("", text: $variable.string)
        }
    }

}
