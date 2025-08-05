//
//  TodoDetailView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import SwiftUI

// 定义待办事项的详情页面
struct TodoDetailView: View {
    
    // 接收从列表中传入的待办事项数据
    let todoItem: TodoItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // 显示标题
            Text(todoItem.title)
                .font(.title) // 使用大标题样式
                .bold()       // 加粗
            
            // 预留：将来可以添加更多字段，如时间、描述等
            // Text("总时长：90分钟")
            // Text("优先级：高")
            
            Spacer() // 推动内容靠上
        }
        .padding() // 给整个 VStack 添加内边距
        .navigationTitle("详情") // 设置导航栏标题
    }
}
