//
//  DestinationView.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 18/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct DestinationView: View {

    @ObservedObject var task: TaskState

    var body: some View {
        HStack {
            task.destination.map {
                Text(self.task.name(for: $0, format: .short))
                    .foregroundColor($0.type == .variable ? .blue : .primary)
                    .fontWeight($0.type == .variable ? .bold : .none)
            }
            .reduce( Text(""), + )
        }
    }

}
