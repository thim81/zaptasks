//
//  ContentViewTests.swift
//  ZapTasksTests
//

import Foundation
import Testing
@testable import ZapTasks

struct ContentViewTests {

    @MainActor
    @Test func reconciliationKeepsASelectionThatStillExists() {
        let selectedTask = makeTask(id: UUID(), name: "Selected")
        let otherTask = makeTask(id: UUID(), name: "Other")

        let result = ContentView.reconciledSelection(
            current: selectedTask.id,
            tasks: [otherTask, selectedTask]
        )

        #expect(result == selectedTask.id)
    }

    @MainActor
    @Test func reconciliationSelectsFirstSortedTaskWhenSelectionDisappears() {
        let alphaTask = makeTask(id: UUID(), name: "alpha")
        let zebraTask = makeTask(id: UUID(), name: "Zebra")

        let result = ContentView.reconciledSelection(
            current: UUID(),
            tasks: [zebraTask, alphaTask]
        )

        #expect(result == alphaTask.id)
    }

    @MainActor
    @Test func reconciliationClearsSelectionForAnEmptyList() {
        let result = ContentView.reconciledSelection(current: UUID(), tasks: [])

        #expect(result == nil)
    }

    private func makeTask(id: UUID, name: String) -> TaskItem {
        TaskItem(
            id: id,
            name: name,
            command: "echo test",
            interval: TaskInterval.daily.rawValue,
            schedule: "{}",
            scheduleDisplay: "test"
        )
    }
}
