//
//  EditableText.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 19/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct EditText: View {

    var name: String
    @Binding var text: String
    @Environment(\.editMode) var editMode

    var body: some View {
        TextField(name, text: $text).disabled(editMode != nil ? editMode!.wrappedValue != .active : false)
    }

    init(_ name: String, text: Binding<String>) {
        self.name = name
        self._text = text
    }

}
