//
//  FileRow.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 04/12/2020.
//

import SwiftUI

struct FileRow: View {

    @Environment(\.isFocused) var isFocused

    var file: FileInfo
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Text(file.name)
                        .lineLimit(1)
                        .font(.headline)
                        .foregroundColor(isSelected || isFocused ? .white : .primary)
                    Spacer()
                    if let date = file.date {
                        DateView(date: date)
                            .foregroundColor(isSelected || isFocused ? .white : .secondary)
                    }
                }
                HStack {
                    Text(file.url.lastPathComponent)
                        .lineLimit(1)
                        .foregroundColor(isSelected || isFocused ? .white : .secondary)
                        .font(.subheadline)
                    Spacer()
                }
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(6)
            .background(isSelected || isFocused ? Color.accentColor.cornerRadius(6).eraseToAnyView() : Color(NSColor.textBackgroundColor).eraseToAnyView())
            Divider()
        }
        .padding(.leading)
        .padding(.trailing)
    }

}
