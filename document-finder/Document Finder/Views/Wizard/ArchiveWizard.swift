//
//  ArchiveWizard.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import SwiftUI

struct ArchiveWizard: View {

    @Environment(\.manager) var manager

    @State var url: URL

    @State var firstResponder: Bool = true

    var body: some View {
        VStack {
            HStack {
                QuickLookPreview(url: url)
                PageView {
                    TaskPage(manager: manager, url: url)
                }
            }
        }
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .padding()
        .frame(minWidth: 800, minHeight: 600, idealHeight: 600)
    }

}
