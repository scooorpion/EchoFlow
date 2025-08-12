//
//  HeaderView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/6.
//

import SwiftUI

struct HeaderView: View {
    @State private var showingNewTaskView = false
    
    var onAddTask: ((TodoItem) -> Void)? = nil
    
    var body: some View {
        HStack {
            Text("待办事项")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                showingNewTaskView = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("添加新待办事项")
        }
        // 1. 【关键点】为内容添加水平和底部边距，以确保它们在视觉上舒适
        // 注意：我们不需要加 .padding(.top)，因为 safeAreaInset 会自动处理
        .padding(.horizontal)
        .padding(.bottom, 10)
        
        // 2. 【关键点】添加背景。这里我们不直接用VStack包裹，而是使用 .background 修饰符
        // .frame(maxWidth: .infinity) 确保背景能横向撑满
        // .background(.ultraThinMaterial) 是实现苹果原生模糊效果的关键
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .overlay(
            // 底部分割线
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(height: 0.5),
            alignment: .bottom
        )
        .sheet(isPresented: $showingNewTaskView) {
            AddNewTaskView { newTask in
                print("接收到新任务: \(newTask.title), 时间: \(newTask.timeInMinutes)分钟")
                onAddTask?(newTask)
                print("新任务已添加到列表")
            }
        }
    }
}


#Preview {
    HeaderView()
}
