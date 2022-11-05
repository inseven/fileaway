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

import Foundation
import MobileCoreServices
import SwiftUI

protocol ActionsViewDelegate: NSObject {
    func moveFileTapped()
}

enum ActionSheet {
    case settings
    case reversePages
    case interleave
    case fakeDuplex
}

extension ActionSheet: Identifiable {
    public var id: ActionSheet { self }
}

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}

struct ActionsView: View {

    weak var delegate: ActionsViewDelegate?
    @ObservedObject var settings: Settings
    @State private var activeSheet: ActionSheet?

    func sheet(type: ActionSheet) -> some View {
        switch type {
        case .settings:
            return NavigationView {
                SettingsView(settings: self.settings)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
        case .reversePages:
            return ReversePages(task: ReverseTask())
                .eraseToAnyView()
        case .interleave:
            return MergeDocumentsView(task: MergeTask())
                .eraseToAnyView()
        case .fakeDuplex:
            return FakeDuplexView(task: FakeDuplexTask())
                .eraseToAnyView()
        }
    }

    var body: some View {
        ScrollView {
        VStack {
            ActionMenu {
                ActionGroup {
                    ActionButton("Move File", systemName: "folder") {
                        guard let delegate = self.delegate else {
                            return
                        }
                        delegate.moveFileTapped()
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: .accentColor, foregroundColor: .white))
                }
                ActionGroup {
                    ActionButton("Reverse Pages", systemName: "doc.on.doc") {
                        self.activeSheet = .reversePages
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: Color(UIColor.systemFill)))
                    ActionButton("Interleave Pages", systemName: "doc.on.doc") {
                        self.activeSheet = .interleave
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: Color(UIColor.systemFill)))
                    ActionButton("Fake Duplex", systemName: "doc.on.doc") {
                        self.activeSheet = .fakeDuplex
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: Color(UIColor.systemFill)))
                }
            }
            .padding()
            .frame(maxWidth: 520)
            }
        }
        .sheet(item: $activeSheet) { sheet in
            return self.sheet(type: sheet)
        }
        .navigationBarTitle("Fileaway")
        .navigationBarItems(leading: Button(action: {
            self.activeSheet = .settings
        }, label: {
            Text("Settings")
        }))
    }

}
