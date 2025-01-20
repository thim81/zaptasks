//
//  TaskDetailsView.swift
//  ZapTasks
//
//  Created by Tim Haselaars on 11/01/2025.
//

import SwiftUI
import SwiftData

struct TaskDetailsView: View {
    @Bindable var task: TaskItem
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false
    @State private var selectedExecution: ExecutionRecord?
    private let executor: TaskExecutor
    private let scheduler: TaskScheduler
    
    init(task: TaskItem,
         onEdit: @escaping () -> Void,
         onDelete: @escaping (TaskItem) -> Void,
         executor: TaskExecutor,
         scheduler: TaskScheduler) {
        self._task = Bindable(task)
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.executor = executor
        self.scheduler = scheduler
    }
    
    var onEdit: () -> Void
    var onDelete: (TaskItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Details")
                .font(.largeTitle)
                .bold()
            
            Group {
                Text("Name: \(task.name)")
                Text("Working Directory: \(task.workingDirectory ?? "-")")
                Text("Command: \(task.command)")
                Text("Schedule: \(task.scheduleDisplay)")
                // Text("Interval: \(task.interval)")
                
                // Last Ran
                if let lastExecution = task.executionRecords.max(by: { $0.date < $1.date }) {
                    Text("Last Ran: \(lastExecution.date.formatted()) (\(lastExecution.success ? "Success" : "Failure"))")
                } else {
                    Text("Last Ran: Never")
                }
                
                // Next Run
                if let nextRunDate = scheduler.calculateNextRun(for: task) {
                    Text("Next Run: \(nextRunDate.formatted())")
                } else {
                    Text("Next Run: Could not determine")
                }
            }
            .font(.body)
            
            Divider()
                .padding(.vertical, 8)
            
            Text("Execution History")
                .font(.headline)
            
            if task.executionRecords.isEmpty {
                Text("No previous executions")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                List(task.executionRecords.sorted(by: { $0.date > $1.date })) { execution in
                    HStack {
                        Image(systemName: execution.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(execution.success ? .green : .red)
                        Text(execution.date.formatted())
                            .font(.body)
                        Spacer()
                        Button("Show Output") {
                            selectedExecution = execution // Pass ExecutionRecord
                        }
                        .buttonStyle(.bordered)
                        Button(role: .destructive) {
                            deleteExecutionRecord(execution)
                        } label: {
                            Text("Delete")
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: 200)
            }
            
            Spacer()
            
            // Actions
            HStack {
                Button("Run Now") {
                    executor.execute(task: task)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Edit Task", action: onEdit)
                    .buttonStyle(.bordered)
                
                Button("Delete Task") {
                    showDeleteConfirmation = true
                }
                .foregroundColor(.red)
                .alert("Delete Task", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        onDelete(task)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to delete this task? This action cannot be undone.")
                }
            }
        }
        .padding()
        .onDisappear {
            print("TaskDetailsView disappeared.")
        }
        .sheet(item: $selectedExecution) { execution in
            VStack(alignment: .leading, spacing: 16) {
                Text("Execution Output")
                    .font(.title2)
                    .bold()
                
                HStack {
                    Text("Status:")
                        .bold()
                    Text(execution.success ? "Success" : "Failure")
                        .foregroundColor(execution.success ? .green : .red)
                    Spacer()
                }
                
                HStack {
                    Text("Date:")
                        .bold()
                    Text(execution.date.formatted())
                    Spacer()
                }
                
                Divider()
                
                Text("Output:")
                    .font(.headline)
                
                // Console-like Text Area
                ScrollView {
                    Text(execution.output)
                        .font(.system(.body, design: .monospaced)) // Use monospaced font
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.white)
                        .background(Color(.black))
                        .textSelection(.enabled)
                        .padding(.vertical, 4)
                }
                
                Button("Close") {
                    selectedExecution = nil
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(minWidth: 800, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
        }
    }
    
    private func deleteExecutionRecord(_ record: ExecutionRecord) {
        context.delete(record)
        do {
            try context.save()
        } catch {
            print("Failed to delete execution record: \(error)")
        }
    }
}

/*#Preview {
    let modelContainer = try! ModelContainer(for: TaskItem.self, ExecutionRecord.self)
    
    let context = modelContainer.mainContext
    let task = TaskItem(
        name: "Backup Files",
        command: "rsync -a ~/Documents /Volumes/BackupDrive",
        interval: "daily",
        schedule: "Daily at 10:00 AM",
        workingDirectory: "~/Documents",
        lastRan: Date()
    )
    let execution1 = ExecutionRecord(date: Date().addingTimeInterval(-3600), success: true, output: "Backup completed successfully.", task: task)
    let execution2 = ExecutionRecord(date: Date().addingTimeInterval(-7200), success: false, output: "Error: Disk not found.", task: task)
    
    context.insert(task)
    context.insert(execution1)
    context.insert(execution2)
    
    let executor = TaskExecutor(context: context)

    return TaskDetailsView(
        task: task,
        onEdit: {},
        onDelete: { _ in },
        executor: executor
    )
    .modelContainer(modelContainer)
}*/
