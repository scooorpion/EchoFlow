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
                            
                            // 更新todoItem的timeInMinutes（使用计算属性，自动转换为秒）
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
                TextEditor(text: $todoItem.description)
                    .frame(minHeight: 40)
            }
            
            Section(header: Text("备注")) {
                TextEditor(text: $todoItem.notes)
                    .frame(minHeight: 40)
            }
        }
        .navigationTitle("任务详情")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            timeInputText = todoItem.timeInMinutes > 0 ? String(todoItem.timeInMinutes) : ""
        }
        
        
    }
}

#Preview {
    NavigationStack {
        TodoDetailView(todoItem: .constant(TodoItem.sampleActive))
    }
}
