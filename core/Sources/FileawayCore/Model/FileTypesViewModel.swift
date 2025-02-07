// Copyright (c) 2018-2025 Jason Morley
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
import UniformTypeIdentifiers

import Interact

public class FileTypesViewModel: ObservableObject, Runnable {

    @Published public var fileTypes: [UTType] = []
    @Published public var selection: Set<UTType.ID> = []
    @Published public var newFilenameExtension: String = ""
    @Published public var proposedFileType: UTType? = nil

    private var settings: Settings
    private var cancellables: Set<AnyCancellable> = []

    @MainActor public var canSubmit: Bool {
        return !self.newFilenameExtension.isEmpty
    }

    public init(settings: Settings) {
        self.settings = settings
    }

    @MainActor public func start() {

        settings
            .$fileTypes
            .map { types in
                return Array(types)
                    .sorted { lhs, rhs in
                        lhs.localizedDisplayName.localizedStandardCompare(rhs.localizedDisplayName) == .orderedAscending
                    }
            }
            .receive(on: DispatchQueue.main)
            .sink { types in
                self.fileTypes = types
            }
            .store(in: &cancellables)

        $newFilenameExtension
            .receive(on: DispatchQueue.main)
            .sink { newFilenameExtension in
                self.proposedFileType = UTType(filenameExtension: newFilenameExtension)
            }
            .store(in: &cancellables)
    }

    @MainActor public func stop() {
        cancellables.removeAll()
    }

    @MainActor public func submit() {
        guard let proposedFileType = proposedFileType else {
            return
        }
        self.settings.fileTypes.insert(proposedFileType)
        newFilenameExtension = ""
    }

    @MainActor public func remove(_ ids: Set<UTType.ID>) {
        self.settings.fileTypes = self.settings.fileTypes.filter { !ids.contains($0.id) }
        for id in ids {
            selection.remove(id)
        }
    }

    @MainActor public func remove(_ indexSet: IndexSet) {
        let ids = indexSet.map { index in
            return self.fileTypes[index].id
        }
        self.remove(Set(ids))
    }

}
