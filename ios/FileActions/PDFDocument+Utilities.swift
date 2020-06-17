//
//  PDFDocument+Utilities.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation
import PDFKit

enum PDFDocumentUtilitiesError: Error {
    case failure
}

extension PDFDocument {

    public static func reverse(url: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        let queueCompletion: (Result<Bool, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        DispatchQueue.global(qos: .userInteractive).async {
            guard let document = PDFDocument(url: url) else {
                queueCompletion(.failure(PDFDocumentUtilitiesError.failure))
                return
            }
            let reversed = document.reverse()
            let success = reversed.write(to: url)
            if success {
                queueCompletion(.success(true))
            } else {
                queueCompletion(.failure(PDFDocumentUtilitiesError.failure))
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
        let documentCopy = self.copy() as! PDFDocument
        for index: Int in 0..<document.pageCount {
            let pageCopy = document.page(at: index)?.copy() as! PDFPage
            documentCopy.insert(pageCopy, at: (index * 2) + 1)
        }
        return documentCopy
    }

}
