//
//  VariableList.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 27/12/2020.
//

import SwiftUI

struct VariableList: View {

    @ObservedObject var rule: TaskState
    @State var selection: VariableState?

    var body: some View {
        VStack {
            HStack {
                List(rule.variables, id: \.self, selection: $selection) { variable in
                    Text("\(variable.name) (\(String(describing: variable.type)))")
                }
                if let selection = selection {
                    VariableTextField(variable: selection)
                        .id(selection)
                }
            }
            HStack {
                Button {
                    rule.createVariable()
                } label: {
                    Image(systemName: "plus")
                }
                Button {
                    guard let variable = selection else {
                        return
                    }
                    rule.remove(variable: variable)
                    selection = nil
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selection == nil)
                Spacer()
            }

        }
    }

}
