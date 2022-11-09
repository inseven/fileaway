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

import FileawayCore

class LegacySettings: ObservableObject {

    @Published var destination: URL? {
        didSet {
            guard let url = destination else {
                return
            }
            do {
                try StorageManager.setRootUrl(url)
            } catch {
                print("Failed to set destination to \(url) with error \(error).")
            }
            if let configurationUrl = try? StorageManager.configurationUrl() {
                let manager = Manager(configurationUrl: configurationUrl)
                tasks = TasksModel(manager.tasks)
                self.manager = manager
            } else {
                tasks = TasksModel()
            }
        }
    }

    var taskObserver: Cancellable?

    @Published var tasks = TasksModel() {
        willSet {
            taskObserver?.cancel()
        }
        didSet {
            tasks.establishBackChannel()
            taskObserver = tasks.onChange {
                let tasks = self.tasks.tasks.map { Task($0) }
                let configuration = tasks.reduce(into: [:]) { result, task in
                    result[task.name] = task.configuration
                }
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    let data = try encoder.encode(configuration)
                    let configurationUrl = try StorageManager.configurationUrl()
                    try data.write(to: configurationUrl)
                    // TODO: Remove this hack to reload the manager.
                    self.manager = Manager(configurationUrl: configurationUrl)
                } catch {
                    print("Failed to store settings with error \(error)")
                }

            }
        }
    }

    var manager: Manager?

    init() {
        destination = try? StorageManager.rootUrl()
    }

    deinit {
        taskObserver?.cancel()
    }

}
