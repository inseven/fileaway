//
//  ArchiveWizard.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import SwiftUI

struct ArchiveWizard: View {

    @Environment(\.manager) var manager
    @SceneStorage("ArchiveWizard.documentUrl") var url: URL?
    @State var firstResponder: Bool = true

    var body: some View {
        VStack {
            if let url = url {
                HStack {
                    QuickLookPreview(url: url)
                    PageView {
                        TaskPage(manager: manager, url: url)
                    }
                }
            } else {
                Text("No File Selected")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
        }
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .padding()
        .onOpenURL { url in
            self.url = URL(fileURLWithPath: url.path)
        }
        .frame(minWidth: 800, minHeight: 600, idealHeight: 600)
    }

}
