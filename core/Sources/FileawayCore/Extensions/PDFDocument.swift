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

import Combine
import Foundation
import PDFKit

enum PDFDocumentUtilitiesError: Error {
    case failure
}

public extension PDFDocument {

    static func open(url: URL) -> Future<PDFDocument, Error> {
        return Future() { promise in
            DispatchQueue.global(qos: .userInteractive).async {
                guard let document = PDFDocument(url: url) else {
                    promise(.failure(PDFDocumentUtilitiesError.failure))
                    return
                }
                promise(.success(document))
            }
        }
    }

    func dates() -> [Date] {
        let pageCount = self.pageCount
        let documentContent = NSMutableAttributedString()
        for i in 0 ..< pageCount {
            guard let page = self.page(at: i) else { continue }
            guard let pageContent = page.attributedString else { continue }
            documentContent.append(pageContent)
        }
        let dates = DateFinder.dateInstances(from: documentContent.string).map { $0.date }.uniqued()
        return dates
    }

    func reverse() -> PDFDocument {
        let documentCopy = self.copy() as! PDFDocument
        for forwardIndex: Int in 0..<documentCopy.pageCount / 2 {
            let backwardIndex = documentCopy.pageCount - forwardIndex - 1
            documentCopy.exchangePage(at: forwardIndex, withPageAt: backwardIndex)
        }
        return documentCopy
    }

    func interleave(_ document: PDFDocument) -> PDFDocument {
        let new = PDFDocument()
        let documents: [PDFDocument] = [self.copy() as! PDFDocument, document.copy() as! PDFDocument]
        while documents.map({ $0.pageCount }).reduce(0, +) > 0 {
            for document in documents {
                guard document.pageCount > 0 else {
                    continue
                }
                let page = document.page(at: 0)?.copy() as! PDFPage
                document.removePage(at: 0)
                new.insert(page, at: new.pageCount)
            }
        }
        return new
    }

    
}
