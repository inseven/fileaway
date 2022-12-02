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

import Collections
import Interact

public class DirectoryViewModel: ObservableObject, Identifiable, Runnable {

    public enum Scope {
        case selection
        case file(FileInfo)
    }

    @MainActor public var id: URL { self.url }

    @Published public var files: OrderedDictionary<URL, FileInfo> = [:]
    @Published public var filter: String = ""
    @Published public var selection: Set<FileInfo> = []
    @Published public var previewUrls: [URL] = []
    @Published public var isLoading: Bool = true

    @Published var previewUrl: URL? = nil

    private var directoryModel: DirectoryModel? = nil
    private var cancellables: Set<AnyCancellable> = []
    private let syncQueue = DispatchQueue.init(label: "DirectoryViewModel.syncQueue")

    public var type: DirectoryModel.DirectoryType {
        return directoryModel?.type ?? .inbox
    }

    public var systemImage: String {
        switch type {
        case .inbox:
            return "tray"
        case .archive:
            return "archivebox"
        }
    }

    @MainActor public var url: URL {
        return directoryModel?.url ?? URL(string: "foo:unknown")!
    }

    @MainActor public var name: String {
        return directoryModel?.name ?? "Nothing to see here"
    }

    @MainActor private var selectedURLs: [URL] {
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
            .$files
            .combineLatest($filter, directoryModel.$isLoading)
            .receive(on: syncQueue)
            .map { files, filter, isLoading -> ([FileInfo], Bool) in
                let files = files
                    .filter { filter.isEmpty || $0.name.localizedSearchMatches(string: filter) }
                    .sorted { fileInfo1, fileInfo2 -> Bool in
                        let dateComparison = fileInfo1.date.date.compare(fileInfo2.date.date)
                        if dateComparison != .orderedSame {
                            return dateComparison == .orderedDescending
                        }
                        return fileInfo1.name.compare(fileInfo2.name) == .orderedAscending
                    }
                return (files, isLoading)
            }
            .map { files, isLoading -> (OrderedDictionary<URL, FileInfo>, [URL], Bool) in

                // Reduce the files into an ordered dictionary.
                let files = files.reduce(into: OrderedDictionary<URL, FileInfo>()) { result, fileInfo in
                    result[fileInfo.url] = fileInfo
                }

                let previewURLs = Array(files.keys)

                return (files, previewURLs, isLoading)
            }
            .receive(on: DispatchQueue.main)
            .sink { files, previewUrls, isLoading in
                self.files = files
                self.previewUrls = previewUrls
                self.isLoading = isLoading
            }
            .store(in: &cancellables)

        // Remove missing files from the selection.
        $files
            .receive(on: DispatchQueue.main)
            .map { files in
                let selection = self.selection.filter { files[$0.url] != nil }
                return selection
            }
            .sink { selection in
                guard self.selection != selection else {
                    return
                }
                self.selection = selection
            }
            .store(in: &cancellables)

        // Update the selection to match the preview URL.
        // Unfortunately the `quickLookPreview` current item binding doesn't seem to be updated on iOS when paging
        // through the items meaning that our selection can't be correctly updated. Given this, on iOS we allow the
        // nil item binding (indicating that the quick look preview has been dismissed) to clear the selection.
        directoryModel
            .$files
            .combineLatest($previewUrl)
            .receive(on: syncQueue)
            .compactMap { (files, previewURL) -> Set<FileInfo>? in
#if os(macOS)
                guard previewURL != nil else {
                    return nil
                }
#endif
                guard let previewURL = previewURL,
                      let file = self.files[previewURL] else {
                    return []
                }
                return [file]
            }
            .receive(on: DispatchQueue.main)
            .sink { selection in
                self.selection = selection
            }
            .store(in: &cancellables)

    }

    @MainActor public func stop() {
        cancellables.removeAll()
    }

    @MainActor public func refresh() {
        guard let directoryModel = directoryModel else {
            return
        }
        directoryModel.refresh()
    }

    @MainActor public var canPreview: Bool {
        return selection.count == 1
    }

    @MainActor public func showPreview(selecting file: FileInfo? = nil) {
        previewUrl = file?.url ?? selection.first?.url
    }

    @MainActor public var canCut: Bool {
        return !selection.isEmpty
    }

    @MainActor public func cut() -> [NSItemProvider] {
        selectedURLs.map { NSItemProvider(object: $0 as NSURL) }
    }

    @MainActor public var canTrash: Bool {
        return !selection.isEmpty
    }

    @MainActor private func files(for scope: Scope) -> Set<FileInfo> {
        switch scope {
        case .selection:
            return selection
        case .file(let file):
            return [file]
        }
    }

    @MainActor public func trash(_ scope: Scope) {
        do {
            let urls = files(for: scope).map { $0.url }
            try urls.forEach { try FileManager.default.trashItem(at: $0, resultingItemURL: nil) }
            directoryModel?.refresh()
        } catch {
            // TODO: Handle this error in the directory model!
            print("Failed to delete file with error \(error).")
        }
    }

    @MainActor public var canMove: Bool {
#if os(macOS)
        return !selection.isEmpty
#else
        return selection.count == 1
#endif
    }

    @MainActor public var canOpen: Bool {
        return !selection.isEmpty
    }

    @MainActor public func open() {
        for url in selectedURLs {
            Application.open(url)
        }
    }

    @MainActor public var canReveal: Bool {
        return !selection.isEmpty
    }

}
