// Copyright (c) 2018-2023 InSeven Limited
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

struct FileRow: View {

    @EnvironmentObject var sceneModel: SceneModel

    struct LayoutMetrics {
        static let iconSize = CGSize(width: 48.0, height: 48.0)
    }

    var file: FileInfo

    init(file: FileInfo) {
        self.file = file
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                IconView(url: file.url, size: LayoutMetrics.iconSize)
                VStack(spacing: 0) {
                    HStack {
                        Text(file.name)
                            .lineLimit(1)
                            .font(.headline)
                        Spacer()
                        if let date = file.date {
                            DateView(date: date)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .layoutPriority(1)
                        }
                    }
                    HStack {
                        if let rootURL = sceneModel.directoryViewModel?.url,
                           let relativePath = file.directoryUrl.relativePath(from: rootURL) {
                            Text(relativePath)
                                .lineLimit(1)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 6)
        }
        .padding(.leading)
        .padding(.trailing)
        .help(file.url.lastPathComponent)
    }

}
