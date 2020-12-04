//
//  DirectoryObserver.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 02/12/2020.
//

import SwiftUI

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

class FileInfo: Identifiable, Hashable {

    public var id: URL { url }
    let url: URL
    let name: String

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent.deletingPathExtension
    }

    static func == (lhs: FileInfo, rhs: FileInfo) -> Bool {
        return lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

}

class DirectoryObserver: ObservableObject, Identifiable {

    public var id: UUID = UUID()
    var name: String
    var locations: [URL]
    var stream: EonilFSEventStream?
    var extensions = ["pdf"]
    var count: Int { self.files.count }
    var searchResults: [FileInfo] = []

    var fileProvider: FileProvider?

    let syncQueue = DispatchQueue.init(label: "DirectoryObserver.syncQueue")

    init(name: String, locations: [URL]) {
        self.name = name
        self.locations = locations
    }

    var activeFilter = "" {
        didSet {
            self.objectWillChange.send()
            self.applyFilter()
        }
    }

    lazy var filter: Binding<String> = { Binding {
        self.activeFilter
    } set: { newValue in
        self.activeFilter = newValue
    }}()

    @Published var files: Set<URL> = Set() {
        didSet {
            applyFilter()
        }
    }

    func applyFilter() {
        dispatchPrecondition(condition: .onQueue(.main))
        let files = Array(self.files)
        let filter = String(activeFilter)
        syncQueue.async {
            let results = files
                .map { FileInfo(url: $0) }
                .filter {
                    filter.isEmpty ||
                        $0.name.localizedSearchMatches(string: filter)
                }
                .sorted { fileInfo1, fileInfo2 -> Bool in
                    fileInfo1.name.compare(fileInfo2.name) == .orderedAscending
                }

            DispatchQueue.main.async {
                self.objectWillChange.send()
                self.searchResults = results
            }
        }
    }

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))
        self.fileProvider = try! FileProvider(locations: locations,
                                              extensions: extensions,
                                              targetQueue: DispatchQueue.main,
                                              handler: { urls in
                                                self.files = urls
                                              })
        self.fileProvider?.start()
    }

}
