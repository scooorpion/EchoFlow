//
//  TodoDetailView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import SwiftUI

struct TodoDetailView: View {
    
    // 使用 @Binding，这样对 todoItem 的任何修改，都会自动同步回上一个页面（主列表），就像电话线
    @Binding var todoItem: TodoItem
    
    var body: some View {
        Form {
            // MARK: - 任务标题 Section
            Section() {
                TextField("任务标题", text: $todoItem.title)
            }
            
            // MARK: - 时间设置 Section
            Section {
                // 如果是全天任务，只显示日期选择器
                if todoItem.isAllDay {
                    DatePicker("日期", selection: $todoItem.startDate, displayedComponents: .date)
                } else {
                    DatePicker("开始时间", selection: $todoItem.startDate)
                    DatePicker("结束时间", selection: $todoItem.endDate)
                }
                
                Toggle("全天", isOn: $todoItem.isAllDay)
            }
            
            // MARK: - 备注 Section
//            Section(header: Text("备注")) {
//                // 用一个占位符来模拟 "写备注"
//                TextEditor(text: $todoItem.notes)
//                    .frame(minHeight: 60) // 给备注一个最小高度
//            }
        }
        .navigationTitle("任务详情") // 导航栏标题
        .navigationBarTitleDisplayMode(.inline) // 小标题样式
        
        // MARK: - 导航栏按钮
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                
                    print("完成按钮被点击。当前标题: \(todoItem.title)")
                }
                .fontWeight(.bold)
            }
        }
        
        
    }
}

//#Preview {
//    
//    NavigationStack {
//        TodoDetailView(todoItem: .constant(TodoItem.sampleActive))
//    }
//}
