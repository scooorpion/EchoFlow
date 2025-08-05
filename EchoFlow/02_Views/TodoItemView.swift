//
//  TodoItemView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import SwiftUI

// 这是主页面，用于显示所有待办事项列表
struct TodoItemView: View {
    
    @StateObject private var viewModel = TodoItemViewModel()
    
    var body: some View {
    
        NavigationStack {
            
            List(viewModel.todoItems) { item in
                NavigationLink(destination: TodoDetailView(todoItem: item)) {
                    Text(item.title)
                }
            }
            .navigationTitle("待办清单")
            .navigationBarItems(trailing: Button(action: {
                print("添加按钮被点击")
            }) {
                Image(systemName: "plus") // +
            })
        }
    }
}


#Preview {
    TodoItemView()
}
