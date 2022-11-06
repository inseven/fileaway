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

public class SelectionModel: ObservableObject {

    @Environment(\.openURL) var openURL

    @Published public var selection: Set<FileInfo> = []

    private let directory: DirectoryModel?
    private var cancellables: Set<AnyCancellable> = []

    public init(directory: DirectoryModel? = nil) {
        self.directory = directory
    }

    @MainActor public func start() {

        guard let directory = directory else {
            return
        }

        // Remove missing files from the selection.
        directory
            .$searchResults
            .receive(on: DispatchQueue.main)
            .map { files in
                return Set(files.filter { self.selection.contains($0) })
            }
            .sink { selection in
                guard self.selection != selection else {
                    return
                }
                self.selection = selection
            }
            .store(in: &cancellables)
    }

    @MainActor public func stop() {
        cancellables.removeAll()
    }

    public var urls: [URL] {
        selection.map { $0.url }
    }

    public var canPreview: Bool {
        return !selection.isEmpty
    }

#if os(macOS)
    public func preview() {
        guard let url = selection.first?.url else {
            return
        }
        QuickLookCoordinator.shared.show(url: url)
    }
#endif

    public var canCut: Bool {
        return !selection.isEmpty
    }

    public func cut() -> [NSItemProvider] {
        urls.map { NSItemProvider(object: $0 as NSURL) }
    }

    public var canTrash: Bool {
        return !selection.isEmpty
    }

    public func trash() throws {
        try urls.forEach { try FileManager.default.trashItem(at: $0, resultingItemURL: nil) }
    }

    public var canMove: Bool {
        return !selection.isEmpty
    }

    public func open() {
        urls.forEach { url in
            openURL(url)
        }
    }

}
