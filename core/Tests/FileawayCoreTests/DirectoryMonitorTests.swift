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

    // TODO: This shouldn't be escaping?
    func expect(_ contents: [Set<URL>?],
                directoryMonitor: DirectoryMonitor,
                file: StaticString = #file,
                line: UInt = #line,
                perform action: @MainActor @escaping () throws -> Void) async throws {

        let publisher = directoryMonitor
            .$files
            .dropFirst()
            .map { $0?.standardizingFileURLs() }

        let files = try wait(for: publisher, count: contents.count, timeout: 10, file: file, line: line) {
            DispatchQueue.main.sync {
                try? action()
                directoryMonitor.refresh()
            }
        }
        XCTAssertEqual(files, contents, file: file, line: line)
    }

    var fileManager: FileManager {
        return FileManager.default
    }

    func startedDirectoryMonitor(locations: [URL]) async throws -> DirectoryMonitor {

        let directoryMonitor = DirectoryMonitor(locations: locations)

        let publisher = directoryMonitor
            .$files
            .dropFirst()
            .collect(1)
            .first()

        _ = try wait(for: publisher, timeout: 3) {
            DispatchQueue.main.sync {
                directoryMonitor.start()
            }
        }

        // TODO: This doesn't seem to actually stop the monitor in a timely fashion. Why?
        addTeardownBlock {
            directoryMonitor.stop()
        }

        return directoryMonitor
    }

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

    func testCreateFile() async throws {

        let rootURL = try createTemporaryDirectory()

        let directoryMonitor = try await startedDirectoryMonitor(locations: [rootURL])

        let fileURL = rootURL.appending(component: "file.pdf")
        try await expect([[fileURL]], directoryMonitor: directoryMonitor) {
            self.createFiles(at: [fileURL])
        }
    }

    func testRemoveFile() async throws {
        let rootURL = try createTemporaryDirectory()

        let fileURL = rootURL.appending(component: "file.pdf")
        createFiles(at: [fileURL])

        let directoryMonitor = try await startedDirectoryMonitor(locations: [rootURL])

        try await expect([[]], directoryMonitor: directoryMonitor) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    func createFiles(at urls: [URL], file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(fileManager.createFiles(at: urls), file: file, line: line)
    }

    func testMoveNonEmptyDirectory() async throws {
        let rootURL = try createTemporaryDirectory()

        let directoryName = "External Directory"
        let externalDirectoryURL = try createTemporaryDirectory().appending(component: directoryName)
        let fileNames = [
            "file.txt",
            "file1.txt",
            "file2.txt",
        ]
        try fileManager.createDirectory(at: externalDirectoryURL, withIntermediateDirectories: false)
        createFiles(at: fileNames.map { externalDirectoryURL.appending(component: $0) })

        let directoryURL = rootURL.appending(component: directoryName)
        let expectedURLs = fileNames.map { directoryURL.appending(component: $0) }

        let directoryMonitor = try await startedDirectoryMonitor(locations: [rootURL])

        try await expect([Set(expectedURLs)], directoryMonitor: directoryMonitor) {
            // TODO: This shouldn't need to be self.
            try self.fileManager.moveItem(at: externalDirectoryURL, to: directoryURL)
        }

    }

    func testSequentialBasicFileOperations() async throws {

        let fileManager = FileManager.default
        let rootURL = try createTemporaryDirectory()
        let fileURL = rootURL.appending(component: "file.pdf")
        createFiles(at: [fileURL])

        let directoryMonitor = DirectoryMonitor(locations: [rootURL])

        // Start the directory monitor.
        try await expect([[fileURL]], directoryMonitor: directoryMonitor) {
            directoryMonitor.start()
        }

        // Create a file.
        let file2URL = rootURL.appending(component: "file2.pdf")
        try await expect([[fileURL, file2URL]], directoryMonitor: directoryMonitor) {
            self.createFiles(at: [file2URL])
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
            self.createFiles(at: [file3URL])
        }

        // Move a directory containing files.
        let externalDirectoryURL = try createTemporaryDirectory().appending(component: "External Directory")
        try fileManager.createDirectory(at: externalDirectoryURL, withIntermediateDirectories: false)
        let file4URL = externalDirectoryURL.appending(component: "child.pdf")
        createFiles(at: [file4URL])
        let externalDirectoryDestinationURL = rootURL.appending(component: "External Directory")
        try await expect([[file2URL, file3URL, externalDirectoryDestinationURL.appending(component: "child.pdf")]],
                                  directoryMonitor: directoryMonitor) {
            try fileManager.moveItem(at: externalDirectoryURL, to: externalDirectoryDestinationURL)
        }

        // TODO: Move directory containing multiple files.

        // TODO: Delete directory containing files?


        // Explicitly stop the directory monitor.
        // TODO: We probably have a retain cycle as this shouldn't be necessary
        directoryMonitor.stop()

    }

    func testSoakSequentialBasicFileOperations() async throws {
        for _ in 0...1000 {
            try await testSequentialBasicFileOperations()
        }
    }

}
