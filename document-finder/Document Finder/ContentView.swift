//
//  ContentView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 01/12/2020.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var manager: Manager

    var body: some View {
        NavigationView {
            Sidebar(manager: manager)
            EmptyView()
                .background(Color(NSColor.textBackgroundColor))
                .modifier(Toolbar(filter: Binding.constant(""), qlCoordinator: QLCoordinator()))
        }
    }
}
