//
//  MailboxRow.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 05/12/2020.
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
