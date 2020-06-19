//
//  ErrorText.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 19/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct ErrorText: View {

    var text: String?

    var body: some View {
        Text(text ?? "").foregroundColor(.red)
    }

}

