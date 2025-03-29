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

import XCTest

import Collections

@testable import FileawayCore

extension OrderedDictionary where Key == URL, Value == FileInfo {

    func standardizingFileURLs() -> Self {
        var result = Self()
        for (url, fileInfo) in self {
            result[url.standardizedFileURL] = fileInfo.standardizingFileURL()
        }
        return result
    }

}

class DirectoryViewModelTests: XCTestCase {

    func testRemoveFileUpdatesSelection() async throws {
        let rootURL = try createTemporaryDirectory()
        let fileURL = rootURL.appending(component: "file.pdf")
        createFiles(at: [fileURL])

        let directoryModel = DirectoryModel(settings: Settings(), type: .inbox, url: rootURL)
        let directoryViewModel = DirectoryViewModel(directoryModel: directoryModel)

        let publisher = directoryViewModel
            .$files
            .dropFirst(1)
            .map { $0.standardizingFileURLs() }

        let result = try wait(for: publisher, count: 1, timeout: 3) {
            DispatchQueue.main.sync {
                directoryModel.start()
                directoryViewModel.start()
            }
        }

        let expectedURLs = [
            fileURL,
        ]
        let expectedFileInfos = expectedURLs
            .map { $0.standardizedFileURL }
            .map { FileInfo(url: $0) }
            .reduce(into: OrderedDictionary<URL, FileInfo>()) { partialResult, fileInfo in
                partialResult[fileInfo.url] = fileInfo
            }

        XCTAssertEqual(result, [expectedFileInfos])
        XCTAssertEqual(directoryViewModel.selection, [])

        guard let fileInfo = result.first?.values.first else {
            XCTFail("Failed to get first file.")
            return
        }

        let selection = try wait(for: directoryViewModel.$selection.dropFirst(), count: 1, timeout: 3) {
            DispatchQueue.main.sync {
                directoryViewModel.selection = [fileInfo]
            }
        }

        XCTAssertEqual(selection, [[fileInfo]])


        let updatedSelection = try wait(for: directoryViewModel.$selection.dropFirst(), count: 1, timeout: 3) {
            DispatchQueue.main.sync {
                do {
                    try self.fileManager.removeItem(at: fileInfo.url)
#if os(iOS)
                    directoryViewModel.refresh()
#endif
                } catch {
                    XCTFail("Failed to perform update action with error \(error).")
                }
            }
        }

        XCTAssertEqual(updatedSelection, [[]])
    }

}
