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

import Foundation

class DateFinder {

    // TODO: Revisit the caching in DateFinder and TitleFinder #160
    //       https://github.com/jbmorley/fileaway/issues/160
    static var cache: NSCache<NSString, NSArray> = {
        return NSCache()
    }()

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    static func dateInstances(from string: String) -> Array<DateInstance> {

        // Check the cache.
        if let dates = Self.cache.object(forKey: string as NSString) as? Array<DateInstance> {
            return dates
        }

        // Find the dates.
        let types: NSTextCheckingResult.CheckingType = [.date]
        let detector = try! NSDataDetector(types: types.rawValue)
        let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        let dateInstances: Array<DateInstance> = matches.compactMap { textCheckingResult in
            guard let date = textCheckingResult.date else {
                return nil
            }
            return DateInstance(date: date, range: textCheckingResult.range)
        }

        // Update the cache.
        Self.cache.setObject(dateInstances as NSArray, forKey: string as NSString)

        return dateInstances
    }

}
