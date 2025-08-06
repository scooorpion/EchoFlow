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
                TodoItem(title: "Go for a walk", iconName: "figure.walk", timeInMinutes: 25, status: .new),
                TodoItem(title: "Read fiction", iconName: "book.closed", timeInMinutes: 15, status: .skip),
                TodoItem(title: "To inhabit the bed", iconName: "bed.double", times: 1, status: .done, isCompleted: true),
                TodoItem(
                        title: "Buy fresh vegetables",
                        iconName: "cart",
                        timeInMinutes: 30,
                        status: .new,
                        isCompleted: false
                    ),
                    TodoItem(
                        title: "Write project report",
                        iconName: "doc.text",
                        timeInMinutes: 60,
                        status: .done,
                        isCompleted: true
                    ),
                    TodoItem(
                        title: "Do laundry",
                        iconName: "washer",
                        times: 2,
                        status: .none,
                        isCompleted: false
                    ),
                    TodoItem(
                        title: "Practice guitar",
                        iconName: "guitars",
                        timeInMinutes: 45,
                        status: .skip,
                        isCompleted: false
                    ),
                    TodoItem(
                        title: "Water the plants",
                        iconName: "leaf",
                        times: 1,
                        status: .done,
                        isCompleted: true
                    ),
                    TodoItem(
                        title: "Meditate",
                        iconName: "apple.meditate",
                        timeInMinutes: 15,
                        status: .new,
                        isCompleted: false
                    ),
                    TodoItem(
                        title: "Clean bathroom",
                        iconName: "shower",
                        timeInMinutes: 25,
                        status: .skip,
                        isCompleted: false
                    ),
                    TodoItem(
                        title: "Backup phone data",
                        iconName: "externaldrive",
                        times: 1,
                        status: .done,
                        isCompleted: true
                    )
        ]
    }
}
