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

    static var cache: NSCache<NSString, NSArray> = {
        return NSCache()
    }()

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    static func dates(from string: String) -> Array<Date> {
        if let dates = Self.cache.object(forKey: string as NSString) as? Array<Date> {
            return dates
        }
        let dates = string.tokens.compactMap { Self.dateFormatter.date(from: $0) }
        Self.cache.setObject(dates as NSArray, forKey: string as NSString)
        return dates
    }

}

class TitleFinder {

    static var cache: NSCache<NSString, NSString> = {
        return NSCache()
    }()

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    static func title(from string: String) -> String {
        if let title = Self.cache.object(forKey: string as NSString) as String? {
            return title
        }
        let names = string.tokens.filter { DateFinder.dateFormatter.date(from: $0) == nil }
        let title = names.joined(separator: " ")
        Self.cache.setObject(title as NSString, forKey: string as NSString)
        return title
    }
}

class FileInfo: Identifiable, Hashable {

    public var id: URL { url }
    let url: URL
    let name: String
    var date: Date?
    var sortDate: Date {
        date ?? Date.distantPast
    }

    let directoryUrl: URL

    init(url: URL) {
        self.url = url
        let name = url.lastPathComponent.deletingPathExtension
        self.date = DateFinder.dates(from: name).first
        let title = TitleFinder.title(from: name)
        self.name = title.isEmpty ? name : title
        self.directoryUrl = url.deletingLastPathComponent()
    }

    static func == (lhs: FileInfo, rhs: FileInfo) -> Bool {
        return lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

}
