//
//  TodoDetailView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import SwiftUI

struct TodoDetailView: View {
    
    @Binding var todoItem: TodoItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            // MARK: - Basic Section
            
            
            Section(header: Text("自动填补")) {
                TextEditor(text: $todoItem.AutoFill)
                    .frame(minHeight: 30)
            }
            
            Section {
                
                LabeledContent {
                    TextField("输入名称", text: $todoItem.title)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Text("任务名称")
                }
                
                
                LabeledContent {
                    TextField("输入时间", value: Binding(
                        get: { todoItem.timeInMinutes },
                        set: { newValue in
                            let clamped = min(newValue, 9999)
                            todoItem.timeInMinutes = clamped
                        }
                    ),
                    format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                } label: {
                    Text("分钟")
                }
                
            }
            
            Section(header: Text("描述（可选）")) {
                // 用一个占位符来模拟 "写备注"
                TextEditor(text: $todoItem.description)
                    .frame(minHeight: 40) // 给备注一个最小高度
            }
            
            // MARK: - 时间设置 Section
            Section {
                if todoItem.isAllDay {
                    DatePicker("日期", selection: $todoItem.startDate, displayedComponents: .date)
                } else {
                    DatePicker("开始时间", selection: $todoItem.startDate)
                    DatePicker("结束时间", selection: $todoItem.endDate)
                }
                
                Toggle("全天", isOn: $todoItem.isAllDay)
            }
            
            // MARK: - 备注 Section
            
            Section(header: Text("备注")) {
                // 用一个占位符来模拟 "写备注"
                TextEditor(text: $todoItem.notes)
                    .frame(minHeight: 40) // 给备注一个最小高度
            }
        }
        .navigationTitle("任务详情") // 导航栏标题
        .navigationBarTitleDisplayMode(.inline) // 小标题样式
        
        // MARK: - 导航栏按钮
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    // 由于使用了@Binding，修改会自动保存到父视图
                    // 关闭当前视图，返回到列表页面
                    dismiss()
                }
                .fontWeight(.bold)
            }
        }
        
        
    }
}

#Preview {
    
    NavigationStack {
        TodoDetailView(todoItem: .constant(TodoItem.sampleActive))
    }
}
