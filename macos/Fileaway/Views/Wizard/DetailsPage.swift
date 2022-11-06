// Copyright (c) 2018-2022 InSeven Limited
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

import SwiftUI

import FileawayCore

struct DetailsPage: View {

    enum AlertType: Identifiable {

        public var id: String {
            switch self {
            case .error(let error):
                return "error:\(error)"
            case .duplicate(let duplicateUrl):
                return "duplicate:\(duplicateUrl)"
            }
        }

        case error(error: Error)
        case duplicate(duplicateUrl: URL)
    }

    @Environment(\.applicationModel) var manager
    @Environment(\.close) var close

    var url: URL
    @StateObject var rule: RuleInstance
    @State var alert: AlertType?
    @State var date: Date = Date()
    @StateObject var dateExtractor: DateExtractor

    init(url: URL, rule: Rule) {
        self.url = url
        _rule = StateObject(wrappedValue: RuleInstance(rule: rule))
        _dateExtractor = StateObject(wrappedValue: DateExtractor(url: url))
    }

    var body: some View {
        Form {
            Section("Rule") {
                Text(rule.name)
            }
            Section("Details") {
                ForEach(rule.variables) { variable in
                    if let variable = variable as? DateInstance {
                        VariableDateView(variable: variable,
                                         creationDate: FileInfo.creationDate(url: url)?.date,
                                         options: dateExtractor.dates)
                    } else if let variable = variable as? StringInstance {
                        VariableStringView(variable: variable)
                    } else {
                        Text("Unknown Variable Type")
                    }
                }
            }
            Section("Destination") {
                Text(rule.destination(for: url).path)
            }
        }
        .formStyle(.grouped)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button {
                    let destinationUrl = rule.destination(for: url)
                    print("moving to \(destinationUrl)...")
                    do {
                        try rule.move(url: url)
                        close()
                    } catch CocoaError.fileWriteFileExists {
                        alert = .duplicate(duplicateUrl: destinationUrl)
                    } catch {
                        alert = .error(error: error)
                    }
                } label: {
                    Text("Move")
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .alert(item: $alert) { alert in
            switch alert {
            case .error(let error):
                return Alert(title: Text("Unable to Move File"), message: Text(error.localizedDescription))
            case .duplicate(let duplicateUrl):
                return Alert(title: Text("Unable to Move File"),
                             message: Text("File exists at location."),
                             primaryButton: .default(Text("OK")),
                             secondaryButton: .default(Text("Reveal Duplicate"), action: {
                                NSWorkspace.shared.activateFileViewerSelecting([duplicateUrl])
                             }))
            }
        }
        .onAppear {
            dateExtractor.load()
        }
    }

}
