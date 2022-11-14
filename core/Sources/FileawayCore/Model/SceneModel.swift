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
import SwiftUI

import Interact

public class SceneModel: ObservableObject, Runnable {

    public enum SheetType: Identifiable {

        public var id: String {
            switch self {
            case .settings:
                return "settings"
            case .addLocation(let type):
                return "add-location-\(type.rawValue)"
            case .move(let file):
                return "open-\(file.url.absoluteURL)"
            case .editRules(let url):
                return "edit-rules-\(url.absoluteURL)"
            }
        }

        case settings
        case addLocation(DirectoryModel.DirectoryType)
        case move(FileInfo)
        case editRules(URL)
    }

    @Published public var section: URL?

    @Published public var inboxes: [DirectoryViewModel] = []
    @Published public var archives: [DirectoryViewModel] = []
    @Published public var directoryViewModel: DirectoryViewModel? = nil
    @Published public var sheet: SheetType?

    private var applicationModel: ApplicationModel
    private var cancelables: Set<AnyCancellable> = []

    public init(applicationModel: ApplicationModel) {
        self.applicationModel = applicationModel
        self.section = applicationModel.directories.filter({ $0.type == .inbox }).first?.url
    }

    @MainActor public func start() {

        // Construct the directory observers.
        applicationModel
            .$directories
            .map { directories in
                return directories.map {
                    return DirectoryViewModel(directoryModel: $0)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { models in
                self.inboxes = models.filter { $0.type == .inbox }
                self.archives = models.filter { $0.type == .archive }
            }
            .store(in: &cancelables)

        // Select the correct directory when the section changes.
        $inboxes
            .combineLatest($archives, $section)
            .map { (inboxes, archives, section) in
                return (inboxes + archives).first { $0.url == section }
            }
            .receive(on: DispatchQueue.main)
            .sink { directoryViewModel in
                self.directoryViewModel = directoryViewModel
            }
            .store(in: &cancelables)

    }

    @MainActor public func stop() {
        cancelables.removeAll()
    }

    @MainActor public func showSettings() {
        sheet = .settings
    }

    @MainActor public func editRules(for locationURL: URL) {
        sheet = .editRules(locationURL)
    }

    @MainActor public func addLocation(type: DirectoryModel.DirectoryType) {
        sheet = .addLocation(type)
    }

    @MainActor public func open(_ files: Set<FileInfo>) {
#if os(macOS)
        for file in files {
            NSWorkspace.shared.open(file.url)
        }
#else
        assertionFailure("Unsupported")
#endif
    }

    @MainActor public func move(_ files: Set<FileInfo>) {
#if os(macOS)
        assertionFailure("Unsupported")
#else
        guard let file = files.first else {
            return
        }
        sheet = .move(file)
#endif
    }

#if os(macOS)
    @MainActor public func reveal(_ files: Set<FileInfo>) {
        for file in files {
            NSWorkspace.shared.activateFileViewerSelecting([file.url])
        }
    }
#endif

}
