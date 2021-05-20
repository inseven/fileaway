// Copyright (c) 2018-2021 InSeven Limited
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

class DirectoryObserver: ObservableObject, Identifiable, Hashable {

    enum DirectoryType {
        case inbox
        case archive
    }

    static func == (lhs: DirectoryObserver, rhs: DirectoryObserver) -> Bool {
        return lhs.id == rhs.id
    }

    public var id: UUID = UUID()

    var type: DirectoryType
    var url: URL
    var extensions = ["pdf"]

    var count: Int { self.files.count }
    var name: String { url.displayName }

    @Published var searchResults: [FileInfo] = []
    var ruleSet: RuleSet

    var fileProvider: FileProvider?

    let syncQueue = DispatchQueue.init(label: "DirectoryObserver.syncQueue")

    var activeFilter = "" {
        didSet {
            self.objectWillChange.send()
            self.applyFilter()
        }
    }

    var cache: NSCache<NSURL, FileInfo> = NSCache()

    lazy var filter: Binding<String> = { Binding {
        self.activeFilter
    } set: { newValue in
        self.activeFilter = newValue
    }}()

    @Published var files: Set<URL> = Set() {
        didSet {
            applyFilter()
        }
    }

    init(type: DirectoryType, url: URL) {
        self.type = type
        self.url = url
        self.ruleSet = RuleSet(url: url)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func syncQueue_fileInfo(for url: URL) -> FileInfo {
        dispatchPrecondition(condition: .onQueue(syncQueue))
        if let fileInfo = cache.object(forKey: url as NSURL) {
            return fileInfo
        }
        let fileInfo = FileInfo(url: url)
        cache.setObject(fileInfo, forKey: url as NSURL)
        return fileInfo
    }

    func applyFilter() {
        dispatchPrecondition(condition: .onQueue(.main))
        let files = Array(self.files)
        let filter = String(activeFilter)
        syncQueue.async {
            let results = files
                .map { self.syncQueue_fileInfo(for: $0) }
                .filter {
                    filter.isEmpty ||
                        $0.name.localizedSearchMatches(string: filter)
                }
                .sorted { fileInfo1, fileInfo2 -> Bool in
                    let dateComparison = fileInfo1.date.date.compare(fileInfo2.date.date)
                    if dateComparison != .orderedSame {
                        return dateComparison == .orderedDescending
                    }
                    return fileInfo1.name.compare(fileInfo2.name) == .orderedAscending
                }

            DispatchQueue.main.async {
                self.objectWillChange.send()
                self.searchResults = results
            }
        }
    }

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))
        self.fileProvider = try! FileProvider(locations: [url],
                                              extensions: extensions,
                                              targetQueue: DispatchQueue.main,
                                              handler: { urls in
                                                self.files = urls
                                              })
        self.fileProvider?.start()
    }

    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        guard let fileProvider = fileProvider else {
            return
        }
        fileProvider.stop()
    }

}
