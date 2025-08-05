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
            TodoItem(title: "买菜"),
            TodoItem(title: "完成 SwiftUI 项目"),
            TodoItem(title: "阅读 30 分钟")
        ]
    }
}
