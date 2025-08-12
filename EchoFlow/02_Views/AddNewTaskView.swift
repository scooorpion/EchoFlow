//
//  AddNewTaskView.swift
//  EchoFlow
//
//  Created by Assistant on 2025/8/6.
//

import SwiftUI

struct AddNewTaskView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // 新任务的属性
    @State private var title: String = ""
    @State private var timeInputText: String = ""
    @State private var description: String = ""
    @State private var notes: String = ""
    @State private var autoFill: String = ""
    
    // 回调函数，用于将新任务传递给父视图
    var onAddTask: (TodoItem) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                // 自动填补部分
                Section(header: Text("自动填补")) {
                    TextEditor(text: $autoFill)
                        .frame(minHeight: 30)
                }
                
                // 基本信息部分
                Section {
                    LabeledContent {
                        TextField("输入任务名称", text: $title)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Text("任务名称")
                    }
                    
                    LabeledContent {
                        TextField("输入时间", text: $timeInputText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .onChange(of: timeInputText) { _, newValue in
                                // 只允许数字输入，最多4位
                                let filtered = newValue.filter { $0.isNumber }
                                let limited = String(filtered.prefix(4))
                                
                                if limited != newValue {
                                    timeInputText = limited
                                }
                            }
                    } label: {
                        Text("设定分钟")
                    }
                }
                
                // 描述部分
                Section(header: Text("描述（可选）")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 60)
                }
                
                // 备注部分
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("新建任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        createNewTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func createNewTask() {
        // 创建新的TodoItem
        let timeInMinutes = Int(timeInputText) ?? 0
        
        var newTask = TodoItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            timeInSeconds: timeInMinutes * 60,
            description: description,
            notes: notes
        )
        
        newTask.AutoFill = autoFill
        
        print("创建新任务: \(newTask.title), 时间: \(newTask.timeInMinutes)分钟")
        
        // 通过回调传递新任务
        onAddTask(newTask)
        
        // 关闭视图
        dismiss()
    }
}

#Preview {
    AddNewTaskView { newTask in
        print("预览中添加任务: \(newTask.title)")
    }
}