//
//  TodoItem.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class TodoItem: Identifiable, Equatable {
    
    //比较运算符重载
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Basic Setting
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var timeInSeconds: Int = 0  // 设定的时间（秒）
    var usedTimeInSeconds: Int = 0  // 实际使用的时间（秒）
    var taskDescription: String = ""
    var notes: String = ""
    
    // MARK: - Computed Properties for Display
    
    // 设定时间的分钟数（四舍五入显示）
    var timeInMinutes: Int {
        get {
            return Int(round(Double(timeInSeconds) / 60.0))
        }
        set {
            timeInSeconds = newValue * 60
        }
    }
    
    // 已用时间的分钟数（四舍五入显示）
    var usedTimeInMinutes: Int {
        get {
            return Int(round(Double(usedTimeInSeconds) / 60.0))
        }
        set {
            usedTimeInSeconds = newValue * 60
        }
    }
    
    // MARK: - Date Set
    var isAllDay: Bool = false
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    
    
    // MARK: - 拓展属性
    var AutoFill: String = ""
    var isCompleted: Bool = false
    
    
    // MARK: - Initializer
    init(title: String, timeInSeconds: Int = 0, usedTimeInSeconds: Int = 0, description: String = "", notes: String = "") {
        self.title = title
        self.timeInSeconds = timeInSeconds
        self.usedTimeInSeconds = usedTimeInSeconds
        self.taskDescription = description
        self.notes = notes
    }
}

// MARK: - Sample Data
extension TodoItem {
    static let sampleActive = TodoItem(
        title: "示例任务",
        timeInSeconds: 1800, // 30分钟
        usedTimeInSeconds: 600, // 已用10分钟
        description: "这是一个示例任务的描述",
        notes: "这是一些备注信息"
    )
}
