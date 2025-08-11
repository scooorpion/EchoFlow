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
    // 3. 没有这个协议，系统无法判 你现在做的这个东西有一些问题。首先这个。你能做到这个长按。长按这个修改。但是长按修改之后的这个内容,它好像没有修改到这个逻辑中。也就是你没有同步。我长按修改,然后点击。点击了完成以后。 或者我修改。修改点击的这个完成以后,我没有更新到这个ToDoItem里面。没有更新到我这个逻辑的这个框架里面。但是你确实是更新到了我的这个即时的这个ToDoDetailVal的这个界面中。然后,比如说我现在改成了。 改成了6分钟。 然后,我这个卡片中的分钟和标题都没有更改。 然后,这个倒计时用这个圆环来表示这个倒计时的时间没有问题。 然后正计时就不需要圆环。正计时只需要保留中间的这个时间就可以了。断哪个TodoItem被选中用于显示详情页
    // 4. 我们通过比较两个TodoItem的id来判断它们是否是同一个待办事项
    
    // 实现Equatable协议的==操作符
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        // 如果两个TodoItem的id相同，则认为它们是同一个待办事项
        return lhs.id == rhs.id
    }
    
    // MARK: - Basic Setting
    let id = UUID()
    var title: String
    var timeInMinutes: Int  // 设定的时间（分钟）
    var usedTimeInMinutes: Int = 0  // 实际使用的时间（分钟）
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

    // 添加apply方法，支持链式调用设置属性
    func apply(_ closure: (inout TodoItem) -> Void) -> TodoItem {
        var copy = self
        closure(&copy)
        return copy
    }
}
