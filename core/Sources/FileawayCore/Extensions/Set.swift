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

extension Set where Element == URL {

    // TODO: Name this appropriately.
    func descendents(of url: URL) -> Set<URL> {
        return filter { url == $0 || url.isParent(of: $0) }
    }

    func descendents(of urls: Set<URL>) -> Set<URL> {
        return urls
            .map { url in
                return descendents(of: url)
            }
            .reduce(into: Set<URL>()) { partialResult, urls in
                partialResult.formUnion(urls)
            }
    }

    func removingURLsAndDescendents(of urls: Set<URL>) -> Set<URL> {
        let removals = descendents(of: urls)
        return subtracting(removals)
    }

}