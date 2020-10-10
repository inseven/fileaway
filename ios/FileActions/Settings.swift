//
//  Settings.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Combine
import Foundation

import FileActionsCore

class Settings: ObservableObject {

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
                tasks = TaskList(manager.tasks)
                self.manager = manager
            } else {
                tasks = TaskList()
            }
        }
    }

    var taskObserver: Cancellable?

    @Published var tasks = TaskList() {
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
