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

    @Published public var tasks: [TaskModel]

    var tasksBackChannel: BackChannel<TaskModel>?

    public init() {
        self.tasks = []
    }

    public var count: Int {
        return tasks.count
    }

    public init(_ tasks: [Task]) {
        self.tasks = tasks.map { TaskModel(task: $0) }
    }

    public func establishBackChannel() {
        tasksBackChannel = BackChannel(value: tasks, publisher: $tasks).bind {
            self.objectWillChange.send()
        }
    }

    public func validate(task: TaskModel) -> Bool {
        return self.tasks.filter { $0.id != task.id && $0.name == task.name }.count < 1
    }

    public func validate() -> Bool {
        let names = Set(tasks.map { $0.name })
        return names.count == tasks.count
    }

    public func validateChildren() -> Bool {
        return self.tasks.map { $0.validate() }.reduce(false, { $0 || $1 })
    }

    public func onChange(completion: @escaping () -> Void) -> Cancellable {
        return $tasks.sink { _ in
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    public func update(task: TaskModel) {
        guard
            let index = self.tasks.firstIndex(where: { $0.id == task.id }),
            let range = Range(NSRange(location: index, length: 1))else {
                return
        }
        self.tasks.replaceSubrange(range, with: [task])
        assert(validate() && validateChildren())
    }

    public func createTask() {
        let names = Set(tasks.map { $0.name })
        var index = 1
        var name = ""
        repeat {
            name = "Task \(index)"
            index = index + 1
        } while names.contains(name)
        let task = TaskModel(id: UUID(),
                             name: name,
                             variables: [Variable(name: "Date", type: .date(hasDay: true))],
                             destination: [
                                ComponentModel(value: "New Folder/", type: .text, variable: nil),
                                ComponentModel(value: "Date", type: .variable, variable: nil),
                                ComponentModel(value: " Description", type: .text, variable: nil)])
        self.tasks.append(task)
    }

}
