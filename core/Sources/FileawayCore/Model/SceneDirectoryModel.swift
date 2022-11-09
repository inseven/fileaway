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

public class SceneDirectoryModel: ObservableObject, Identifiable {

    public var id: URL { self.url }

    @Published public var files: [FileInfo] = []
    @Published public var filter: String = ""

    private var directoryModel: DirectoryModel
    private var cancelables: Set<AnyCancellable> = []
    private let syncQueue = DispatchQueue.init(label: "SceneDirectoryModel.syncQueue")

    public var type: DirectoryModel.DirectoryType {
        return directoryModel.type
    }

    public var url: URL {
        return directoryModel.url
    }

    public var name: String {
        return directoryModel.name
    }

    public init(directoryModel: DirectoryModel) {
        self.directoryModel = directoryModel
    }

    @MainActor public func start() {

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

    }

    @MainActor public func stop() {
        cancelables.removeAll()
    }

}
