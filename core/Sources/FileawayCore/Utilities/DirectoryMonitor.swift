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

import Combine
import Foundation

#if os(macOS)
import EonilFSEvents
#else
import UIKit
#endif

public class DirectoryMonitor: ObservableObject {

    let locations: [URL]
    let syncQueue = DispatchQueue(label: "DirectoryMonitor.syncQueue")

    var cancellables: Set<AnyCancellable> = []

    @MainActor @Published var files: Set<URL>? = nil

#if os(macOS)

    lazy var stream: EonilFSEventStream = {
        // TODO: DirectoryMonitor instances leak if not explicitly stopped #518
        //       https://github.com/inseven/fileaway/issues/518
        let stream = try! EonilFSEventStream(pathsToWatch: self.locations.map { $0.path },
                                             sinceWhen: .now,
                                             latency: 0.3,
                                             flags: [.fileEvents],
                                             handler: { event in
            guard let flag = event.flag else {
                return
            }

            // Determine the operation.
            let isCreate: Bool
            if flag.contains(.itemCreated) || flag.contains(.itemRemoved) || flag.contains(.itemRenamed) {
                // While it might seem counter-intuitive, we explicitly check the file system to determine the type of
                // operation. This allows us to effectively ignore transient creation operations as they'll always
                // become removal operations that are then ignored as the files in question aren't in the active set.
                isCreate = FileManager.default.fileExists(atPath: event.path)
            } else if flag.contains(.historyDone) {
                // Silently ignore known flags.
                return
            } else {
                // Ignore all other operations.
                print("Unhandled file event \(event).")
                return
            }

            // Check to see if the event path is a directory and, if so, deal with the directory contents.
            var isDirectory: ObjCBool = false
            _ = FileManager.default.fileExists(atPath: event.path, isDirectory: &isDirectory)
            let urls: Set<URL>
            if isDirectory.boolValue && isCreate {
                urls = Set(FileManager.default.files(at: URL(fileURLWithPath: event.path)))
            } else {
                urls = [URL(fileURLWithPath: event.path)]
            }

            print("State: isCreate = \(isCreate), urls=\(urls)")

            DispatchQueue.main.sync {
                precondition(self.files != nil)
                guard let files = self.files else {
                    return
                }
                if isCreate {
                    if files.intersection(urls).count != urls.count {
                        self.files = files.union(urls)
                    }
                } else {
                    let removals = files.urlAndDescendents(of: urls)
                    if !files.intersection(removals).isEmpty {
                        print("State: -> removing urls")
                        self.files = files.subtracting(removals)
                        print("State: self.files = \(self.files ?? [])")
                    }
                }
            }
        })
        stream.setDispatchQueue(syncQueue)
        return stream
    }()

#endif

    public init(locations: [URL]) {
        self.locations = locations
    }

    @MainActor public func start() {

#if os(iOS)
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { foreground in
                self.refresh()
            }
            .store(in: &cancellables)
#endif

        syncQueue.async {
#if os(macOS)
            try! self.stream.start()
#endif
            self.syncQueue_refresh()
        }


    }

    @MainActor public func stop() {
        dispatchPrecondition(condition: .notOnQueue(syncQueue))
#if os(macOS)
        syncQueue.sync {
            self.stream.stop()
        }
#endif
        cancellables.removeAll()
    }

    @MainActor public func refresh() {
        syncQueue.async {
            self.syncQueue_refresh()
        }
    }

    @MainActor public func add(_ url: URL) {
        self.files?.insert(url)
    }

    @MainActor public func remove(_ url: URL) {
        self.files?.remove(url)
    }

    private func syncQueue_refresh() {
        dispatchPrecondition(condition: .onQueue(syncQueue))
        let files = Set(FileManager.default.files(at: self.locations.first!))
        DispatchQueue.main.sync {
            // Ensure we don't trigger an unnecessary redraw if the files haven't changed.
            guard self.files != files else {
                return
            }
            self.files = files
        }
    }

}
