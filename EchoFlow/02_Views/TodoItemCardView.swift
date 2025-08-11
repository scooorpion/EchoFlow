//
//  TodoItemCardView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/6.
//

import SwiftUI

// 自定义的单个代办事项卡片视图
struct TodoItemCardView: View {
    
    // 传入的待办事项数据 - 使用@Binding确保数据变化时视图会更新
    @Binding var todoItem: TodoItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todoItem.title)
                    .font(.headline)
                    .foregroundColor(todoItem.isCompleted ? .gray : .primary)
                    .strikethrough(todoItem.isCompleted, color: .gray) 
                    .lineLimit(1)
                
                Text(todoItem.description)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                // 显示设定的时间
                if todoItem.timeInMinutes > 0 {
                    Text("设定: \(todoItem.timeInMinutes)分钟")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 显示实际使用的时间
                if todoItem.usedTimeInMinutes > 0 {
                    Text("已用: \(todoItem.usedTimeInMinutes)分钟")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        // .padding(.horizontal)
    }
}


extension TodoItem {
    static let sampleActive = TodoItem(
        title: "Meditate",
        timeInSeconds: 15 * 60  // 15分钟转换为秒
    ).apply { $0.usedTimeInSeconds = 5 * 60 }  // 5分钟转换为秒
    
    static let sampleCompleted = TodoItem(
        title: "Clean bathroom",
        timeInSeconds: 25 * 60  // 25分钟转换为秒
    ).apply { $0.usedTimeInSeconds = 20 * 60 }  // 20分钟转换为秒
}

#Preview {
    @State var sampleItem = TodoItem.sampleActive
    return VStack(spacing: 20) {
        TodoItemCardView(todoItem: $sampleItem)
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
