//
//  TodoItemView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import SwiftUI
import SwiftData

// 这是主页面，用于显示所有待办事项列表
struct TodoItemView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TodoItemViewModel()
    @State private var selectedDetailItem: TodoItem? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.todoItems.indices, id: \.self) { index in
                        let item = viewModel.todoItems[index]
                        // 使用NavigationLink，并添加手势识别器来处理长按
                        NavigationLink(destination: CountdownView(todoItem: Binding(
                            get: { viewModel.todoItems[index] },
                            set: { viewModel.todoItems[index] = $0; viewModel.saveContext() }
                        ))) {
                            TodoItemCardView(todoItem: Binding(
                                get: { viewModel.todoItems[index] },
                                set: { viewModel.todoItems[index] = $0; viewModel.saveContext() }
                            ), onDelete: {
                                // 删除当前项目
                                viewModel.deleteTodoItem(item)
                            })
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    // 添加轻微震动反馈
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }
                        )
                        // 使用高优先级的长按手势，确保长按时不会触发导航
                        .highPriorityGesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    // 设置选中的待办事项，这将触发sheet显示
                                    // 使用当前item的值来设置selectedDetailItem
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
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.secondarySystemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .safeAreaInset(edge: .top) {
                HeaderView(onAddTask: { newTask in
                    print("添加新任务: \(newTask.title), 时间: \(newTask.timeInMinutes)分钟")
                    viewModel.addTodoItem(newTask)
                    print("当前任务总数: \(viewModel.todoItems.count)")
                })
            }
            // 添加sheet修饰符，用于长按显示详情页
            .sheet(item: $selectedDetailItem) { item in
                // 找到对应的绑定
                if let index = viewModel.todoItems.firstIndex(where: { $0.id == item.id }) {
                    // 使用NavigationStack包装详情视图，以便显示导航栏
                    NavigationStack {
                        // 创建TodoDetailView并传入绑定
                        TodoDetailView(todoItem: Binding(
                            get: { viewModel.todoItems[index] },
                            set: { viewModel.todoItems[index] = $0; viewModel.saveContext() }
                        ))
                        .onDisappear {
                            // 当详情页关闭时，保存数据
                            viewModel.saveContext()
                        }
                    }
                }
            }
            .onChange(of: selectedDetailItem) { oldValue, newValue in
                // 当详情页关闭时的处理
                if newValue == nil {
                    // 保存数据并重新加载
                    viewModel.saveContext()
                    viewModel.loadTodoItems()
                }
            }
            .onAppear {
                // 设置ModelContext并加载数据
                viewModel.setModelContext(modelContext)
            }
            
        }
    }
}


#Preview {
    TodoItemView()
}
