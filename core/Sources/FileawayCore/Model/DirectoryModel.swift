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
import UniformTypeIdentifiers

import Interact

public class DirectoryModel: ObservableObject, Identifiable, Hashable {

    public enum DirectoryType: String {
        case inbox = "inbox"
        case archive = "archive"
    }

    public static func == (lhs: DirectoryModel, rhs: DirectoryModel) -> Bool {
        return lhs.id == rhs.id
    }

    public let id: UUID = UUID()
    public let type: DirectoryType
    public let url: URL
    public let ruleSet: RulesModel

    public var count: Int { files.count }
    public var name: String { url.displayName }

    @Published public var files: [FileInfo] = []
    @Published public var isLoading: Bool = true

    private let settings: Settings
    private let syncQueue = DispatchQueue.init(label: "DirectoryModel.syncQueue")
    private var directoryMonitor: DirectoryMonitor
    private var cache: NSCache<NSURL, FileInfo> = NSCache()
    private var cancelables: Set<AnyCancellable> = []

    public init(settings: Settings, type: DirectoryType, url: URL) {
        self.settings = settings
        self.type = type
        self.url = url
        self.ruleSet = RulesModel(url: url)
        self.directoryMonitor = DirectoryMonitor(locations: [url])
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    @MainActor public func start() {

        directoryMonitor.start()

        directoryMonitor
            .$files
            .compactMap { $0 }  // nil is a marker that the data is loading
            .combineLatest(settings.$types)
            .receive(on: syncQueue)
            .map { files, types in
                let files = files
                    .compactMap { url -> FileInfo? in

                        // Filter by file type.
                        guard let type = UTType(filenameExtension: url.pathExtension), type.conforms(to: types) else {
                            return nil
                        }

                        // Load file info from the cache if we have it, updating if not.
                        if let fileInfo = self.cache.object(forKey: url as NSURL) {
                            return fileInfo
                        }
                        let fileInfo = FileInfo(url: url)
                        self.cache.setObject(fileInfo, forKey: url as NSURL)

                        return fileInfo
                    }
                return files
            }
            .receive(on: DispatchQueue.main)
            .sink { files in
                self.files = files
                self.isLoading = false
            }
            .store(in: &cancelables)
    }

    @MainActor public func stop() {
        directoryMonitor.stop()
        cancelables.removeAll()
    }

    @MainActor public func refresh() {
        directoryMonitor.refresh()
    }

}
