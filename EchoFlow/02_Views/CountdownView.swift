//
//  CountdownView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/6.
//

import SwiftUI

struct CountdownView: View {
    // 绑定待办事项，使用@Binding确保修改会反映到父视图
    @Binding var todoItem: TodoItem
    // 用于关闭当前视图的环境变量
    @Environment(\.dismiss) private var dismiss
    
    // State变量解释：
    // 1. @State是SwiftUI中用于存储视图的本地状态的属性包装器
    // 2. 当@State变量改变时，SwiftUI会自动重新渲染视图
    
    // 计时模式：true为倒计时，false为正计时
    @State private var isCountdownMode = true
    // 计时时间（秒）：倒计时模式下为剩余时间，正计时模式下为已用时间
    @State private var timeInSeconds: Int
    // 计时器是否正在运行
    @State private var isRunning = false
    // 计时器对象，用于定时更新时间
    @State private var timer: Timer? = nil
    // 初始时间（分钟），仅用于倒计时模式
    @State private var initialTimeMinutes: Int
    // 是否显示确认放弃对话框
    @State private var showingAbandonAlert = false
    // 是否已经开始过计时
    @State private var hasStarted = false
    
    // 初始化方法
    init(todoItem: Binding<TodoItem>) {
        // 绑定todoItem
        self._todoItem = todoItem
        
        // 倒计时默认时间固定为25分钟，与TodoItem的设定时间无关
        let defaultCountdownMinutes = 25
        
        // 保存初始时间（分钟）- 倒计时专用
        self._initialTimeMinutes = State(initialValue: defaultCountdownMinutes)
        
        // 初始化计时时间（秒）
        // 默认为倒计时模式，使用固定的25分钟
        self._timeInSeconds = State(initialValue: defaultCountdownMinutes * 60)
        
        // 如果用户想要正计时模式，可以手动切换
        // 这里默认都是倒计时模式
    }
    
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
                                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                .frame(width: 280, height: 280)
                            
                            // 进度圈
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 20, lineCap: .round))
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
                    if isCountdownMode && !isRunning && !hasStarted {
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
                        // 放弃按钮
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
                        
                        // 开始/暂停按钮
                        Button(action: {
                            if isRunning {
                                pauseTimer()
                            } else {
                                startTimer()
                                hasStarted = true
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
                    if !isCountdownMode && hasStarted {
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
                // 保存当前时间
                saveTimeToTodoItem()
                // 关闭视图
                dismiss()
            }
        } message: {
            Text("放弃将保存当前计时结果，确定要放弃吗？")
        }
        .onDisappear {
            // 确保离开视图时停止计时器并保存时间
            saveTimeToTodoItem()
            timer?.invalidate()
            timer = nil
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
                    self.saveTimeToTodoItem()
                }
            } else {
                // 正计时模式：时间一直增加
                self.timeInSeconds += 1
                // 正计时模式不需要每秒保存，只在暂停或结束时保存
            }
        }
    }
    
    // 暂停计时函数 - 停止但不重置计时器
    private func pauseTimer() {
        // 设置状态为非运行
        isRunning = false
        // 停止计时器
        timer?.invalidate()
        // 清空计时器引用
        timer = nil
        // 保存当前时间到TodoItem
        saveTimeToTodoItem()
    }
    
    // 重置计时函数 - 停止计时器并重置时间
    private func resetTimer() {
        // 先暂停计时器
        pauseTimer()
        
        if isCountdownMode {
            // 倒计时模式：重置为初始时间
            timeInSeconds = initialTimeMinutes * 60
        } else {
            // 正计时模式：重置为0
            timeInSeconds = 0
        }
        
        // 重置开始状态
        hasStarted = false
    }
    
    // 保存时间到TodoItem
    private func saveTimeToTodoItem() {
        // 只有在计时器运行过或有时间变化时才保存
        if hasStarted {
            if isCountdownMode {
                // 倒计时模式：累加已用时间到TodoItem的已用时间中
                let usedTimeInSeconds = (initialTimeMinutes * 60) - timeInSeconds
                if usedTimeInSeconds > 0 {
                    // 将本次倒计时的已用时间累加到TodoItem的总已用时间中
                    todoItem.usedTimeInSeconds += usedTimeInSeconds
                }
                // 注意：不修改todoItem的timeInSeconds，保持原有的设定时间不变
            } else {
                // 正计时模式：累加已用时间到TodoItem的已用时间中
                if timeInSeconds > 0 {
                    todoItem.usedTimeInSeconds += timeInSeconds
                }
                // 注意：不修改todoItem的timeInSeconds，保持原有的设定时间不变
            }
            
            // 保存后重置状态，避免重复保存
            hasStarted = false
        }
    }
}

#Preview {
    NavigationStack {
        CountdownView(todoItem: .constant(TodoItem.sampleActive))
    }
}
