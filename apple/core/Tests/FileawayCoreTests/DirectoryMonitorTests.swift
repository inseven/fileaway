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

@testable import FileawayCore

class DirectoryMonitorTests: XCTestCase {

    func testStartEmpty() async throws {

        let rootURL = try createTemporaryDirectory()
        let directoryMonitor = DirectoryMonitor(locations: [rootURL])

        try await expect([[]], directoryMonitor: directoryMonitor) {
            directoryMonitor.start()
        }

    }

    func testStartNonEmpty() async throws {

        let rootURL = try createTemporaryDirectory()
        let directoryMonitor = DirectoryMonitor(locations: [rootURL])

        let directoryURL = rootURL.appending(component: "Directory")
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false)

        let urls = [
            rootURL.appending(component: "file.txt"),
            directoryURL.appending(component: "file2.txt"),
            directoryURL.appending(component: "file3.txt"),
        ]
        createFiles(at: urls)

        try await expect([Set(urls)], directoryMonitor: directoryMonitor) {
            directoryMonitor.start()
        }

    }

//    func testCreateFile() async throws {
//
//        let rootURL = try createTemporaryDirectory()
//
//        let directoryMonitor = try await startedDirectoryMonitor(locations: [rootURL])
//
//        let fileURL = rootURL.appending(component: "file.pdf")
//        try await expect([[fileURL]], directoryMonitor: directoryMonitor) {
//            self.createFiles(at: [fileURL])
//        }
//    }
//
//    func testRemoveFile() async throws {
//        let rootURL = try createTemporaryDirectory()
//
//        let fileURL = rootURL.appending(component: "file.pdf")
//        createFiles(at: [fileURL])
//
//        let directoryMonitor = try await startedDirectoryMonitor(locations: [rootURL])
//
//        try await expect([[]], directoryMonitor: directoryMonitor) {
//            try FileManager.default.removeItem(at: fileURL)
//        }
//    }
//
//    func testMoveInNonEmptyDirectory() async throws {
//        let rootURL = try createTemporaryDirectory()
//
//        let directoryName = "External Directory"
//        let externalDirectoryURL = try createTemporaryDirectory().appending(component: directoryName)
//        let fileNames = [
//            "file.txt",
//            "file1.txt",
//            "file2.txt",
//        ]
//        try fileManager.createDirectory(at: externalDirectoryURL, withIntermediateDirectories: false)
//        createFiles(at: fileNames.map { externalDirectoryURL.appending(component: $0) })
//
//        let directoryURL = rootURL.appending(component: directoryName)
//        let expectedURLs = fileNames.map { directoryURL.appending(component: $0) }
//
//        let directoryMonitor = try await startedDirectoryMonitor(locations: [rootURL])
//
//        try await expect([Set(expectedURLs)], directoryMonitor: directoryMonitor) {
//            try self.fileManager.moveItem(at: externalDirectoryURL, to: directoryURL)
//        }
//
//    }
//
//    func testRemoveNonEmptyDirectory() async throws {
//
//        let rootURL = try createTemporaryDirectory()
//        let directoryURL = rootURL.appending(component: "Directory")
//        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false)
//        let fileURLs = [
//            "file.txt",
//            "file1.txt",
//            "file2.txt",
//        ].map { directoryURL.appending(component: $0) }
//        createFiles(at: fileURLs)
//
//        let directoryMonitor = try await startedDirectoryMonitor(locations: [rootURL])
//
//        // This test differs on macOS and on iOS as the iOS tests use `DirectoryMonitor.refresh` to force through a
//        // change, while macOS relies on the directory monitor. Given this we expect a different number of updates
//        // before quiescence based on the platforms.
//#if os(macOS)
//        let dropCount = 3
//#else
//        let dropCount = 1
//#endif
//        try await expect([[]], directoryMonitor: directoryMonitor, drop: dropCount) {
//            try self.fileManager.removeItem(at: directoryURL)
//        }
//
//    }
//
//    func testMoveOutNonEmptyDirectory() async throws {
//
//        let rootURL = try createTemporaryDirectory()
//        let directoryURL = rootURL.appending(component: "Directory")
//        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false)
//        let fileURLs = [
//            "file.txt",
//            "file1.txt",
//            "file2.txt",
//        ].map { directoryURL.appending(component: $0) }
//        createFiles(at: fileURLs)
//
//        let directoryMonitor = try await startedDirectoryMonitor(locations: [rootURL])
//
//        // This test differs on macOS and on iOS as the iOS tests use `DirectoryMonitor.refresh` to force through a
//        // change, while macOS relies on the directory monitor. Given this we expect a different number of updates
//        // before quiescence based on the platforms.
//#if os(macOS)
//        let dropCount = 3
//#else
//        let dropCount = 1
//#endif
//        let destinationURL = try createTemporaryDirectory()
//        try await expect([[]], directoryMonitor: directoryMonitor, drop: dropCount) {
//            try self.fileManager.moveItem(at: directoryURL, to: destinationURL.appending(component: "Directory"))
//        }
//
//    }
//
//#if os(macOS)
//
//    func testTrashNonEmptyDirectory() async throws {
//        // `FileManager.trashItem` sometimes only results in a single file system event for directory (not events for
//        // it's children) meaning that we need to wait for this test to reach our expectation instead of waiting for
//        // an explicit number of updates. Entertainingly `FileManager.trashItem` also fails on iOS, so we can't even
//        // test it there.
//
//        let rootURL = try createTemporaryDirectory()
//        let directoryURL = rootURL.appending(component: "Directory")
//        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false)
//        let fileURLs = [
//            "file.txt",
//            "file1.txt",
//            "file2.txt",
//        ].map { directoryURL.appending(component: $0) }
//        createFiles(at: fileURLs)
//
//        let directoryMonitor = try await startedDirectoryMonitor(locations: [rootURL])
//
//        let publisher = directoryMonitor
//            .$files
//            .drop { contents in
//                guard let contents = contents else {
//                    return true
//                }
//                return !contents.isEmpty
//            }
//            .first()
//
//        let results = try wait(for: publisher, count: 1, timeout: 3) {
//            DispatchQueue.main.sync {
//                do {
//                    try FileManager.default.trashItem(at: directoryURL, resultingItemURL: nil)
//                } catch {
//                    XCTFail("Failed to trash file with error \(error).")
//                }
//            }
//        }
//
//        XCTAssertEqual(results, [[]])
//    }
//
//#endif
//
//    func testSequentialBasicFileOperations() async throws {
//
//        let fileManager = FileManager.default
//        let rootURL = try createTemporaryDirectory()
//        let fileURL = rootURL.appending(component: "file.pdf")
//        createFiles(at: [fileURL])
//
//        let directoryMonitor = DirectoryMonitor(locations: [rootURL])
//
//        // Start the directory monitor.
//        try await expect([[fileURL]], directoryMonitor: directoryMonitor) {
//            directoryMonitor.start()
//        }
//
//        // Create a file.
//        let file2URL = rootURL.appending(component: "file2.pdf")
//        try await expect([[fileURL, file2URL]], directoryMonitor: directoryMonitor) {
//            self.createFiles(at: [file2URL])
//        }
//
//        // Delete a file.
//        try await expect([[file2URL]], directoryMonitor: directoryMonitor) {
//            try fileManager.removeItem(at: fileURL)
//        }
//
//        // Create a new file in a directory.
//        let subdirectoryURL = rootURL.appending(component: "Directory")
//        let file3URL = subdirectoryURL.appending(component: "file.pdf")
//        try await expect([[file2URL, file3URL]], directoryMonitor: directoryMonitor) {
//            try fileManager.createDirectory(at: subdirectoryURL, withIntermediateDirectories: false)
//            self.createFiles(at: [file3URL])
//        }
//
//        // Move a directory containing files.
//        let externalDirectoryURL = try createTemporaryDirectory().appending(component: "External Directory")
//        try fileManager.createDirectory(at: externalDirectoryURL, withIntermediateDirectories: false)
//        let file4URL = externalDirectoryURL.appending(component: "child.pdf")
//        createFiles(at: [file4URL])
//        let externalDirectoryDestinationURL = rootURL.appending(component: "External Directory")
//        try await expect([[file2URL, file3URL, externalDirectoryDestinationURL.appending(component: "child.pdf")]],
//                                  directoryMonitor: directoryMonitor) {
//            try fileManager.moveItem(at: externalDirectoryURL, to: externalDirectoryDestinationURL)
//        }
//
//        // Since this test is run in a tight loop by `testSoakSequentialBasicFileOperations`, the teardown usually
//        // responsible for stopping `DirectoryMonitor` instances isn't called in a timely fashion and we run out of
//        // file handles unless we call it explicitly here.
//        await directoryMonitor.stop()
//
//    }
//
//    func testSoakSequentialBasicFileOperations() async throws {
//        for _ in 0...100 {
//            try await testSequentialBasicFileOperations()
//        }
//    }

}
