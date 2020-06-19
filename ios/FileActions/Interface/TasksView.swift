//
//  TasksView.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 18/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation
import SwiftUI


class TaskList: ObservableObject, BackChannelable {

    @Published var tasks: [TaskState]
    var tasksBackChannel: BackChannel<TaskState>?

    init(tasks: [TaskState]) {
        self.tasks = tasks
    }

    func establishBackChannel() {
        tasksBackChannel = BackChannel(value: tasks, publisher: $tasks).bind {
            self.objectWillChange.send()
        }
    }

}


struct TasksView: View {

    @ObservedObject var tasks: TaskList

    init(tasks: [TaskState]) {
        self.tasks = TaskList(tasks: tasks)
        self.tasks.establishBackChannel()
    }

    var body: some View {
        VStack {
            List {
                Section() {
                    ForEach(tasks.tasks) { task in
                        NavigationLink(destination: TaskView(task: task)) {
                            Text(task.name)
                        }
                    }
                    .onDelete { self.tasks.tasks.remove(atOffsets: $0) }
                }
            }
            .listStyle(DefaultListStyle())
        }.navigationBarItems(trailing: Button(action: {
            print("Add")
        }) {
            Text("Add")
        })
        .navigationBarTitle("Tasks")
    }

}
