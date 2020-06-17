//
//  ActionView.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation
import SwiftUI

struct ActionView: View {

    var text: String
    var imageName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                Spacer()
                Image(systemName: imageName)
            }
        }.foregroundColor(.primary)
    }
}
