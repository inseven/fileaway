//
//  FileProvider.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 04/12/2020.
//

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

    func targetQueue_update() {
        dispatchPrecondition(condition: .onQueue(syncQueue))
        let files = Set(self.files)
        targetQueue.async {
            self.handler(files)
        }
    }

}
