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

class TitleFinderTests: XCTestCase {

    var calendar: Calendar = Calendar.gregorian

    func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.gregorian.date(year, month, day)!
    }

    func testSingleDate() {
        XCTAssertEqual(TitleFinder.title(from: "2018-12-23 Document title"),
                       "Document title")
    }

    func testSingleDateLeadingWhitespace() {
        XCTAssertEqual(TitleFinder.title(from: " 2018-12-23 Document title"),
                       "Document title")
    }

    func testComplexDate() {
        XCTAssertEqual(TitleFinder.title(from: "Dec 23, 2018 Document title"),
                       "Document title")
    }

    func testMultipleDates() {
        XCTAssertEqual(TitleFinder.title(from: "2018-12-23 Document title 2021-05-19"),
                       "Document title 2021-05-19")
    }

    func testFirstDateWithinString() {
        XCTAssertEqual(TitleFinder.title(from: "Document title 2018-12-23 Further details"),
                       "Document title 2018-12-23 Further details")
    }

    func testDateOnlyStringYieldsTitle() {
        // Strings that contain just a date should return the full string.
        XCTAssertEqual(TitleFinder.title(from: "Dec 28, 1982"),
                       "Dec 28, 1982")
        XCTAssertEqual(TitleFinder.title(from: "1982-12-28"),
                       "1982-12-28")
    }

    func testStringWithoutDate() {
        // Strings that contain just a date should return the full string.
        XCTAssertEqual(TitleFinder.title(from: "Fromage"),
                       "Fromage")
    }

    func testTrimming() {
        XCTAssertEqual(TitleFinder.title(from: " 1982-12-28"),
                       "1982-12-28")
        XCTAssertEqual(TitleFinder.title(from: "1982-12-28 "),
                       "1982-12-28")
        XCTAssertEqual(TitleFinder.title(from: " 1982-12-28 "),
                       "1982-12-28")
        XCTAssertEqual(TitleFinder.title(from: " Date outside string 1982-12-28 Cheese"),
                       "Date outside string 1982-12-28 Cheese")
        XCTAssertEqual(TitleFinder.title(from: "Date outside string 1982-12-28 Cheese "),
                       "Date outside string 1982-12-28 Cheese")
    }

    func testEmptyString() {
        XCTAssertEqual(TitleFinder.title(from: ""),
                       "")
        XCTAssertEqual(TitleFinder.title(from: " "),
                       "")
        XCTAssertEqual(TitleFinder.title(from: "\t"),
                       "")
        XCTAssertEqual(TitleFinder.title(from: "\n"),
                       "")
    }

}
