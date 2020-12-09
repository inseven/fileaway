//
//  ArchiveWizard.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 09/12/2020.
//

import SwiftUI

extension String: Identifiable {
    public var id: String { self }
}

struct TaskPage: View {

    @State var isShowingChild: Bool = false

    @State var items = [
        "1Password Invoice",
        "Adobe Illustrator Subscription",
        "Amazon Web Services Invoice",
        "Apple Card Statement",
        "Bank Statement",
        "Phone Bill",
    ]

    @State var filter: String = ""

    var body: some View {
        VStack {
            SearchField(search: $filter)
            List {
                ForEach(items.filter { $0.localizedSearchMatches(string: filter) } ) { item in
                    PageLink(isActive: $isShowingChild, destination: DetailsPage()) {
                        HStack {
                            Text(item)
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        .padding()
                        .background(Color.textBackgroundColor)
                    }
                    Divider()
                }
                HStack {
                    Text("Add task...")
                    Spacer()
                    Image(systemName: "chevron.forward")
                }
            }
        }
        .pageTitle("Task")
    }

}

struct DonePage: View {

    var body: some View {
        HStack {
            Text("Empty MKII")
        }
        .pageTitle("Empty View")
    }

}

struct DetailsPage: View {

    @State var active: Bool = false

    var body: some View {
        VStack {
            PageLink(isActive: $active, destination: DonePage()) {
                Text("Click me")
            }
            Spacer()
            Text("Empty view")
            Spacer()
        }
        .pageTitle("Details")
        .frame(minWidth: 0, maxWidth: .infinity)
    }

}

struct ArchiveWizard: View {

    @State var url: URL
    var onDismiss: () -> Void

    @State var firstResponder: Bool = true

    var body: some View {
        VStack {
            HStack {
                QuickLookPreview(url: url)
                PageView {
                    TaskPage()
                }
            }
            Button(action: onDismiss) {
                Text("Cancel")
            }
            .padding()
        }
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .padding()
        .frame(minWidth: 800, minHeight: 600)
        .onExitCommand(perform: onDismiss)
    }

}
