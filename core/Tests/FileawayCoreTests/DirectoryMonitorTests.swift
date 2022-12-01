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

import XCTest

@testable import FileawayCore

// TODO: Ensure the directory monitor ignores duplicates.
// TODO: How do we deal with files that have changed; we should probably include the mtime too since this is used
//       to determine whether we fetch the updates.

class DirectoryMonitorTests: XCTestCase {

    func expect(_ snapshots: [Set<URL>?],
                directoryMonitor: DirectoryMonitor,
                file: StaticString = #file,
                line: UInt = #line,
                perform: @MainActor @escaping () throws -> Void) async throws {

        let publisher = directoryMonitor
            .$files
            .dropFirst()
            .map { $0?.standardizingFileURLs() }

        // Perform the block of changes after a delay to ensure we've already subscribed to the publisher.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try? perform()
#if os(iOS)
            // Directory monitoring isn't automatic on iOS and requires external / manual updates.
            // This is achieved either by an explict user-triggered refresh operation, or a foregrounding of the app.
            // In these tests, we simulate an explicit refresh operation.
            directoryMonitor.refresh()
#endif
        }

        let files = try wait(for: publisher, count: snapshots.count, timeout: 10, file: file, line: line)
        XCTAssertEqual(files, snapshots, file: file, line: line)
    }

    func testSoakBasicFileOperations() async throws {
        for _ in 0...100 {
            try await testBasicFileOperations()
        }
    }

    func testBasicFileOperations() async throws {

        let fileManager = FileManager.default
        let rootURL = try createTemporaryDirectory()
        let fileURL = rootURL.appending(component: "file.pdf")
        fileManager.createFile(at: fileURL)

        let directoryMonitor = DirectoryMonitor(locations: [rootURL])

        // Start the directory monitor.
        try await expect([[fileURL]], directoryMonitor: directoryMonitor) {
            directoryMonitor.start()
        }

        // Create a file.
        let file2URL = rootURL.appending(component: "file2.pdf")
        try await expect([[fileURL, file2URL]], directoryMonitor: directoryMonitor) {
            fileManager.createFile(at: file2URL)
        }

        // Delete a file.
        try await expect([[file2URL]], directoryMonitor: directoryMonitor) {
            try fileManager.removeItem(at: fileURL)
        }

        // Create a new file in a directory.
        let subdirectoryURL = rootURL.appending(component: "Directory")
        let file3URL = subdirectoryURL.appending(component: "file.pdf")
        try await expect([[file2URL, file3URL]], directoryMonitor: directoryMonitor) {
            try fileManager.createDirectory(at: subdirectoryURL, withIntermediateDirectories: false)
            fileManager.createFile(at: file3URL)
        }

        // Move a directory containing files.
        let externalDirectoryURL = try createTemporaryDirectory().appending(component: "External Directory")
        try fileManager.createDirectory(at: externalDirectoryURL, withIntermediateDirectories: false)
        let file4URL = externalDirectoryURL.appending(component: "child.pdf")
        fileManager.createFile(at: file4URL)
        let externalDirectoryDestinationURL = rootURL.appending(component: "External Directory")
        try await expect([[file2URL, file3URL, externalDirectoryDestinationURL.appending(component: "child.pdf")]],
                                  directoryMonitor: directoryMonitor) {
            try fileManager.moveItem(at: externalDirectoryURL, to: externalDirectoryDestinationURL)
        }

        // TODO: Move directory containing multiple files.

        // TODO: Delete directory containing files?

    }

}
