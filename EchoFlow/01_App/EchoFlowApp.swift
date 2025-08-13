//
//  EchoFlowApp.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/2.
//

// 程序入口

import SwiftUI
import SwiftData

@main
struct EchoFlowApp: App {
    
    // 配置SwiftData模型容器
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TodoItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("无法创建ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            TodoItemView()
        }
        .modelContainer(sharedModelContainer)
    }
}
