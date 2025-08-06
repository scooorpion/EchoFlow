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
            
            Image(systemName: todoItem.iconName)
                .font(.system(size: 24))
                .foregroundColor(.primary)
            
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
            
            Spacer()
            
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
                .fill(Color(UIColor.systemGray5)) //background color
        )
        .padding(.horizontal)
    }
}


// 类型属性 (Type Property / Static Property)：使用 static 关键字。它不属于任何一个具体的实例，而是属于 TodoItem 这个类型本身。
// 这里的关键区别在于 static 关键字

// "关注点分离” (Separation of Concerns)
// extension：用来存放所有“附加”的、“便利性”的功能。
// 比如我们的预览样本数据、一些辅助的计算方法等。
// fileprivate 文件内私有

fileprivate extension TodoItem {
    static let sampleActive = TodoItem(
        title: "Meditate",
        iconName: "apple.meditate",
        timeInMinutes: 15,
        status: .new,
        isCompleted: false
    )
    
    static let sampleCompleted = TodoItem(
        title: "Clean bathroom",
        iconName: "shower",
        timeInMinutes: 25,
        status: .skip,
        isCompleted: false
    )
}


#Preview {
    VStack(spacing: 20) {
            TodoItemCardView(todoItem: .sampleActive)
            TodoItemCardView(todoItem: .sampleCompleted)
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
}
