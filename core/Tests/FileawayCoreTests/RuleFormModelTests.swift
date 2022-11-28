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

class RuleFormModelTests: XCTestCase {

    func testLongDateDestination() async throws {

        let inboxURL = try createTemporaryDirectory()
        let archiveURL = try createTemporaryDirectory()

        let rule = RuleModel(id: UUID(),
                             archiveURL: archiveURL,
                             name: "Rule",
                             variables: [],
                             destination: [])
        let variable = rule.createVariable()
        variable.name = "Date"
        variable.type = .date(hasDay: true)

        rule.destination.append(ComponentModel(value: variable.name,
                                               type: .variable,
                                               variable: variable))
        XCTAssertEqual(rule.destination.count, 1)

        dispatchPrecondition(condition: .notOnQueue(.main))

        let applicationModel = await MainActor.run {
            return ApplicationModel()
        }

        let documentURL = inboxURL.appending(component: "document.pdf")
        let ruleFormModel = RuleFormModel(applicationModel: applicationModel, ruleModel: rule, url: documentURL)

        XCTAssertEqual(ruleFormModel.variableFieldModels.count, 1)
        guard let dateFieldModel = ruleFormModel.variableFieldModels.first as? DateFieldModel else {
            XCTFail("Unable to get date variable field.")
            return
        }

        dateFieldModel.date = Calendar.current.date(1971, 3, 27)!

        let destinationURL = await MainActor.run {
            return ruleFormModel.destinationURL
        }

        XCTAssertEqual(destinationURL, archiveURL.appending(component: "1971-03-27.pdf"))
    }

    func testShortDateDestination() async throws {

        let inboxURL = try createTemporaryDirectory()
        let archiveURL = try createTemporaryDirectory()

        let rule = RuleModel(id: UUID(),
                             archiveURL: archiveURL,
                             name: "Rule",
                             variables: [],
                             destination: [])
        let variable = rule.createVariable()
        variable.name = "Date"
        variable.type = .date(hasDay: false)

        rule.destination.append(ComponentModel(value: variable.name,
                                               type: .variable,
                                               variable: variable))
        XCTAssertEqual(rule.destination.count, 1)

        dispatchPrecondition(condition: .notOnQueue(.main))

        let applicationModel = await MainActor.run {
            return ApplicationModel()
        }

        let documentURL = inboxURL.appending(component: "document.pdf")
        let ruleFormModel = RuleFormModel(applicationModel: applicationModel, ruleModel: rule, url: documentURL)

        XCTAssertEqual(ruleFormModel.variableFieldModels.count, 1)
        guard let dateFieldModel = ruleFormModel.variableFieldModels.first as? DateFieldModel else {
            XCTFail("Unable to get date variable field.")
            return
        }

        dateFieldModel.date = Calendar.current.date(1971, 3, 27)!

        let destinationURL = await MainActor.run {
            return ruleFormModel.destinationURL
        }

        XCTAssertEqual(destinationURL, archiveURL.appending(component: "1971-03.pdf"))
    }

}
