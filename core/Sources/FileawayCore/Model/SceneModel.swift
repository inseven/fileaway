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

public class SceneModel: ObservableObject {

    @Published public var section: URL?

    // TODO: Not sure if these actually need to be public?
    @Published public var inboxes: [DirectoryViewModel] = []
    @Published public var archives: [DirectoryViewModel] = []
    @Published public var directory: DirectoryViewModel? = nil

    private var applicationModel: ApplicationModel
    private var cancelables: Set<AnyCancellable> = []

    public init(applicationModel: ApplicationModel) {
        self.applicationModel = applicationModel
    }

    // TODO: Sort by name?
    @MainActor public func start() {

        // Construct the directory observers.
        applicationModel
            .$directories
            .map { directories in
                return directories.map {
                    let model = DirectoryViewModel(directoryModel: $0)
                    model.start()
                    return model
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { models in
                // TODO: Diff the new models and stop the old ones.
                self.inboxes = models.filter { $0.type == .inbox }
                self.archives = models.filter { $0.type == .archive }
            }
            .store(in: &cancelables)

        $inboxes
            .combineLatest($archives, $section)
            .map { (inboxes, archives, section) in
                return (inboxes + archives).first { $0.url == section }
            }
            .receive(on: DispatchQueue.main)
            .sink { directory in
                self.directory = directory
            }
            .store(in: &cancelables)

    }

    @MainActor public func stop() {
        cancelables.removeAll()
    }

}
