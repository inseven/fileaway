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

import Foundation

public class DateFinder {

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    public static func dateInstances(from string: String) -> Array<DateInstance> {
        let types: NSTextCheckingResult.CheckingType = [.date, .phoneNumber]
        let detector = try! NSDataDetector(types: types.rawValue)
        let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        let dateInstances: [[DateInstance]] = matches.compactMap { textCheckingResult in
            guard let date = textCheckingResult.date else {
                return nil
            }
            var results = [DateInstance(date: date, range: textCheckingResult.range)]
            if textCheckingResult.duration > 0 {
                let end = date.addingTimeInterval(textCheckingResult.duration)
                results.append(DateInstance(date: end, range: textCheckingResult.range))
            }
            return results
        }
        return dateInstances.flatMap { $0 }
    }

}
