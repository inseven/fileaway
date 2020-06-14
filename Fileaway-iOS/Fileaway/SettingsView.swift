//
//  SettingsView.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/05/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @State var name: String

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Do something")) {
                    TextField("Your Name", text: $name)
                    Button(action: {
                        print("Button Pressed")
                    }) {
                        Text("Something!")
                    }
                }
            }
        }
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(name: "Cheese")
    }
}
