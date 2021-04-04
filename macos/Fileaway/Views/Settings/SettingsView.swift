// Copyright (c) 2018-2021 InSeven Limited
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

import Combine
import SwiftUI

struct VariableTextField: View {

    @ObservedObject var variable: VariableState
    @State var variableType: VariableType = .string

    var body: some View {
        VStack {
            TextField("Name", text: $variable.name)
            Picker(selection: $variable.type, label: Text("Type")) {
                ForEach(VariableType.allCases, id: \.self) { type in
                    Text(String(describing: type))
                }
            }
            Spacer()
        }
    }

}

struct ListButtons: View {

    var add: () -> Void
    var remove: () -> Void

    var body: some View {
        HStack {
            Button(action: add) {
                Image(systemName: "plus")
            }
            Button(action: remove) {
                Image(systemName: "minus")
            }
        }
    }

}

struct SettingsView: View {

    private enum Tabs: Hashable {
        case general
    }

    @ObservedObject var manager: Manager

    var body: some View {
        TabView {
            GeneralSettingsView(manager: manager)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            if let ruleSet = manager.ruleSet {
                RulesSettingsView(rules: ruleSet)
                    .tabItem {
                        Label("Rules", systemImage: "tray.and.arrow.down")
                    }
            }
        }
        .padding()
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 460, maxHeight: .infinity)
    }

}
