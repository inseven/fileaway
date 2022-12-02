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

class URLTests: XCTestCase {

    func testRelativePath() {
        let parentURL = URL(string: "file:///Documents/Paperwork/")!
        let childURL = URL(string: "file:///Documents/Paperwork/Accommodation/2022-11-22%20House%20Correspondence.pdf")!
        XCTAssertEqual(childURL.relativePath(from: parentURL), "Accommodation/2022-11-22 House Correspondence.pdf")
    }

    func testParent() {
        XCTAssertTrue(URL(fileURLWithPath: "/a").isParent(of: URL(fileURLWithPath: "/a/b")))
        XCTAssertFalse(URL(fileURLWithPath: "/a").isParent(of: URL(fileURLWithPath: "/abba/b")))
    }

}

