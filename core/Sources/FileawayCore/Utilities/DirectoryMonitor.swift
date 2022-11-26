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
        let stream = try! EonilFSEventStream(
            pathsToWatch: self.locations.map { $0.path },
            sinceWhen: .now,
            latency: 0,
            flags: [.fileEvents],
            handler: { event in
                let url = URL(fileURLWithPath: event.path)
                guard let flag = event.flag else {
                    return
                }
                Task { @MainActor in
                    precondition(self.files != nil)
                    if flag.contains(.itemRemoved) {
                        self.files?.remove(url)
                    } else if flag.contains(.itemRenamed) {
                        if FileManager.default.fileExists(atPath: event.path) {
                            self.files?.insert(url)
                        } else {
                            self.files?.remove(url)
                        }
                    } else if flag.contains(.itemCreated) {
                        self.files?.insert(url)
                    } else {
                        print("Unhandled event \(event)")
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

    public func start() {
        dispatchPrecondition(condition: .notOnQueue(syncQueue))

#if os(iOS)
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { foreground in
                print("Refreshing monitor for \(self.locations).")
                self.refresh()
            }
            .store(in: &cancellables)
#endif

        syncQueue.async {
#if os(macOS)
            try! self.stream.start()
#endif
            let files = Set(FileManager.default.files(at: self.locations.first!))
            Task { @MainActor in
                self.files = files
            }
        }
    }

    public func stop() {
        dispatchPrecondition(condition: .notOnQueue(syncQueue))
#if os(macOS)
        syncQueue.sync {
            self.stream.stop()
        }
#endif
        cancellables.removeAll()
    }

    public func refresh() {
        dispatchPrecondition(condition: .notOnQueue(syncQueue))
        syncQueue.async {
            let files = Set(FileManager.default.files(at: self.locations.first!))
            Task { @MainActor in
                self.files = files
            }
        }
    }

    @MainActor public func add(_ url: URL) {
        self.files?.insert(url)
    }

    @MainActor public func remove(_ url: URL) {
        self.files?.remove(url)
    }

}
