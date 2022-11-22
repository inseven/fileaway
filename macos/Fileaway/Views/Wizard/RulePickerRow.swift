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

import Combine
import SwiftUI

import FileawayCore
import Interact

struct RulePickerRow: View {

    @ObservedObject private var ruleModel: RuleModel

    private let action: () -> Void

    init(ruleModel: RuleModel, action: @escaping () -> Void) {
        self.ruleModel = ruleModel
        self.action = action
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(ruleModel.name)
                Text(ruleModel.rootUrl.displayName)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.forward")
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }

    }

}
