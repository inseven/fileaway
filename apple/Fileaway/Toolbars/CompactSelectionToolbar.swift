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

import FileawayCore

#if os(iOS)

public struct CompactSelectionToolbar: ToolbarContent {

    @EnvironmentObject var sceneModel: SceneModel

    @ObservedObject var directoryViewModel: DirectoryViewModel

    public init(directoryViewModel: DirectoryViewModel) {
        self.directoryViewModel = directoryViewModel
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {

            HStack {

                Button("Move") {
                    sceneModel.move(directoryViewModel.selection)
                }
                .disabled(!directoryViewModel.canMove)

                Spacer()

                Button("Preview") {
                    directoryViewModel.showPreview()
                }
                .disabled(!directoryViewModel.canPreview)

                Spacer()

                Button("Delete") {
                    directoryViewModel.trash(.selection)
                }
                .disabled(!directoryViewModel.canTrash)
            }
            
        }

    }

}

#endif
