//
//  Settings.swift
//  ZapTasks
//
//  Created by Tim Haselaars on 20/01/2025.
//

final class Settings {
    static let shared = Settings()
    private init() {}
    
    var shaasBaseURL: String = "http://localhost:7575"
}
