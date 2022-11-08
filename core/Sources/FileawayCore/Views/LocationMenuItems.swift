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

public struct LocationMenuItems: View {

    var manager: ApplicationModel
    var directoryObserver: DirectoryModel
    var onError: (Error) -> Void

    public init(manager: ApplicationModel, directoryObserver: DirectoryModel, onError: @escaping (Error) -> Void) {
        self.manager = manager
        self.directoryObserver = directoryObserver
        self.onError = onError
    }

    public var body: some View {
#if os(macOS)
        // TODO: Move these macOS specific commands into a separate file
        Button("Reveal in Finder") {
            NSWorkspace.shared.activateFileViewerSelecting([directoryObserver.url])
        }
        Divider()
#endif
        Button("Remove") {
            do {
                try manager.removeDirectoryObserver(directoryObserver: directoryObserver)
            } catch {
                self.onError(error)
            }
        }
    }

}
