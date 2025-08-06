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
//                    .font(.system(size: 22, weight: .regular))
//                    .padding(.vertical, 6)
            }
            
            // MARK: - 时间设置 Section
            Section {
                // 如果是全天任务，只显示日期选择器
                if todoItem.isAllDay {
                    DatePicker("日期", selection: $todoItem.startDate, displayedComponents: .date)
                } else {
                    // 否则显示完整的开始和结束日期时间选择器
                    // 注意：这里为了简化，我们只用一个 dueDate，您可以扩展为 startDate 和 endDate
                    DatePicker("开始时间", selection: $todoItem.startDate)
                    DatePicker("结束时间", selection: $todoItem.endDate)
                }
                
                // “全天”开关，它的改变会影响上面的 DatePicker
                Toggle("全天", isOn: $todoItem.isAllDay)
            }
            
            // MARK: - 分类与优先级 Section
            Section {
                Picker("优先级", selection: $todoItem.priority) {
                    ForEach(TodoItem.Priority.allCases) { priority in
                        Text(priority.rawValue)
                    }
                }
                .pickerStyle(.menu) // 使用下拉菜单样式，更紧凑
            }
            
            // MARK: - 备注 Section
            Section(header: Text("备注")) {
                // 用一个占位符来模拟 "写备注"
                TextEditor(text: $todoItem.notes)
                    .frame(minHeight: 60) // 给备注一个最小高度
            }
        }
        .navigationTitle("任务详情") // 导航栏标题
        .navigationBarTitleDisplayMode(.inline) // 小标题样式
        
        // MARK: - 导航栏按钮
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    // 在这里可以添加保存或关闭页面的逻辑
                    // 由于使用了@Binding，数据已经自动保存了
                    print("完成按钮被点击。当前标题: \(todoItem.title)")
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
