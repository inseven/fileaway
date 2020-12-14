//
//  DetailsPage.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import SwiftUI

struct DetailsPage: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.manager) var manager

    var url: URL
    @StateObject var task: TaskInstance

    @State var date: Date = Date()
    @State var year = "2020"

    init(url: URL, rootUrl: URL, task: Task) {
        self.url = url
        _task = StateObject(wrappedValue: TaskInstance(url: rootUrl, task: task))
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(task.variables) { variable in
                        HStack {
                            if let variable = variable as? DateInstance {
                                VariableDateView(variable: variable)
                            } else if let variable = variable as? StringInstance {
                                VariableStringView(variable: variable)
                            } else {
                                Text(variable.name)
                                Spacer()
                                Text("Unsupported")
                            }
                        }
                        .padding()
                    }
                }
            }
            Text(task.destinationUrl.path)
                .lineLimit(1)
                .truncationMode(.head)
                .help(task.destinationUrl.path)
            Button {
                print("moving to \(task.destinationUrl)...")
                do {
                    try task.move(url: url)
                } catch {
                    print("Failed to move file with error \(error)")
                }

                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Move")
            }
        }
        .pageTitle(task.name)
        .frame(minWidth: 0, maxWidth: .infinity)
    }

}
