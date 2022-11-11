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

import Interact

public class DirectoryViewModel: ObservableObject, Identifiable, Runnable {

    public var id: URL { self.url }

    @Environment(\.openURL) var openURL
    @Environment(\.openWindow) var openWindow

    @Published public var files: [FileInfo] = []
    @Published public var filter: String = ""
    @Published public var selection: Set<FileInfo> = []

    private var directoryModel: DirectoryModel? = nil
    private var cancelables: Set<AnyCancellable> = []
    private let syncQueue = DispatchQueue.init(label: "DirectoryViewModel.syncQueue")

    public var type: DirectoryModel.DirectoryType {
        return directoryModel?.type ?? .inbox
    }

    public var url: URL {
        return directoryModel?.url ?? URL(string: "foo:unknown")!
    }

    public var name: String {
        return directoryModel?.name ?? "Nothing to see here"
    }

    private var selectedUrls: [URL] {
        selection.map { $0.url }
    }

    public init(directoryModel: DirectoryModel? = nil) {
        self.directoryModel = directoryModel
    }

    @MainActor public func start() {

        guard let directoryModel = directoryModel else {
            return
        }

        // Filter the files.
        directoryModel
            .$searchResults
            .combineLatest($filter)
            .receive(on: syncQueue)
            .map { (files, filter) in
                return files
                    .filter { filter.isEmpty || $0.name.localizedSearchMatches(string: filter) }
                    .sorted { fileInfo1, fileInfo2 -> Bool in
                        let dateComparison = fileInfo1.date.date.compare(fileInfo2.date.date)
                        if dateComparison != .orderedSame {
                            return dateComparison == .orderedDescending
                        }
                        return fileInfo1.name.compare(fileInfo2.name) == .orderedAscending
                    }
            }
            .receive(on: DispatchQueue.main)
            .sink { files in
                self.files = files
            }
            .store(in: &cancelables)

        // Remove missing files from the selection.
        $files
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
            .store(in: &cancelables)


    }

    @MainActor public func stop() {
        cancelables.removeAll()
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
        selectedUrls.map { NSItemProvider(object: $0 as NSURL) }
    }

    @MainActor public var canTrash: Bool {
        return !selection.isEmpty
    }

    @MainActor public func trash() throws {
        try selectedUrls.forEach { try FileManager.default.trashItem(at: $0, resultingItemURL: nil) }
    }

    @MainActor public var canShowRulesWizard: Bool {
        return !selection.isEmpty
    }

    @MainActor public var canOpen: Bool {
        return !selection.isEmpty
    }

    @MainActor public func open() {
        for url in selectedUrls {
            openURL(url)
        }
    }

}