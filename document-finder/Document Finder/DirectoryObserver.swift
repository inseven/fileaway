//
//  DirectoryObserver.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 02/12/2020.
//

import SwiftUI

import EonilFSEvents

extension FileManager {

    func files(at url: URL, extensions: [String]) -> [URL] {
        var files: [URL] = []
        if let enumerator = enumerator(at: url,
                                       includingPropertiesForKeys: [.isRegularFileKey],
                                       options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                guard fileURL.matches(extensions: extensions) else {
                    continue
                }

                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        files.append(fileURL)
                    }
                } catch { print(error, fileURL) }
            }
        }
        return files
    }

}

class DirectoryObserver: ObservableObject, Identifiable {

    public var id: UUID = UUID()
    var name: String
    var locations: [URL]

    init(name: String, locations: [URL]) {
        self.name = name
        self.locations = locations
    }

    var stream: EonilFSEventStream?
    var extensions = ["pdf"]

    var activeFilter = "" {
        didSet {
            self.objectWillChange.send()
            self.applyFilter()
        }
    }

    var searchResults: [URL] = []

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
        searchResults = files.filter {
            activeFilter.isEmpty ||
                $0.lastPathComponent.localizedStandardContains(activeFilter)
        }
    }

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))

        stream = try? EonilFSEventStream(
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
                } else if flag.contains(.itemRenamed) {
                    if FileManager.default.fileExists(atPath: event.path) {
                        self.files.insert(url)
                    } else {
                        self.files.remove(url)
                    }
                } else if flag.contains(.itemCreated) {
                    self.files.insert(url)
                } else {
                    print("Unhandled event \(event)")
                }
            })
        stream?.setDispatchQueue(DispatchQueue.main)
        try! stream?.start()

        let files = FileManager.default.files(at: locations.first!, extensions: extensions)
        for file in files {
            self.files.insert(file)
        }

        // List the original files.
    }

}
