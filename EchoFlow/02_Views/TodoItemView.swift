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
    @State private var selectedDetailItem: TodoItem? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach($viewModel.todoItems) { $item in
                        // 使用NavigationLink，并添加手势识别器来处理长按
                        NavigationLink(destination: CountdownView(todoItem: $item)) {
                            TodoItemCardView(todoItem: item)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        // 使用高优先级的长按手势，确保长按时不会触发导航
                        .highPriorityGesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    // 设置选中的待办事项，这将触发sheet显示
                                    selectedDetailItem = item
                                    
                                    // 创建触觉反馈
                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                    // 触发反馈
                                    impactMed.impactOccurred()
                                    
                                    // 打印日志，用于调试
                                    print("长按手势触发，显示详情页：\(item.title)")
                                }
                        )
                    }
                }
                .padding(.horizontal, 3)
                .padding(.top, 10)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .safeAreaInset(edge: .top, spacing: 0) {
                HeaderView()
            }
            // 添加sheet修饰符，用于长按显示详情页
            // sheet(item:)修饰符的工作原理：
            // 1. 当$selectedDetailItem的值不为nil时，会自动显示sheet
            // 2. 当$selectedDetailItem的值变为nil时，sheet会自动关闭
            // 3. item参数会接收selectedDetailItem的值（非nil时）
            .sheet(item: $selectedDetailItem) { item in
                // 找到对应的绑定
                // 注意：这里不能直接使用传入的item，因为它不是@Binding
                // 我们需要在viewModel.todoItems数组中找到对应的项，并创建绑定
                if let index = viewModel.todoItems.firstIndex(where: { $0.id == item.id }) {
                    // 使用NavigationStack包装详情视图，以便显示导航栏
                    NavigationStack {
                        // 创建TodoDetailView并传入绑定
                        // 使用$viewModel.todoItems[index]创建绑定，确保修改会反映到模型中
                        TodoDetailView(todoItem: $viewModel.todoItems[index])
                    }
                }
            }
            
        }
    }
}


#Preview {
    TodoItemView()
}
