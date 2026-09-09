//
//  TaskExecutorTests.swift
//  ZapTasksTests
//

import Foundation
import SwiftData
import Testing
@testable import ZapTasks

struct TaskExecutorTests {

    @MainActor
    @Test func successfulRequestRecordsExecutionOnOwningActor() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: TaskItem.self,
            ExecutionRecord.self,
            configurations: configuration
        )
        let context = container.mainContext
        let task = TaskItem(
            name: "test task",
            command: "echo test",
            interval: TaskInterval.daily.rawValue,
            schedule: "{}",
            scheduleDisplay: "test"
        )
        context.insert(task)
        try context.save()

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [SuccessfulURLProtocol.self]
        let session = URLSession(configuration: sessionConfiguration)
        let executor = TaskExecutor(context: context, session: session)

        await executor.execute(task: task)

        #expect(task.lastRan != nil)
        #expect(task.executionRecords.count == 1)
        #expect(task.executionRecords.first?.success == true)
        #expect(task.executionRecords.first?.output == "completed")
    }
}

private final class SuccessfulURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("completed".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
