//
//  SettingsView.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/05/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import SwiftUI

import FileawayCore

struct SettingsView: View {

    @State var tasks: [Task]

    var body: some View {
        VStack {
            List {
                Section(header: Text("Tasks")) {
                    ForEach(tasks, id: \.name) { task in
                        NavigationLink(destination: VStack {
                            List {
                                Section(header: Text("Name")) {
                                    Text(task.name)
                                }
                                Section(header: Text("Variables")) {
                                    ForEach(task.configuration.variables, id: \.name) { variable in
                                        Text(variable.name)
                                    }
                                    Button(action: {
                                        print("Add variable...")
                                    }) {
                                        Text("New variable...")
                                    }
                                }
                            }
                        }) {
                            Text(task.name)
                        }
                    }
                }
            }.listStyle(GroupedListStyle())
        }
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(tasks: [])
    }
}
