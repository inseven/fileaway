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

public class TasksModel: ObservableObject, BackChannelable {

    public let rootUrl: URL
    public let url: URL

    @Published public var taskModels: [RuleModel]

    var tasksBackChannel: BackChannel<RuleModel>?

    public var count: Int {
        return taskModels.count
    }

    public init(url: URL) {
        print("Load TasksModel with url \(url)")
        self.rootUrl = url
        self.url = url.rulesUrl
        if FileManager.default.fileExists(atPath: self.url.path) {
            do {
                self.taskModels = try RuleList(url: self.url).rules.map { rule in
                    return RuleModel(rootUrl: url, rule: rule)
                }
            } catch {
                // TODO: Propagate this error!
                print("Failed to load rules with error \(error).")
                self.taskModels = []
            }
        } else {
            self.taskModels = []
        }
        establishBackChannel()
    }

    public func establishBackChannel() {
        tasksBackChannel = BackChannel(value: taskModels, publisher: $taskModels).bind {
            self.objectWillChange.send()
        }
    }

    public func validate(taskModel: RuleModel) -> Bool {
        return self.taskModels.filter { $0.id != taskModel.id && $0.name == taskModel.name }.count < 1
    }

    public func validate() -> Bool {
        let names = Set(taskModels.map { $0.name })
        return names.count == taskModels.count
    }

    public func validateChildren() -> Bool {
        return self.taskModels.map { $0.validate() }.reduce(false, { $0 || $1 })
    }

    public func onChange(completion: @escaping () -> Void) -> Cancellable {
        return $taskModels.sink { _ in
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    public func update(task: RuleModel) {
        guard
            let index = self.taskModels.firstIndex(where: { $0.id == task.id }),
            let range = Range(NSRange(location: index, length: 1))else {
                return
        }
        self.taskModels.replaceSubrange(range, with: [task])
        assert(validate() && validateChildren())
    }

    public func createTask() {
        let names = Set(taskModels.map { $0.name })
        var index = 1
        var name = ""
        repeat {
            name = "Task \(index)"
            index = index + 1
        } while names.contains(name)
        let task = RuleModel(id: UUID(),
                             rootUrl: rootUrl,
                             name: name,
                             variables: [VariableModel(name: "Date", type: .date(hasDay: true))],
                             destination: [
                                ComponentModel(value: "New Folder/", type: .text, variable: nil),
                                ComponentModel(value: "Date", type: .variable, variable: nil),
                                ComponentModel(value: " Description", type: .text, variable: nil)])
        self.taskModels.append(task)
    }

}
