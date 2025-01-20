//
//  SidebarView.swift
//  ZapTasks
//
//  Created by Tim Haselaars on 13/01/2025.
//

import SwiftUI

struct SidebarView: View {
    
    @Binding var tasks: [TaskItem]
    @Binding var selectedTask: TaskItem?
    @State private var showAddTaskSheet = false
    
    var body: some View {
        List(selection: $selectedTask) {
            Section("Task List") {
                ForEach(tasks) { task in
                    Text(task.name)
                        .font(.headline)
                        .tag(task)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                showAddTaskSheet.toggle()
            }) {
                Label("Add Task", systemImage: "plus.circle")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .listStyle(.sidebar)
//        .sheet(isPresented: $showAddTaskSheet) {
//            AddTaskView { newTask in
//                tasks.append(newTask)
//            }
//        }
    }
}
