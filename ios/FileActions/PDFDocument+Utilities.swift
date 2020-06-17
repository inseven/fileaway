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

class ReverseTask {

    private var task: AnyCancellable?

    func reverse(url: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.task = PDFDocument.reverse(url: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                }
            }) { document in
                completion(.success(true))
        }
    }

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

    static func reverse(url: URL) -> AnyPublisher<Bool, Error> {
        return self.open(url: url)
            .map { $0.reverse() }
            .map { $0.write(to: url) }
            .eraseToAnyPublisher()
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
