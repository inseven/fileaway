// Copyright (c) 2018-2025 Jason Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if os(iOS)

import SwiftUI

import Diligence

import FileawayCore

public struct PhoneSettingsView: View {

    enum SheetType: Identifiable {

        var id: Self { self }

        case about
    }

    @Environment(\.dismiss) private var dismiss

    @ObservedObject var applicationModel: ApplicationModel
    @ObservedObject var settings: Settings

    @State private var sheet: SheetType? = nil

    public init(applicationModel: ApplicationModel, settings: Settings) {
        self.applicationModel = applicationModel
        self.settings = settings
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    NavigationLink {
                        PhoneFileTypesView(settings: settings)
                    } label: {
                        Text("File Types")
                            .badge(settings.fileTypes.count)
                    }
                }
                Section("Rules") {
                    if applicationModel.archives.isEmpty {
                        Text("None")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(applicationModel.archives) { directory in
                            NavigationLink {
                                PhoneRulesView(rulesModel: directory.ruleSet)
                            } label: {
                                Text(directory.name)
                            }
                        }
                    }
                }
                Section {
                    Button("About Fileaway...") {
                        sheet = .about
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Done")
                    .bold()
            })
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .about:
                    AboutView(Legal.contents)
                }
            }
        }
    }

}

#endif
