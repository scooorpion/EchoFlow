//
//  TodoListViewModel.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import Foundation

// 这是待办事项列表的 ViewModel，负责提供和管理待办事项的数据
class TodoItemViewModel: ObservableObject {
    
    // 当这个属性发生变化时，自动通知使用它的视图（View）进行刷新
    @Published var todoItems: [TodoItem] = []
    
    // 构造方法，用来初始化一些测试数据
    init() {
        
        todoItems = [
            TodoItem(
                title: "Go for a walk",
                timeInSeconds: 1200 * 60,  // 1200分钟转换为秒
                description: "Walk 1km day by day.Walk 1km day by dayWalk 1km day by dayWalk 1km day by dayWalk 1km day by dayWalk 1km day by dayWalk 1km day by dayWalk 1km day by dayWalk 1km day by day"
            ).apply { $0.usedTimeInSeconds = 30 * 60 },  // 示例：已使用30分钟转换为秒
            TodoItem(
                title: "Read fiction",
                timeInSeconds: 1200 * 60   // 1200分钟转换为秒
            ).apply { $0.usedTimeInSeconds = 0 }  // 示例：尚未使用时间
        ]
        
        
    }
}
