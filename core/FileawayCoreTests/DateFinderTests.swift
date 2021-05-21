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

import XCTest

@testable import FileawayCore

extension Array where Element == Date {

    func matches(_ array: Array<Element>, granularity: Calendar.Component) -> Bool {
        guard self.count == array.count else {
            return false
        }
        for (index, date) in enumerated() {
            if Calendar.gregorian.compare(date, to: array[index], toGranularity: granularity) != .orderedSame {
                return false
            }
        }
        return true
    }

}

class DateFinderTests: XCTestCase {

    var calendar: Calendar = Calendar.gregorian

    func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.gregorian.date(year, month, day)!
    }

    func dates(from string: String) -> Array<Date> {
        return DateFinder.dateInstances(from: string).map { $0.date }
    }

    func testDateFromString() {
        XCTAssertTrue(dates(from: "2018-12-23 Document title")
                        .matches([date(2018, 12, 23)], granularity: .day))
    }

    func testMultipleDatesFromString() {
        XCTAssertTrue(dates(from: "2018-12-23 Document title 2021-05-19")
                        .matches([date(2018, 12, 23), date(2021, 05, 19)], granularity: .day))
    }

    func testPackedISO8601() {
        XCTAssertTrue(dates(from: "20181223 Document title")
                        .matches([date(2018, 12, 23)], granularity: .day))
    }

    func testRichFormat() {
        XCTAssertTrue(dates(from: "Dec 1, 2018 Document title")
                        .matches([date(2018, 12, 1)], granularity: .day))
    }

    func testDateRange() {
        XCTExpectFailure("Date detection fails on date ranges")
        XCTAssertTrue(dates(from: "19 May 2021 - 18 May 2022")
                        .matches([date(2021, 5, 19), date(2022, 5, 18)], granularity: .day))
    }


}
