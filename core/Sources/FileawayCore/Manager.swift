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

import Foundation

public class Manager {

    public var tasks: [Task] = []

    /**
     * Return the URL of the preferred configuration file.
     *
     * This will select the user's local configuration where available, falling back to the
     * destinations.json file in the bundle otherwise.
     */
    func configurationUrl() -> URL {
        return rootUrl.appendingPathComponent("Rules.fileaway")
    }

    public init(configurationUrl: URL) {
        do {
            print("Loading configuration at '\(configurationUrl.absoluteString)'...")
            tasks = try Manager.load(configurationUrl)
        } catch {
            print("\(error)")
        }
    }

    public var rootUrl: URL {
        return URL(fileURLWithPath: NSString(string: UserDefaults.standard.string(forKey: "root")!).expandingTildeInPath)
    }

    static func load(_ url: URL) throws -> [Task] {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let configurations = try decoder.decode([String: Configuration].self, from: data)
        let tasks = configurations.map { (name, configuration) -> Task in
            return Task(name: name, configuration: configuration)
            }.sorted { (task0, task1) -> Bool in
                return task0.name < task1.name
        }
        return tasks
           }

           public func destinationUrl(_ task: Task, variableProvider: VariableProvider, rootUrl: URL? = nil) -> URL {
               let destination = task.configuration.destination.reduce("") { (result, component) -> String in
                   switch component.type {
                   case .text:
                       return result.appending(component.value)
                   case .variable:
                       guard let value = variableProvider.variable(forKey: component.value) else {
                           return result
                       }
                       return result.appending(value)
            }
        }
        let actualRootUrl = rootUrl ?? self.rootUrl
        return actualRootUrl.appendingPathComponent(destination).appendingPathExtension("pdf")
    }

}
