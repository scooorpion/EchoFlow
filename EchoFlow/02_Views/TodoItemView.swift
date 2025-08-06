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
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach($viewModel.todoItems) { $item in
                        NavigationLink(destination: TodoDetailView(todoItem: $item)) {
                                TodoItemCardView(todoItem: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 3)
                .padding(.top, 10)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .safeAreaInset(edge: .top, spacing: 0) {
                HeaderView()
            }
            
        }
    }
}


#Preview {
    TodoItemView()
}
