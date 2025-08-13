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
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(
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
