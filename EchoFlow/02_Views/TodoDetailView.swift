//
//  TodoDetailView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import SwiftUI

struct TodoDetailView: View {
    
    // 使用 @Binding，这样对 todoItem 的任何修改，
    // 都会自动同步回上一个页面（主列表）！
    // 这就是那根“电话线”。
    @Binding var todoItem: TodoItem
    
    var body: some View {
        // 使用 Form 布局，让编辑界面看起来更像系统设置，很专业
        Form {
            Section(header: Text("任务详情")) {
                // 将任务标题绑定到一个文本输入框
                TextField("任务标题", text: $todoItem.title)
                
                // 添加一个开关来切换完成状态
                Toggle("标记为完成", isOn: $todoItem.isCompleted)
            }
        }
        // 给这个页面设置一个导航栏标题
        .navigationTitle("编辑任务")
        // 设置导航栏标题的显示模式为内联，更紧凑
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    
    NavigationStack {
        TodoDetailView(todoItem: .constant(TodoItem.sampleActive))
    }
}
