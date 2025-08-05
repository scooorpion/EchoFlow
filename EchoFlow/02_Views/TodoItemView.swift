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
                LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                    
                    // Section Header 是固定在顶部的
                    Section(header: HeaderView()) {
                        ForEach(viewModel.todoItems) { item in
                            TodoItemCardView(todoItem: item)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true) // 隐藏默认导航栏
        }
    }
}


#Preview {
    TodoItemView()
}
