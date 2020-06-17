//
//  Destination.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct Destination: View {

    @Binding var url: URL?

    var body: some View {
        Text(url != nil ? "Files will be moved to '\(url!.lastPathComponent)'." : "No destination set.")
    }

}
