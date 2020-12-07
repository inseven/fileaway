//
//  DirectoryObserver.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 02/12/2020.
//

import SwiftUI


class DirectoryObserver: ObservableObject, Identifiable {

    public var id: UUID = UUID()
    var name: String
    var locations: [URL]
    var extensions = ["pdf"]
    var count: Int { self.files.count }
    @Published var searchResults: [FileInfo] = []

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
                    let dateComparison = fileInfo1.sortDate.compare(fileInfo2.sortDate)
                    if dateComparison != .orderedSame {
                        return dateComparison == .orderedDescending
                    }
                    return fileInfo1.name.compare(fileInfo2.name) == .orderedAscending
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
