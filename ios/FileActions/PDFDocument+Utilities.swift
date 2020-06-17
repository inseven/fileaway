//
//  PDFDocument+Utilities.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Combine
import Foundation
import PDFKit

enum PDFDocumentUtilitiesError: Error {
    case failure
}

extension PDFDocument {

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
