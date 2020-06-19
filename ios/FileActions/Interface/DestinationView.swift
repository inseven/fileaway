//
//  DestinationView.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 18/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct DestinationView: View {

    @Binding var variables: [VariableState]
    @Binding var components: [ComponentState]

    func description(for component: ComponentState) -> String {
        switch component.type {
        case .text:
            return component.value
        case .variable:
            guard let variable = (variables.first { $0.name == component.value }) else {
                return "Missing Variable"
            }
            switch variable.type {
            case .date(hasDay: true):
                return "YYYY-mm-dd"
            case .date(hasDay: false):
                return "YYYY-mm"
            case .string:
                return variable.name
            }
        }
    }

    var body: some View {
        HStack {
            components.map {
                Text(self.description(for: $0))
                    .foregroundColor($0.type == .variable ? .blue : .primary)
                    .fontWeight($0.type == .variable ? .bold : .none)
            }
            .reduce( Text(""), + )
        }
    }

}
