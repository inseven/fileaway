//
//  FileRow.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 04/12/2020.
//

import SwiftUI

struct FileRow: View {

    var file: FileInfo
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Text(file.name)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    Spacer()
                    if let date = file.date {
                        DateView(date: date)
                            .foregroundColor(isSelected ? .white : .secondary)
                    }
                }
                HStack {
                    Text(file.url.lastPathComponent)
                        .foregroundColor(isSelected ? .white : .secondary)
                        .font(.subheadline)
                    Spacer()
                }
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(6)
            .background(isSelected ? Color.accentColor.cornerRadius(6).eraseToAnyView() : Color(NSColor.textBackgroundColor).eraseToAnyView())
            Divider()
        }
        .padding(.leading)
        .padding(.trailing)
    }

}
