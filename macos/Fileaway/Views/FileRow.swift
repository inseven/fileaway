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
import Interact

struct FileRow: View {

    var file: FileInfo
    var isSelected: Bool

    init(file: FileInfo, isSelected: Bool) {
        self.file = file
        self.isSelected = isSelected
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                IconView(url: file.url, size: CGSize(width: 48, height: 48))
                VStack(spacing: 0) {
                    HStack {
                        Text(file.name)
                            .lineLimit(1)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .primary)
                        Spacer()
                        if let date = file.date {
                            DateView(date: date)
                                .foregroundColor(isSelected ? .white : .secondary)
                        }
                    }
                    HStack {
                        Text(file.directoryUrl.path)
                            .lineLimit(1)
                            .foregroundColor(isSelected ? .white : .secondary)
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 6)
        }
        .padding(.leading)
        .padding(.trailing)
    }

}
