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
    @Environment(\.scenePhase) private var scenePhase
    
    
    @State private var isCountdownMode = true
    
    // 当前时间（秒）
    @State private var timeInSeconds: Int
    
    // 计时器是否正在运行
    @State private var isRunning = false
    
    // 计时器对象，用于定时更新时间
    @State private var timer: Timer? = nil
    
    // 初始时间（分钟），仅用于倒计时模式
    @State private var initialTimeMinutes: Int
    
    // 是否显示确认放弃对话框
    @State private var showingAbandonAlert = false
    
    // 控制重置确认对话框的显示
    @State private var showingResetAlert = false
    
    // 是否已经开始过计时
    @State private var hasStarted = false
    
    // 是否曾经开始过倒计时（一旦开始就永远不能重置时间设置）
    @State private var hasEverStartedCountdown = false
    
    // 是否曾经开始过任何计时（用于控制放弃按钮显示）
    @State private var hasEverStarted = false
    
    // 记录本次会话开始时的时间快照（用于增量结算）
    @State private var sessionStartTimeSnapshot: Int = 0
    
    // 记录当前计时段开始的真实时间（用于前后台/丢tick对齐）
    @State private var segmentStartDate: Date?
    
    // 标记是否应该保存时间（用于区分正常退出和放弃退出）
    @State private var shouldSaveOnExit = true
    
    // 计算滑条的最大值
    private var maxSliderValue: Double {
        return Double(min(todoItem.timeInMinutes, 60))
    }
    
    // 初始化器
    init(todoItem: Binding<TodoItem>) {
        self._todoItem = todoItem
        let defaultMinutes = min(25, todoItem.wrappedValue.timeInMinutes)
        self._timeInSeconds = State(initialValue: defaultMinutes * 60)
        self._initialTimeMinutes = State(initialValue: defaultMinutes)
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                // 顶部区域：标题 + 模式切换 (固定高度: 120px)
                VStack(spacing: 15) {
                    Text(todoItem.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    // 计时模式选择器 - 开始后锁定模式
                    Group {
                        if hasEverStarted {
                            // 已开始计时：显示当前模式的固定标签
                            HStack {
                                Spacer()
                                Text(isCountdownMode ? "倒计时" : "正计时")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.primary.opacity(0.1))
                                    )
                                Spacer()
                            }
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 1.2).combined(with: .opacity)
                            ))
                        } else {
                            // 未开始计时：显示可切换的选择器
                            Picker("计时模式", selection: $isCountdownMode) {
                                Text("倒计时").tag(true)
                                Text("正计时").tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            .onChange(of: isCountdownMode) {
                                // 添加触感反馈
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                resetTimer()
                            }
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 1.2).combined(with: .opacity)
                            ))
                        }
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: hasEverStarted)
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
                                 .stroke(
                                     Color.primary,
                                     style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                 )
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
                                  set: { newValue in
                                      let newMinutes = Int(newValue)
                                      if newMinutes != initialTimeMinutes {
                                          // 每分钟变化时添加触感反馈
                                          let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                          impactFeedback.impactOccurred()
                                      }
                                      initialTimeMinutes = newMinutes
                                      resetTimer()
                                  }
                              ), in: 1...maxSliderValue, step: 1)
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
                            Button(role: .destructive, action: {
                                // 添加触感反馈
                                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                impactFeedback.impactOccurred()
                                
                                showingAbandonAlert = true
                            }) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.red.opacity(0.1),
                                                        Color.red.opacity(0.05)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 54, height: 54)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                            )
                                        
                                        Image(systemName: "xmark")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.red)
                                    }
                                    
                                    Text("放弃")
                                        .font(.system(.caption, design: .rounded, weight: .medium))
                                        .foregroundColor(.red)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("放弃")
                        } else {
                            // 占位空间，保持布局稳定
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 50, height: 70)
                        }
                        
                        // 开始/暂停按钮
                        Button(action: {
                            // 添加触感反馈
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            if isRunning {
                                pauseTimer()
                            } else {
                                startTimer()
                            }
                        }) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(Color.primary)
                                        .frame(width: 64, height: 64)
                                    
                                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(Color(.systemBackground))
                                }
                                
                                Text(isRunning ? "暂停" : "开始")
                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isRunning ? "暂停" : "开始")
                        
                        // 重置按钮 - 一旦开始过计时就一直显示
                        if hasEverStarted {
                            Button(action: {
                                // 添加触感反馈
                                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                impactFeedback.impactOccurred()
                                
                                showingResetAlert = true
                            }) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.secondary.opacity(0.1),
                                                        Color.secondary.opacity(0.05)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 54, height: 54)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                            )
                                        
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("重置")
                                        .font(.system(.caption, design: .rounded, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("重置")
                        } else {
                            // 占位空间，保持布局稳定
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 50, height: 70)
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
                            // 添加触感反馈
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            pauseTimer()
                            dismiss()
                        }) {
                            Text("完成计时")
                                .font(.system(.headline, design: .rounded, weight: .semibold))
                                .foregroundColor(Color(.systemBackground))
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(Color.primary)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
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
        .background(Color(.systemBackground))
        .navigationTitle("专注计时")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确认放弃", isPresented: $showingAbandonAlert) {
            Button("取消", role: .cancel) { }
            Button("确认放弃", role: .destructive) {
                // 放弃时不保存时间
                shouldSaveOnExit = false
                pauseTimer(save: false)
                dismiss()
            }
        } message: {
            Text("放弃将丢弃当前计时结果，确定要放弃吗？")
        }
        .alert("确认重置", isPresented: $showingResetAlert) {
            Button("取消", role: .cancel) { }
            Button("确认重置", role: .destructive) {
                resetTimer()
            }
        } message: {
            Text("重置将丢弃当前计时结果，确定要重置吗？")
        }
        .onDisappear {
            // 停止计时器
            timer?.invalidate()
            timer = nil
            // 根据shouldSaveOnExit标志决定是否保存时间
            if shouldSaveOnExit {
                saveTimeToTodoItem()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active && isRunning {
                // 从后台回到前台时，重新对齐时间
                if let startDate = segmentStartDate {
                    let elapsed = Date().timeIntervalSince(startDate)
                    
                    if isCountdownMode {
                        let newTime = max(0, sessionStartTimeSnapshot - Int(elapsed))
                        timeInSeconds = newTime
                        
                        if newTime == 0 {
                            pauseTimer()
                        }
                    } else {
                        timeInSeconds = sessionStartTimeSnapshot + Int(elapsed)
                    }
                }
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
        
        // 设置开始标记（单一入口）- 使用动画
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
            hasStarted = true
            hasEverStarted = true
            if isCountdownMode {
                hasEverStartedCountdown = true
            }
        }
        
        // 记录本次会话开始时的时间快照
        sessionStartTimeSnapshot = timeInSeconds
        
        // 记录当前计时段开始的真实时间
        segmentStartDate = Date()
        
        // 设置状态为运行中
        isRunning = true
        
        // 创建一个每秒触发一次的计时器
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // 注意：结构体不需要使用 [weak self]，因为结构体是值类型，不会造成循环引用
            
            // 真实流逝时间对齐
            if let startDate = self.segmentStartDate {
                let elapsed = Date().timeIntervalSince(startDate)
                
                if self.isCountdownMode {
                    // 倒计时模式：从快照减去流逝时间
                    let newTime = max(0, self.sessionStartTimeSnapshot - Int(elapsed))
                    self.timeInSeconds = newTime
                    
                    if newTime == 0 {
                        // 时间到时的处理
                        self.pauseTimer()
                    }
                } else {
                    // 正计时模式：快照加上流逝时间
                    self.timeInSeconds = self.sessionStartTimeSnapshot + Int(elapsed)
                }
            }
        }
        
        // 将计时器加入.common RunLoop模式，防止交互期间暂停
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
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
        // 清空时间锚点
        segmentStartDate = nil
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
        
        // 重置开始状态 - 使用动画
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
            hasStarted = false
            hasEverStartedCountdown = false  // 重置后允许重新设置时间
            hasEverStarted = false  // 重置后恢复选择器可用状态
        }
        
        // 重置后恢复保存标志
        shouldSaveOnExit = true
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
