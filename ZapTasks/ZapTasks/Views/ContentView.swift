//
//  ContentView.swift
//  ZapTasks
//
//  Created by Tim Haselaars on 09/01/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var tasks: [TaskItem]
    @Environment(\.modelContext) private var context
    @State private var selectedTask: TaskItem? = nil
    @State private var showAddEditSheet = false
    @State private var editingTask: TaskItem? = nil
    @State private var showExecutionRecords = false
    
    var body: some View {
        NavigationSplitView {
            // Sidebar: Task List
            List(tasks, selection: $selectedTask) { task in
                Text(task.name)
                    .font(.headline)
                    .tag(task)
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showExecutionRecords = true }) {
                        Label("View Execution Records", systemImage: "list.bullet")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        editingTask = nil // Reset editingTask
                        showAddEditSheet = true
                    }) {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }

        } detail: {
            // Task Details View
            if let task = selectedTask {
                let executor = TaskExecutor(context: context)
                let scheduler = TaskScheduler(context: context)
                TaskDetailsView(task: task, onEdit: {
                    editingTask = task
                    showAddEditSheet = true
                }, onDelete: { task in
                    deleteTask(task)
                }, executor: executor, scheduler: scheduler)
            } else {
                Text("Select a task to view details.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .sheet(isPresented: $showAddEditSheet) {
            AddTaskView(task: $editingTask)
        }
        .sheet(isPresented: $showExecutionRecords) {
            ExecutionRecordsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func deleteTask(_ task: TaskItem) {
        print("Deleting task: \(task.name) with \(task.executionRecords.count) execution records.")
        DispatchQueue.main.async {
            self.selectedTask = nil
        }
        context.delete(task)
        do {
            try context.save()
            print("Task and related execution records deleted successfully.")
        } catch {
            print("Failed to delete task: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TaskItem.self)
}
