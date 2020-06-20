//
//  TaskList.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 19/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Combine
import Foundation

import FileActionsCore

class TaskList: ObservableObject, BackChannelable {

    @Published var tasks: [TaskState]
    var tasksBackChannel: BackChannel<TaskState>?

    init() {
        self.tasks = []
    }

    var count: Int {
        return tasks.count
    }

    init(_ tasks: [Task]) {
        self.tasks = tasks.map { TaskState(task: $0) }
    }

    func establishBackChannel() {
        tasksBackChannel = BackChannel(value: tasks, publisher: $tasks).bind {
            self.objectWillChange.send()
        }
    }

    func validate(task: TaskState) -> Bool {
        return self.tasks.filter { $0.id != task.id && $0.name == task.name }.count < 1
    }

    func validate() -> Bool {
        let names = Set(tasks.map { $0.name })
        return names.count == tasks.count
    }

    func validateChildren() -> Bool {
        return self.tasks.map { $0.validate() }.reduce(false, { $0 || $1 })
    }

    func onChange(completion: @escaping () -> Void) -> Cancellable {
        return $tasks.sink { _ in
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func replace(task: TaskState, with newTask: TaskState) {
        guard
            let index = self.tasks.firstIndex(where: { $0.id == task.id }),
            let range = Range(NSRange(location: index, length: 1))else {
                return
        }
        self.tasks.replaceSubrange(range, with: [newTask])
        assert(validate() && validateChildren())
    }

    func createTask() {
        let names = Set(tasks.map { $0.name })
        var index = 1
        var name = ""
        repeat {
            name = "Task \(index)"
            index = index + 1
        } while names.contains(name)
        let task = TaskState(id: UUID(),
                             name: name,
                             variables: [VariableState(name: "Date", type: .date(hasDay: true))],
                             destination: [
                                ComponentState(value: "Date", type: .variable, variable: nil),
                                ComponentState(value: " Description", type: .text, variable: nil)])
        self.tasks.append(task)
    }

}
