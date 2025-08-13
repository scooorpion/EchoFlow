//
//  TodoListViewModel.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import Foundation
import SwiftData

// 这是待办事项列表的 ViewModel，负责提供和管理待办事项的数据
@Observable
class TodoItemViewModel {
    
    var modelContext: ModelContext?
    var todoItems: [TodoItem] = []
    
    // 构造方法
    init() {
        // 初始化时不添加测试数据，等待modelContext设置后再加载
    }
    
    // 设置ModelContext并加载数据
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadTodoItems()
        
        // 如果没有数据，添加一些示例数据
        if todoItems.isEmpty {
            addSampleData()
        }
    }
    
    // 加载所有待办事项
    func loadTodoItems() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<TodoItem>(sortBy: [SortDescriptor(\TodoItem.startDate)])
            todoItems = try context.fetch(descriptor)
        } catch {
            print("加载待办事项失败: \(error)")
        }
    }
    
    // 添加新的待办事项
    func addTodoItem(_ item: TodoItem) {
        guard let context = modelContext else { return }
        
        context.insert(item)
        saveContext()
        loadTodoItems()
    }
    
    // 删除待办事项
    func deleteTodoItem(_ item: TodoItem) {
        guard let context = modelContext else { return }
        
        context.delete(item)
        saveContext()
        loadTodoItems()
    }
    
    // 保存上下文
    func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("保存数据失败: \(error)")
        }
    }
    
    // 添加示例数据
    private func addSampleData() {
        let sampleItem1 = TodoItem(
            title: "Go for a walk",
            timeInSeconds: 1200 * 60,  // 1200分钟转换为秒
            description: "Walk 1km day by day.Walk 1km day by dayWalk 1km day by dayWalk 1km day by dayWalk 1km day by dayWalk 1km day by dayWalk 1km day by dayWalk 1km day by dayWalk 1km day by day"
        )
        sampleItem1.usedTimeInSeconds = 30 * 60  // 示例：已使用30分钟转换为秒
        
        let sampleItem2 = TodoItem(
            title: "Read fiction",
            timeInSeconds: 1200 * 60   // 1200分钟转换为秒
        )
        sampleItem2.usedTimeInSeconds = 0  // 示例：尚未使用时间
        
        addTodoItem(sampleItem1)
        addTodoItem(sampleItem2)
    }
}
