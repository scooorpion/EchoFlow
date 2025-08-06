//
//  TodoItemCardView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/6.
//

import SwiftUI

// 自定义的单个代办事项卡片视图
struct TodoItemCardView: View {
    
    // 传入的待办事项数据
    let todoItem: TodoItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // 左侧图标区域（假设为 SF Symbols）
            Image(systemName: todoItem.iconName)
                .font(.system(size: 24))
                .foregroundColor(.primary)
            
            // 中间信息区域
            VStack(alignment: .leading, spacing: 4) {
                Text(todoItem.title)
                    .font(.headline)
                    .foregroundColor(todoItem.isCompleted ? .gray : .primary)
                    .strikethrough(todoItem.isCompleted, color: .gray)
                
                if let statusLabel = todoItem.statusLabel {
                    Text(statusLabel)
                        .font(.caption)
                        .foregroundColor(todoItem.statusColor)
                }
            }
            
            Spacer() // 推动右侧内容到最右边
            
            // 右侧时间/次数显示
            VStack {
                if let displayTime = todoItem.timeText {
                    Text(displayTime)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray5)) // 背景色
        )
        .padding(.horizontal)
    }
}
