//
//  TodoItem.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import Foundation
import SwiftUI

struct TodoItem: Identifiable, Equatable {
    
    //比较运算符重载
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Basic Setting
    let id = UUID()
    var title: String
    var timeInSeconds: Int = 0  // 设定的时间（秒）
    var usedTimeInSeconds: Int = 0  // 实际使用的时间（秒）
    var description: String = ""
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
    
    
    // 添加apply方法，支持链式调用设置属性
    func apply(_ closure: (inout TodoItem) -> Void) -> TodoItem {
        var copy = self
        closure(&copy)
        return copy
    }
}
