//
//  RuleDetailView.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import SwiftUI

struct RuleDetailView: View {

    @ObservedObject var rule: RuleState

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Title", text: $rule.name)
            Text("Variables")
                .font(.headline)
            VariableList(rule: rule)
            Text("Destination")
                .font(.headline)
            DestinationList(rule: rule)
            Spacer()
        }
        .padding()
    }

}
