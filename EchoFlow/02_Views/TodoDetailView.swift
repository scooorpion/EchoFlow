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
    @State private var timeInputText: String = ""
    
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
                    TextField("输入时间", text: $timeInputText)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .onChange(of: timeInputText) { _, newValue in
                            // 只允许数字字符
                            let filtered = newValue.filter { $0.isNumber }
                            // 限制最多4位数字
                            let limited = String(filtered.prefix(4))
                            
                            if limited != newValue {
                                timeInputText = limited
                            }
                            
                            // 更新todoItem的timeInMinutes
                            if let intValue = Int(limited) {
                                todoItem.timeInMinutes = intValue
                            } else if limited.isEmpty {
                                todoItem.timeInMinutes = 0
                            }
                        }
                } label: {
                    Text("设定分钟")
                }
                
                // 显示已用时间（只读）
                if todoItem.usedTimeInMinutes > 0 {
                    LabeledContent {
                        Text("\(todoItem.usedTimeInMinutes)")
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.blue)
                    } label: {
                        Text("已用分钟")
                    }
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
        .onAppear {
            // 初始化时间输入文本
            timeInputText = todoItem.timeInMinutes > 0 ? String(todoItem.timeInMinutes) : ""
        }
        
        // MARK: - 导航栏按钮
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
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
