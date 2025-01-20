//
//  TaskExecutor.swift
//  ZapTasks
//
//  Created by Tim Haselaars on 13/01/2025.
//

import Foundation
import SwiftData

final class TaskExecutorProcess {
    private weak var context: ModelContext?

    init(context: ModelContext) {
        self.context = context
    }
    
    func execute(task: TaskItem) {
        guard let context = context else {
            print("Context is no longer valid. Cannot execute task.")
            return
        }

        print("Executing task: \(task.name)")
        
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", task.command]

        // Set the working directory if provided
        if let workingDirectory = task.workingDirectory, !workingDirectory.isEmpty {
            let directoryURL = URL(fileURLWithPath: workingDirectory)
            if FileManager.default.isReadableFile(atPath: directoryURL.path) {
                process.currentDirectoryURL = directoryURL
            } else {
                print("Warning: Working directory is not readable: \(workingDirectory)")
            }
        }

        // Inherit the PATH from the user's shell
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = getSystemPath()
        process.environment = environment
        print("Environment PATH: \(process.environment?["PATH"] ?? "No PATH set")")

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? "No output"
            print("Task \(task.name) output: \(output)")
            
            // Add execution record
            let newExecution = ExecutionRecord(
                date: Date(),
                success: process.terminationStatus == 0,
                output: output,
                task: task
            )
            context.insert(newExecution)
            try context.save()
        } catch {
            print("Failed to execute task: \(error.localizedDescription)")
        }
    }

    private func getSystemPath() -> String {
        // Fetch PATH from the user's shell
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["bash", "-c", "echo $PATH"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let shellPath = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            // Ensure default paths are included
            return "\(shellPath):/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin"
        } catch {
            print("Failed to fetch system PATH: \(error.localizedDescription)")
            return "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        }
    }
}
