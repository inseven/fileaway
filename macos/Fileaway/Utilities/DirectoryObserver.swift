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


class DirectoryObserver: ObservableObject, Identifiable {

    public var id: UUID = UUID()
    var name: String
    var locations: [URL]
    var extensions = ["pdf"]
    var count: Int { self.files.count }
    @Published var searchResults: [FileInfo] = []

    var fileProvider: FileProvider?

    let syncQueue = DispatchQueue.init(label: "DirectoryObserver.syncQueue")

    init(name: String, locations: [URL]) {
        self.name = name
        self.locations = locations
    }

    var activeFilter = "" {
        didSet {
            self.objectWillChange.send()
            self.applyFilter()
        }
    }

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

    func applyFilter() {
        dispatchPrecondition(condition: .onQueue(.main))
        let files = Array(self.files)
        let filter = String(activeFilter)
        syncQueue.async {
            let results = files
                .map { FileInfo(url: $0) }
                .filter {
                    filter.isEmpty ||
                        $0.name.localizedSearchMatches(string: filter)
                }
                .sorted { fileInfo1, fileInfo2 -> Bool in
                    let dateComparison = fileInfo1.sortDate.compare(fileInfo2.sortDate)
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
        self.fileProvider = try! FileProvider(locations: locations,
                                              extensions: extensions,
                                              targetQueue: DispatchQueue.main,
                                              handler: { urls in
                                                self.files = urls
                                              })
        self.fileProvider?.start()
    }

}
