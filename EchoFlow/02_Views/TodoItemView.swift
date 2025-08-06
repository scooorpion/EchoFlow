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
                // LazyVStack 现在只负责内容列表
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.todoItems) { item in
                        TodoItemCardView(todoItem: item)
                    }
                }
                .padding(.horizontal)
                // 1. 【关键点】让 ScrollView 的内容可以延伸到屏幕顶部
                .padding(.top, 10) // 给列表和HeaderView之间留出一点间距
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            
            // 2. 【关键点】使用 safeAreaInset 来放置固定的、覆盖安全区的 Header
            // 这会将 HeaderView “嵌入”到安全区域的边缘，同时允许其背景延伸
            .safeAreaInset(edge: .top, spacing: 0) {
                HeaderView()
            }
        }
    }
}


#Preview {
    TodoItemView()
}
