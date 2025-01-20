//
//  ZapTasksApp.swift
//  ZapTasks
//
//  Created by Tim Haselaars on 09/01/2025.
//

import SwiftUI
import SwiftData

@main
struct ZapTasksApp: App {
    @StateObject private var scheduler: TaskScheduler
    private let modelContainer: ModelContainer

    init() {
        do {
            // Initialize a shared ModelContainer
            self.modelContainer = try ModelContainer(for: TaskItem.self, ExecutionRecord.self)
            let context = modelContainer.mainContext
            _scheduler = StateObject(wrappedValue: TaskScheduler(context: context))
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        MenuBarExtra {
            TaskMenuBarView()
                .onAppear {
                    print("Starting scheduler...")
                    scheduler.start()
                }
                .onDisappear {
                    print("Stopping scheduler...")
                    scheduler.stop()
                }
        } label: {
            Image("ZapTasksIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18) // Size to fit the menu bar
        }
        .modelContainer(modelContainer) // Pass the shared ModelContainer
    }
}
