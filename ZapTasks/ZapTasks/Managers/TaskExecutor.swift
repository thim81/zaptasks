//
//  TaskExecutor.swift
//  ZapTasks
//
//  Created by Tim Haselaars on 13/01/2025.
//

import Foundation
import SwiftData

@MainActor
final class TaskExecutor {
    private weak var context: ModelContext?
    private let shaasBaseURL = Settings.shared.shaasBaseURL
    private let session: URLSession
    
    init(context: ModelContext, session: URLSession = .shared) {
        self.context = context
        self.session = session
        NotificationHelper.requestAuthorization()
    }
    
    func execute(task: TaskItem) async {
        guard context != nil else {
            print("Context is no longer valid. Cannot execute task.")
            return
        }
        
        print("Executing task via SHAAS: \(task.name)")
        
        // Construct the URL by appending the working directory to the base URL if it exists
        var urlPath = shaasBaseURL
        if let workingDirectory = task.workingDirectory,
           !workingDirectory.isEmpty {
            urlPath += workingDirectory.hasPrefix("/") ? workingDirectory : "/\(workingDirectory)"
        }
        
        // Ensure the URL is valid
        guard let url = URL(string: urlPath) else {
            print("Invalid SHAAS URL path: \(urlPath)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        // Add the command as the request body
        request.httpBody = task.command.data(using: .utf8)
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Failed to get a valid response from SHAAS")
                handleTaskCompletion(task: task, success: false, output: "Error: Invalid response from SHAAS")
                return
            }

            let output = String(data: data, encoding: .utf8) ?? "Unknown output"
            if httpResponse.statusCode == 200 {
                print("Task \(task.name) output: \(output)")
                handleTaskCompletion(task: task, success: true, output: output)
            } else {
                print("SHAAS returned an error: \(httpResponse.statusCode) - \(output)")
                handleTaskCompletion(task: task, success: false, output: output)
            }
        } catch {
            print("Failed to execute task via SHAAS: \(error.localizedDescription)")
            handleTaskCompletion(task: task, success: false, output: "Error: \(error.localizedDescription)")
        }
    }
    
    private func handleTaskCompletion(task: TaskItem, success: Bool, output: String) {
        recordExecution(task: task, success: success, output: output)
        if shouldNotify(task: task, success: success) {
            NotificationHelper.showNotification(
                title: "\(task.name) \(success ? "Completed" : "Failed")",
                body: output.prefix(100) + (output.count > 100 ? "..." : "")
            )
        }
    }
    
    private func shouldNotify(task: TaskItem, success: Bool) -> Bool {
        switch task.notificationPreference {
        case .failuresOnly:
            return !success
        case .successesOnly:
            return success
        case .both:
            return true
        }
    }
    
    private func recordExecution(task: TaskItem, success: Bool, output: String) {
        guard let context = context else { return }
        let newExecution = ExecutionRecord(
            date: Date(),
            success: success,
            output: output,
            task: task
        )
        do {
            context.insert(newExecution)
            task.lastRan = Date()
            try context.save()
        } catch {
            print("Failed to save execution record: \(error.localizedDescription)")
        }
    }
}
