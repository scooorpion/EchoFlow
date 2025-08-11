//
//  TodoItem.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import Foundation
import SwiftUI

struct TodoItem: Identifiable, Equatable {
    
    // Equatable协议解释：
    // 1. Equatable协议允许两个TodoItem对象进行比较（是否相等）
    // 2. 这对于在sheet中使用TodoItem作为item参数是必需的
    // 3. 没有这个协议，系统无法判断哪个TodoItem被选中用于显示详情页
    // 4. 我们通过比较两个TodoItem的id来判断它们是否是同一个待办事项
    
    // 实现Equatable协议的==操作符
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        // 如果两个TodoItem的id相同，则认为它们是同一个待办事项
        return lhs.id == rhs.id
    }
    
    // MARK: - Basic Setting
    let id = UUID()
    var title: String
    var timeInMinutes: Int
    var description: String = ""
    var notes: String = ""
    
    // MARK: - Date Set
    var isAllDay: Bool = false
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    
    
    // MARK: - 拓展属性
    var AutoFill: String = ""
    var isCompleted: Bool = false
    
//    var timeText: String? {
//        if let minutes = timeInMinutes {
//            return "\(minutes) min"
//        }
//        return nil
//    }

}
