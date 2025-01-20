//
//  ExecutionRecord.swift
//  ZapTasks
//
//  Created by Tim Haselaars on 11/01/2025.
//

import Foundation
import SwiftData

@Model
final class ExecutionRecord: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var success: Bool
    var output: String
    @Relationship(deleteRule: .nullify, inverse: \TaskItem.executionRecords) var task: TaskItem?
    
    init(
        id: UUID = UUID(),
        date: Date,
        success: Bool,
        output: String,
        task: TaskItem? = nil
    ) {
        self.id = id
        self.date = date
        self.success = success
        self.output = output
        self.task = task
    }
}
