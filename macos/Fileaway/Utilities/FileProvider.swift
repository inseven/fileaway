// Copyright (c) 2018-2021 InSeven Limited
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

import EonilFSEvents

class FileProvider {

    let locations: [URL]
    let extensions: [String]
    let handler: (Set<URL>) -> Void
    let syncQueue = DispatchQueue.init(label: "FileProvider.syncQueue")
    let targetQueue: DispatchQueue
    lazy var stream: EonilFSEventStream = {
        let stream = try! EonilFSEventStream(
            pathsToWatch: self.locations.map { $0.path },
            sinceWhen: .now,
            latency: 0,
            flags: [.fileEvents],
            handler: { event in
                let url = URL(fileURLWithPath: event.path)
                guard let flag = event.flag,
                      self.extensions.contains(url.pathExtension) else {
                    return
                }
                if flag.contains(.itemRemoved) {
                    self.files.remove(url)
                    self.targetQueue_update()
                } else if flag.contains(.itemRenamed) {
                    if FileManager.default.fileExists(atPath: event.path) {
                        self.files.insert(url)
                    } else {
                        self.files.remove(url)
                    }
                    self.targetQueue_update()
                } else if flag.contains(.itemCreated) {
                    self.files.insert(url)
                    self.targetQueue_update()
                } else {
                    print("Unhandled event \(event)")
                }
            })
        stream.setDispatchQueue(syncQueue)
        return stream
    }()

    var files: Set<URL> = []

    init(locations: [URL], extensions: [String], targetQueue: DispatchQueue, handler: @escaping (Set<URL>) -> Void) throws {
        self.locations = locations
        self.extensions = extensions
        self.targetQueue = targetQueue
        self.handler = handler
    }

    func start() {
        dispatchPrecondition(condition: .notOnQueue(syncQueue))
        syncQueue.async {
            try! self.stream.start()
            self.files = Set(FileManager.default.files(at: self.locations.first!, extensions: self.extensions))
            self.targetQueue_update()
        }
    }

    func stop() {
        dispatchPrecondition(condition: .notOnQueue(syncQueue))
        syncQueue.sync {
            self.stream.stop()
        }
    }

    func targetQueue_update() {
        dispatchPrecondition(condition: .onQueue(syncQueue))
        let files = Set(self.files)
        targetQueue.async {
            self.handler(files)
        }
    }

}
