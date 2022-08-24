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

public class FileInfo: Identifiable, Hashable {

    static func filenameDate(url: URL) -> FileDate? {
        guard let date = DateFinder.dateInstances(from: url.displayName.deletingPathExtension).map({ $0.date }).first else {
            return nil
        }
        return FileDate(date: date, type: .filename)
    }

    static func creationDate(url: URL) -> FileDate? {
        guard let date = (try? FileManager.default.attributesOfItem(atPath: url.path))?[.creationDate] as? Date else {
            return nil
        }
        return FileDate(date: date, type: .creation)
    }

    static func unknownDate() -> FileDate {
        return FileDate(date: Date.distantPast, type: .unknown)
    }

    public var id: URL { url }
    
    public let url: URL
    public let name: String
    public var date: FileDate
    public let directoryUrl: URL

    public init(url: URL) {
        self.url = url
        let name = url.displayName.deletingPathExtension
        self.date = Self.filenameDate(url: url) ?? Self.creationDate(url: url) ?? Self.unknownDate()
        let title = TitleFinder.title(from: name)
        self.name = title.isEmpty ? name : title
        self.directoryUrl = url.deletingLastPathComponent()
    }

    public static func == (lhs: FileInfo, rhs: FileInfo) -> Bool {
        return lhs.url == rhs.url
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

}
