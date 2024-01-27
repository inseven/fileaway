// Copyright (c) 2018-2024 Jason Morley
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

import SwiftUI
import UniformTypeIdentifiers

extension NSItemProvider {

    convenience init(object: Codable, type: UTType) {
        self.init()
        registerDataRepresentation(forTypeIdentifier: type.identifier, visibility: .all) {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(object)
                $0(data, nil)
            } catch {
                $0(nil, error)
            }
            return nil
        }
    }

}

// See https://stackoverflow.com/questions/71764564/moving-table-rows-in-swiftui.
extension Array where Element == NSItemProvider {

    func loadObjects<T: Codable>(ofClass: T.Type, forType type: UTType, completionHandler: @escaping ([T]) -> Void) {

        let dispatchGroup = DispatchGroup()
        var result: [Int: T] = [:]

        let filteredProviders = filter { itemProvider in
            itemProvider.hasItemConformingToTypeIdentifier(type.identifier)
        }

        for (index, itemProvider) in filteredProviders.enumerated() {
            dispatchGroup.enter()
            itemProvider.loadDataRepresentation(forTypeIdentifier: type.identifier) { (data, error) in
                defer {
                    dispatchGroup.leave()
                }
                guard let data = data else {
                    print("Failed to load provider data representation with error \(String(describing: error)).")
                    return
                }
                let decoder = JSONDecoder()
                guard let channel = try? decoder.decode(T.self, from: data) else {
                    return
                }
                result[index] = channel
            }
        }

        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            let objects = result.keys.sorted().compactMap { result[$0] }
            DispatchQueue.main.async {
                completionHandler(objects)
            }
        }

    }

}
