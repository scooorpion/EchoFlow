//
//  TodoItemCardView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/6.
//

import SwiftUI

// 自定义的单个代办事项卡片视图 - 进度条样式
struct TodoItemCardView: View {
    
    // 传入的待办事项数据 - 使用@Binding确保数据变化时视图会更新
    @Binding var todoItem: TodoItem
    
    // 滑动手势状态
    @State private var offset: CGFloat = 0
    @State private var showingDeleteAlert = false
    @State private var showingEditView = false
    @State private var dragVelocity: CGFloat = 0
    
    // 删除回调
    var onDelete: (() -> Void)? = nil
    
    // 计算进度百分比
    private var progress: Double {
        guard todoItem.timeInSeconds > 0 else { return 0 }
        return min(Double(todoItem.usedTimeInSeconds) / Double(todoItem.timeInSeconds), 1.0)
    }
    
    // 进度条颜色
    private var progressColor: Color {
        if todoItem.isCompleted {
            return Color(red: 0.2, green: 0.7, blue: 0.3)
        } else if progress >= 1.0 {
            return Color(red: 0.9, green: 0.5, blue: 0.2)
        } else if progress >= 0.8 {
            return Color(red: 0.9, green: 0.7, blue: 0.2)
        } else {
            return Color(red: 0.3, green: 0.6, blue: 0.9)
        }
    }
    
    var body: some View {
        ZStack {
            // 背景按钮层
            HStack {
                // 左滑显示编辑按钮
                if offset > 0 {
                    Button(action: {
                        // 添加触感反馈
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        showingEditView = true
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .scaleEffect(min(offset / 80, 1.0))
                    }
                    .padding(.leading, 20)
                    .opacity(offset > 20 ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: offset)
                }
                
                Spacer()
                
                // 右滑显示删除按钮
                if offset < 0 {
                    Button(action: {
                        // 添加触感反馈
                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                        impactFeedback.impactOccurred()
                        
                        showingDeleteAlert = true
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.red)
                            .clipShape(Circle())
                            .scaleEffect(min(abs(offset) / 80, 1.0))
                    }
                    .padding(.trailing, 20)
                    .opacity(abs(offset) > 20 ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: offset)
                }
            }
            
            // 主内容层
            HStack(alignment: .center, spacing: 16) {
                // 左侧内容
                VStack(alignment: .leading, spacing: 6) {
                    Text(todoItem.title)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(todoItem.isCompleted ? .secondary : .primary)
                        .strikethrough(todoItem.isCompleted, color: .secondary)
                        .lineLimit(1)
                    
                    if !todoItem.taskDescription.isEmpty {
                            Text(todoItem.taskDescription)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    // 进度信息
                    if todoItem.timeInSeconds > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                                .foregroundColor(progressColor)
                            
                            Text("\(todoItem.usedTimeInMinutes)/\(todoItem.timeInMinutes)分钟")
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundColor(progressColor)
                            
                            if progress > 0 {
                                Text("(\(Int(progress * 100))%)")
                                    .font(.system(.caption2, design: .rounded, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(height: 80)
            .background(
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                        
                        // 进度条背景
                        if todoItem.timeInSeconds > 0 {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(progressColor.opacity(0.2))
                                .frame(width: geometry.size.width * progress)
                                .animation(.easeInOut(duration: 0.3), value: progress)
                        }
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.width
                        dragVelocity = value.velocity.width
                    }
                    .onEnded { value in
                        let finalOffset = value.translation.width
                        let velocity = value.velocity.width
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            // 右滑删除逻辑：滑动距离超过120或速度足够快
                            if finalOffset < -120 || (finalOffset < -50 && velocity < -500) {
                                // 滑到底部自动触发删除确认
                                offset = 0
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showingDeleteAlert = true
                                }
                            }
                            // 左滑编辑逻辑：滑动距离超过120或速度足够快
                            else if finalOffset > 120 || (finalOffset > 50 && velocity > 500) {
                                // 滑到底部自动触发编辑
                                offset = 0
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showingEditView = true
                                }
                            }
                            // 显示按钮状态
                            else if abs(finalOffset) > 50 {
                                offset = finalOffset > 0 ? 80 : -80
                            }
                            // 回弹
                            else {
                                offset = 0
                            }
                        }
                    }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showingEditView) {
             NavigationStack {
                 TodoDetailView(todoItem: $todoItem)
             }
         }
        .alert("删除确认", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("确定要删除这个待办事项吗？")
        }
    }
}


#Preview {
    VStack(spacing: 20) {
        TodoItemCardView(todoItem: .constant(TodoItem.sampleActive))
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
