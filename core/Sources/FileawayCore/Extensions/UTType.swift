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

import UniformTypeIdentifiers

extension UTType: Identifiable {
    
    public static let rules = UTType(exportedAs: "app.fileaway.types.rules")
    public static var component = UTType(exportedAs: "app.fileaway.types.component")

    public static var doc = UTType(filenameExtension: "doc")!
    public static var docx = UTType(filenameExtension: "docx")!
    public static var numbers = UTType(filenameExtension: "numbers")!
    public static var pages = UTType(filenameExtension: "pages")!
    public static var xls = UTType(filenameExtension: "xls")!
    public static var xlsx = UTType(filenameExtension: "xlsx")!


    public var id: String { self.identifier }

    public var localizedDisplayName: String {
        if let localizedDescription = localizedDescription {
            return localizedDescription
        }
        if let preferredFilenameExtension = preferredFilenameExtension {
            return preferredFilenameExtension
        }
        if let preferedMIMEType = preferredMIMEType {
            return preferedMIMEType
        }
        return "Unknown Type"
    }

    public func conforms(to types: Set<UTType>) -> Bool {
        if types.contains(self) {
            return true
        }
        for type in supertypes {
            if types.contains(type) {
                return true
            }
        }
        return false
    }
    
}
