// Copyright (c) 2018-2023 InSeven Limited
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

// TODO: Comprehensive RulesModel tests #500
//       https://github.com/inseven/fileaway/issues/500
class RulesModelTests: XCTestCase {

    func emptyModel() throws -> RulesModel {
        let archiveURL = try createTemporaryDirectory()
        let rules = RulesModel(archiveURL: archiveURL)
        return rules
    }

    func testNewRule() throws {
        let archiveURL = try createTemporaryDirectory()

        let rules = RulesModel(archiveURL: archiveURL)
        XCTAssert(rules.ruleModels.isEmpty)

        let rule = try rules.new()
        XCTAssertEqual(rule.archiveURL, archiveURL)
        XCTAssertEqual(rule.name, "Rule")
        XCTAssertEqual(rules.ruleModels.count, 1)
    }

    func testDuplicate() throws {
        let rules = try emptyModel()

        let rule1 = try rules.new()
        let duplicates = try rules.duplicate(ids: [rule1.id])
        XCTAssertEqual(duplicates.count, 1)
        XCTAssertEqual(rules.ruleModels.count, 2)

        guard let rule2 = duplicates.first else {
            XCTFail("Failed to get first duplicate rule.")
            return
        }

        XCTAssertNotEqual(rule2.id, rule1.id)
        XCTAssertEqual(rule2.archiveURL, rule1.archiveURL)
        XCTAssertEqual(rule2.name, "Copy of Rule")
        XCTAssertEqual(rule2.variables, rule1.variables)
        XCTAssertEqual(rule2.destination, rule1.destination)
    }

}
