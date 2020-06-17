//
//  FakeDuplexTask.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Combine
import Foundation
import PDFKit

class FakeDuplexTask {

    private var task: AnyCancellable?

    func perform(url1: URL, url2: URL, output: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        task = Publishers.Zip(PDFDocument.open(url: url1), PDFDocument.open(url: url2).map { $0.reverse() })
            .map { $0.interleave($1) }
            .map { $0.write(to: output) }
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
