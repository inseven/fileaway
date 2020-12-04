//
//  FileInfo.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 04/12/2020.
//

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

    init(url: URL) {
        self.url = url
        let name = url.lastPathComponent.deletingPathExtension
        self.date = DateFinder.dates(from: name).first
        let title = TitleFinder.title(from: name)
        self.name = title.isEmpty ? name : title
    }

    static func == (lhs: FileInfo, rhs: FileInfo) -> Bool {
        return lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

}
