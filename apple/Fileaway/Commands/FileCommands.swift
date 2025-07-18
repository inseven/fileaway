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

public struct FileCommands: Commands {

    @ObservedObject var directoryViewModel: DirectoryViewModel
    @FocusedObject private var sceneModel: SceneModel?

    public init(directoryViewModel: DirectoryViewModel?) {
        _directoryViewModel = ObservedObject(initialValue: directoryViewModel ?? DirectoryViewModel())
    }

    @MainActor public var body: some Commands {
        CommandGroup(after: .newItem) {

            Divider()

            Button("Move") {
                sceneModel?.move(directoryViewModel.selection)
            }
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(!directoryViewModel.canMove)

            Divider()

            Button("Open") {
                directoryViewModel.open()
            }
            .keyboardShortcut("o")
            .disabled(!directoryViewModel.canOpen)

#if os(macOS)
            Button("Reveal in Finder") {
                sceneModel?.reveal(directoryViewModel.selection)
            }
            .disabled(!directoryViewModel.canReveal)
#endif

        }
    }

}
