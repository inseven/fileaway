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

class RuleModelTests: XCTestCase {

    func testDeepCopy() throws {

        let archiveURL = try createTemporaryDirectory()
        let rule1 = RuleModel(id: UUID(),
                              archiveURL: archiveURL,
                              name: "Rule",
                              variables: [],
                              destination: [])
        _ = rule1.createVariable()
        XCTAssertEqual(rule1.variables.count, 1)
        XCTAssertEqual(rule1.variables[0].name, "Variable 1")
        XCTAssertEqual(rule1.variables[0].type, .string)

        // Ensure that we deep copy a rule so that modifications to the new model do not affect any component
        // of the original.

        // Variables.

        let rule2 = RuleModel(rule1)

        // Duplicate variables should have the same identifiers and should be identical on first copy.
        XCTAssertEqual(rule1.variables[0].id, rule2.variables[0].id)
        XCTAssertEqual(rule1.variables, rule2.variables)

        // Create a new variable and ensure the variable lists now differ.
        _ = rule2.createVariable()
        XCTAssertEqual(rule1.variables.count, 1)
        XCTAssertEqual(rule2.variables.count, 2)

        rule2.variables[0].name = "Description"
        XCTAssertEqual(rule1.variables[0].name, "Variable 1")
        XCTAssertNotEqual(rule1.variables[0].name, rule2.variables[0].name)

        rule2.variables[0].type = .date(hasDay: true)
        XCTAssertEqual(rule1.variables[0].type, .string)
        XCTAssertNotEqual(rule1.variables[0].type, rule2.variables[0].type)

        // Destination.

        // TODO: Test RuleModel.destination deep copy behaviour #510
        //       https://github.com/inseven/fileaway/issues/510
        
    }

}
