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

    public enum ActionType: Identifiable, Equatable {

        public var id: String {
            switch self {
            case .settings:
                return "settings"
            case .addLocation(let type):
                return "add-location-\(type.rawValue)"
            case .move(let files):
                let identifier = files
                    .map { $0.url.absoluteString }
                    .joined(separator: "-")
                return "open-\(identifier)"
            case .editRules(let url):
                return "edit-rules-\(url.absoluteURL)"
            }
        }

        case settings
        case addLocation(DirectoryModel.DirectoryType)
        case move(Set<FileInfo>)
        case editRules(URL)
    }

    @MainActor @Published public var section: URL? {
        didSet {
            applicationModel.settings.selectedFolderURL = section
        }
    }

    @Published public var inboxes: [DirectoryViewModel] = []
    @Published public var archives: [DirectoryViewModel] = []
    @Published public var directoryViewModel: DirectoryViewModel? = nil
    @Published public var action: ActionType?

    private var applicationModel: ApplicationModel
    private var cancellables: Set<AnyCancellable> = []

    @MainActor public init(applicationModel: ApplicationModel) {
        self.applicationModel = applicationModel
        self.section = applicationModel.settings.selectedFolderURL ?? applicationModel.directories.filter({ $0.type == .inbox }).first?.url
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
            .sink { (models: [DirectoryViewModel]) in

                let newInboxes = models.filter { $0.type == .inbox }
                self.inboxes = self.inboxes.applying(newInboxes) { directoryViewModel in
                    directoryViewModel.start()
                } onRemove: { directoryViewModel in
                    directoryViewModel.stop()
                }

                let newArchives = models.filter { $0.type == .archive }
                self.archives = self.archives.applying(newArchives) { directoryViewModel in
                    directoryViewModel.start()
                } onRemove: { directoryViewModel in
                    directoryViewModel.stop()
                }

            }
            .store(in: &cancellables)

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
            .store(in: &cancellables)

    }

    @MainActor public func stop() {
        cancellables.removeAll()
    }

    @MainActor public func showSettings() {
        action = .settings
    }

    @MainActor public func editRules(for locationURL: URL) {
        action = .editRules(locationURL)
    }

    @MainActor public func addLocation(type: DirectoryModel.DirectoryType) {
        action = .addLocation(type)
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
        action = .move(files)
    }

#if os(macOS)
    @MainActor public func reveal(_ files: Set<FileInfo>) {
        NSWorkspace.shared.activateFileViewerSelecting(files.map { $0.url })
    }
#endif

}
