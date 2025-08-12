//
//  CountdownView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/6.
//

import SwiftUI

struct CountdownView: View {
    
    @Binding var todoItem: TodoItem
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var isCountdownMode = true
    
    // 当前时间（秒）
    @State private var timeInSeconds = 25 * 60
    
    // 计时器是否正在运行
    @State private var isRunning = false
    
    // 计时器对象，用于定时更新时间
    @State private var timer: Timer? = nil
    
    // 初始时间（分钟），仅用于倒计时模式
    @State private var initialTimeMinutes = 25
    
    // 是否显示确认放弃对话框
    @State private var showingAbandonAlert = false
    
    // 是否已经开始过计时
    @State private var hasStarted = false
    
    // 是否曾经开始过倒计时（一旦开始就永远不能重置时间设置）
    @State private var hasEverStartedCountdown = false
    
    // 是否曾经开始过任何计时（用于控制放弃按钮显示）
    @State private var hasEverStarted = false
    
    // 记录本次会话开始时的时间快照（用于计算增量时间）
    @State private var sessionStartTimeSnapshot: Int = 0
    
    // 标记是否是放弃操作，用于避免在onDisappear中保存时间
    @State private var isAbandoning = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 顶部区域：标题 + 模式切换 (固定高度: 120px)
                VStack(spacing: 15) {
                    Text(todoItem.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Picker("计时模式", selection: $isCountdownMode) {
                        Text("倒计时").tag(true)
                        Text("正计时").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .onChange(of: isCountdownMode) {
                        resetTimer()
                    }
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                
                Spacer(minLength: 20)
                
                // 计时显示区域 (固定高度: 300px)
                VStack {
                    if isCountdownMode {
                        // 倒计时模式 - 显示圆环和时间
                        ZStack {
                            // 外圈
                             Circle()
                                 .stroke(Color.primary.opacity(0.1), lineWidth: 20)
                                 .frame(width: 280, height: 280)
                             
                             // 进度圈
                             Circle()
                                 .trim(from: 0, to: progress)
                                 .stroke(Color.primary, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                 .frame(width: 280, height: 280)
                                 .rotationEffect(.degrees(-90))
                            
                            // 时间文本 - 倒计时模式
                            VStack {
                                Text(timeString)
                                    .font(.system(size: 60, weight: .bold))
                                
                                Text("剩余时间")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        // 正计时模式 - 只显示时间文本，不显示圆环
                        VStack {
                            Text(timeString)
                                .font(.system(size: 60, weight: .bold))
                            
                            Text("已用时间")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(width: 280, height: 280)
                    }
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                
                Spacer(minLength: 10)
                
                // 滑块区域 (固定高度: 80px)
                 VStack {
                     if isCountdownMode && !hasEverStartedCountdown {
                         VStack(spacing: 10) {
                             Text("\(initialTimeMinutes) 分钟")
                                 .font(.headline)
                             
                             Slider(value: Binding<Double>(
                                 get: { Double(initialTimeMinutes) },
                                 set: { 
                                     initialTimeMinutes = Int($0)
                                     resetTimer()
                                 }
                             ), in: 1...60, step: 1)
                             .padding(.horizontal)
                         }
                     } else {
                         // 占位空间，保持布局稳定
                         Rectangle()
                             .fill(Color.clear)
                     }
                 }
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                
                Spacer(minLength: 10)
                
                // 控制按钮区域 (固定高度: 100px)
                VStack {
                    HStack(spacing: 40) {
                        // 放弃按钮 - 一旦开始过计时就一直显示
                        if hasEverStarted {
                            Button(action: {
                                showingAbandonAlert = true
                            }) {
                                VStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.red)
                                    Text("放弃")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        } else {
                            // 占位空间，保持布局稳定
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 50, height: 70)
                        }
                        
                        // 开始/暂停按钮
                        Button(action: {
                            if isRunning {
                                pauseTimer()
                            } else {
                                startTimer()
                                hasStarted = true
                                hasEverStarted = true  // 标记为曾经开始过计时
                                // 如果是倒计时模式，标记为曾经开始过倒计时
                                if isCountdownMode {
                                    hasEverStartedCountdown = true
                                }
                            }
                        }) {
                            VStack {
                                Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                Text(isRunning ? "暂停" : "开始")
                                    .font(.caption)
                            }
                        }
                        
                        // 重置按钮
                        Button(action: {
                            resetTimer()
                        }) {
                            VStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                                Text("重置")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                
                Spacer(minLength: 10)
                
                // 完成按钮区域 (固定高度: 70px)
                VStack {
                    if !isCountdownMode && hasEverStarted && timeInSeconds >= 5 {
                        Button(action: {
                            saveTimeToTodoItem()
                            dismiss()
                        }) {
                            Text("完成计时")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    } else {
                        // 占位空间，保持布局稳定
                        Rectangle()
                            .fill(Color.clear)
                    }
                }
                .frame(height: 70)
                .frame(maxWidth: .infinity)
                
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal)
        .navigationTitle("专注计时")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确认放弃", isPresented: $showingAbandonAlert) {
            Button("取消", role: .cancel) { }
            Button("确认放弃", role: .destructive) {
                // 标记为放弃操作，避免在onDisappear中保存时间
                isAbandoning = true
                // 放弃时不保存当前计时结果，直接关闭视图
                dismiss()
            }
        } message: {
            Text("放弃将丢弃当前计时结果，确定要放弃吗？")
        }
        .onDisappear {
            // 先停止计时器，避免极端竞态条件
            timer?.invalidate()
            timer = nil
            // 只有在非放弃操作时才保存时间
            if !isAbandoning {
                saveTimeToTodoItem()
            }
        }
    }
    
    // 计算进度比例 - 用于绘制圆形进度条
    private var progress: CGFloat {
        if isCountdownMode {
            // 倒计时模式：剩余时间占总时间的比例
            if initialTimeMinutes > 0 {
                return CGFloat(timeInSeconds) / CGFloat(initialTimeMinutes * 60)
            }
            return 0
        } else {
            // 正计时模式：已用时间占60分钟的比例（最大为1）
            // 使用固定的60分钟作为最大值，这样进度条会随着时间增长而增长
            return min(CGFloat(timeInSeconds) / CGFloat(60 * 60), 1.0)
        }
    }
    
    // 格式化时间显示 - 将秒数转换为分:秒格式
    private var timeString: String {
        // 计算分钟数（整除60）
        let minutes = timeInSeconds / 60
        // 计算剩余秒数（取余60）
        let seconds = timeInSeconds % 60
        // 格式化为两位数，不足两位前面补0
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 开始计时函数 - 创建并启动计时器
    private func startTimer() {
        // 如果计时器已经在运行，先停止它
        timer?.invalidate()
        
        // 记录本次会话开始时的时间快照
        sessionStartTimeSnapshot = timeInSeconds
        
        // 设置状态为运行中
        isRunning = true
        
        // 创建一个每秒触发一次的计时器
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // 注意：结构体不需要使用 [weak self]，因为结构体是值类型，不会造成循环引用
            
            if self.isCountdownMode {
                // 倒计时模式
                if self.timeInSeconds > 0 {
                    // 每秒减少1秒
                    self.timeInSeconds -= 1
                } else {
                    // 时间到时的处理
                    self.pauseTimer()
                    // 保存时间到TodoItem
                    // self.saveTimeToTodoItem()
                }
            } else {
                // 正计时模式：时间一直增加
                self.timeInSeconds += 1
                // 正计时模式不需要每秒保存，只在暂停或结束时保存
            }
        }
    }
    
    // 暂停计时函数 - 停止但不重置计时器
    private func pauseTimer(save: Bool = true) {
        // 设置状态为非运行
        isRunning = false
        // 停止计时器
        timer?.invalidate()
        // 清空计时器引用
        timer = nil
        // 根据参数决定是否保存当前时间到TodoItem
        if save {
            saveTimeToTodoItem()
        }
    }
    
    // 重置计时函数 - 停止计时器并重置时间
    private func resetTimer() {
        // 先暂停计时器，但不保存时间
        pauseTimer(save: false)
        
        if isCountdownMode {
            // 倒计时模式：重置为初始时间
            timeInSeconds = initialTimeMinutes * 60
        } else {
            // 正计时模式：重置为0
            timeInSeconds = 0
        }
        
        // 重置开始状态
        hasStarted = false
        hasEverStartedCountdown = false  // 重置后允许重新设置时间
    }
    
    // 保存时间到TodoItem
    private func saveTimeToTodoItem() {
        
        if hasStarted {
            if isCountdownMode {
                // 倒计时模式：计算本次会话实际用掉的时间
                // 本次会话用时 = 开始时剩余时间 - 当前剩余时间
                let sessionUsedTime = sessionStartTimeSnapshot - timeInSeconds
                if sessionUsedTime > 0 {
                    todoItem.usedTimeInSeconds += sessionUsedTime
                }
            } else {
                // 正计时模式：计算本次会话增加的时间
                // 本次会话用时 = 当前累计时间 - 开始时累计时间
                let sessionUsedTime = timeInSeconds - sessionStartTimeSnapshot
                if sessionUsedTime > 0 {
                    todoItem.usedTimeInSeconds += sessionUsedTime
                }
            }
            hasStarted = false
        }
    }
    
}

#Preview {
    NavigationStack {
        CountdownView(todoItem: .constant(TodoItem.sampleActive))
    }
}
