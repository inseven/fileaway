//
//  ContentView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 01/12/2020.
//

import SwiftUI

struct MailboxRow: View {

    @ObservedObject var directoryObserver: DirectoryObserver
    var title: String
    var imageSystemName: String

    var body: some View {
        HStack {
            Image(systemName: imageSystemName)
                .foregroundColor(.accentColor)
            Text(title)
            Spacer()
            if directoryObserver.count > 0 {
                Text(String(directoryObserver.count))
            }
        }
    }

}

struct ContentView: View {

    @ObservedObject var manager: Manager

    var body: some View {
        NavigationView {
            Sidebar(manager: manager)
            EmptyView()
                .modifier(Toolbar(selection: nil, filter: Binding.constant(""), qlCoordinator: QLCoordinator()))
        }
    }
}
