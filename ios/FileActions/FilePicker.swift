//
//  FilePicker.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation
import SwiftUI

struct FilePicker: View {

    @State private var showingFilePicker = false
    let placeholder: String
    let documentTypes: [String]
    @Binding var url: URL?

    var body: some View {
        Button(action: {
            self.showingFilePicker = true
        }) {
            if url == nil {
                Text(placeholder)
            } else {
                Text(url!.lastPathComponent)
            }
        }
        .sheet(isPresented: $showingFilePicker) {
            FilePickerSheet(documentTypes: self.documentTypes, url: self.$url)
        }
    }

}
