//
//  TasksView.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 18/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation
import SwiftUI

struct TasksView: View {

    @ObservedObject var tasks: TaskList

    var body: some View {
        VStack {
            List {
                Section() {
                    ForEach(tasks.tasks) { task in
                        NavigationLink(destination: TaskView(tasks: self.tasks, editingTask: TaskState(task), originalTask: task)) {
                            Text(task.name)
                        }
                    }
                    .onDelete { self.tasks.tasks.remove(atOffsets: $0) }
                }
            }
            .listStyle(DefaultListStyle())
        }.navigationBarItems(trailing: Button(action: {
            self.tasks.createTask()
        }) {
            Text("Add")
        })
        .navigationBarTitle("Tasks")
    }

}
