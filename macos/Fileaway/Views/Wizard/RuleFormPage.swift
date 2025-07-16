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

import SwiftUI

import Interact

import FileawayCore

struct RuleFormPage: View {

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

    @Environment(\.dismissWindow) private var dismissWindow

    @ObservedObject var ruleModel: RuleModel
    @StateObject var ruleFormModel: RuleFormModel

    var url: URL
    @State var alert: AlertType?

    init(applicationModel: ApplicationModel, url: URL, ruleModel: RuleModel) {
        self.url = url
        self.ruleModel = ruleModel
        _ruleFormModel = StateObject(wrappedValue: RuleFormModel(applicationModel: applicationModel,
                                                                 ruleModel: ruleModel,
                                                                 url: url))
    }

    var body: some View {
        RuleForm(ruleFormModel, url: url)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Button {
                        do {
                            try ruleFormModel.move()
                            dismissWindow()
                        } catch CocoaError.fileWriteFileExists {
                            alert = .duplicate(duplicateUrl: ruleFormModel.destinationURL)
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
            .showsStackNavigationBar(ruleModel.name)
            .alert(item: $alert) { alert in
                switch alert {
                case .error(let error):
                    return Alert(title: Text("Unable to Move File"), message: Text(error.localizedDescription))
                case .duplicate(let duplicateUrl):
                    return Alert(title: Text("Unable to Move File"),
                                 message: Text("File exists at location."),
                                 primaryButton: .default(Text("OK")),
                                 secondaryButton: .default(Text("Reveal Duplicate"), action: {
                        Application.reveal(duplicateUrl)
                    }))
                }
            }
    }

}
