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
                    
                    // 【关键修改】: 遍历索引，以便创建绑定
                    ForEach($viewModel.todoItems) { $item in
                        // 【关键修改】: 使用 NavigationLink 包裹卡片
                        NavigationLink(destination: TodoDetailView(todoItem: $item)) {
                            // 你的卡片视图保持不变
                            TodoItemCardView(todoItem: item)
                        }
                        // 让 NavigationLink 的样式变平，去掉默认的箭头和蓝色字体
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 3)
                .padding(.top, 10)
            }
            .background(Color(UIColor.systemGroupedBackground))
            // 注意：因为我们现在需要用 NavigationStack 的标题，
            // 所以我们不再完全隐藏它，而是自定义它的外观。
            // .navigationBarHidden(true)  <-- 我们不再需要这行
            
            .safeAreaInset(edge: .top, spacing: 0) {
                // HeaderView 依然作为安全区的嵌入视图，保持固定
                HeaderView()
            }
        }
    }
}


#Preview {
    TodoItemView()
}
