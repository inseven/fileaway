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
import XCTest

extension XCTestCase {

    func createTemporaryDirectory() throws -> URL {

        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        var isDirectory: ObjCBool = false
        XCTAssertTrue(fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory))
        XCTAssert(isDirectory.boolValue)

        addTeardownBlock {
            do {
                let fileManager = FileManager.default
                try fileManager.removeItem(at: directoryURL)
                XCTAssertFalse(fileManager.fileExists(atPath: directoryURL.path))
            } catch {
                XCTFail("Failed to delete temporary directory with error \(error).")
            }
        }

        return directoryURL
    }

    // Based on https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/.
    func wait<T: Publisher>(for publisher: T,
                            timeout: TimeInterval = 10,
                            file: StaticString = #file,
                            line: UInt = #line,
                            perform action: (() throws -> Void)? = nil) throws -> T.Output {

        var result: Result<T.Output, Error>?
        let expectation = expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        // Perform any requested operation after we've created the subscription to ensure that changes aren't missed.
        try action?()

        wait(for: [expectation], timeout: timeout)
        cancellable.cancel()

        let unwrappedResult = try XCTUnwrap(result,
                                            "Awaited publisher did not produce any output",
                                            file: file,
                                            line: line)

        return try unwrappedResult.get()
    }

    func wait<T: Publisher>(for publisher: T,
                            count: Int,
                            timeout: TimeInterval = 10,
                            file: StaticString = #file,
                            line: UInt = #line,
                            perform action: (() throws -> Void)? = nil) throws -> Publishers.First<Publishers.CollectByCount<T>>.Output {
        return try wait(for: publisher.collect(count).first(), timeout: timeout, file: file, line: line, perform: action)
    }

}
