//
//  ReverseTask.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Combine
import Foundation
import PDFKit

class ReverseTask {

    private var task: AnyCancellable?

    func reverse(url: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.task = PDFDocument.open(url: url)
            .map { $0.reverse() }
            .map { $0.write(to: url) }
            .eraseToAnyPublisher()
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
