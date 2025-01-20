//
//  ExecutionRecordsView.swift
//  ZapTasks
//
//  Created by Tim Haselaars on 11/01/2025.
//

import SwiftUI
import SwiftData

struct ExecutionRecordsView: View {
    @Query private var executionRecords: [ExecutionRecord] // Fetch all execution records
    
    var body: some View {
        VStack {
            Text("Execution Records")
                .font(.headline)
            
            if executionRecords.isEmpty {
                Text("No execution records found.")
                    .foregroundColor(.gray)
            } else {
                List(executionRecords) { record in
                    VStack(alignment: .leading) {
                        Text("Date: \(record.date.formatted())")
                        Text("Success: \(record.success ? "Yes" : "No")")
                        Text("Linked Task: \(record.task?.name ?? "None")")
                            .foregroundColor(record.task == nil ? .red : .primary)
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }
}

#Preview {
    ExecutionRecordsView()
        .modelContainer(for: [TaskItem.self, ExecutionRecord.self])
}
