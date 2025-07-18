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

import Combine
import Foundation
import SwiftUI

import FileawayCore

struct PhoneVariableRow : View {

    @Environment(\.editMode) var editMode
    @State var showSheet: Bool = false

    @ObservedObject var ruleModel: RuleModel
    @ObservedObject var variable: VariableModel

    var body: some View {
        HStack {
            VariableMarker(variable: variable)
            Text(variable.name)
            Spacer()
            Text(String(describing: variable.type))
                .foregroundColor(editMode?.wrappedValue == .active ? .accentColor : .secondary)
        }
        .sheet(isPresented: $showSheet) {
            PhoneVariableView(ruleModel: self.ruleModel, variable: self.variable)
        }
        .onTapGesture {
            if self.editMode?.wrappedValue == .active {
                self.showSheet = true
            }
        }
    }

}

#endif
