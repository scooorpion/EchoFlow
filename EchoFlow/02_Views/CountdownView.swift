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
    
    // 初始化方法
    init(todoItem: Binding<TodoItem>) {
        // 初始化绑定的待办事项
        self._todoItem = todoItem
        
        // 保存初始时间（分钟）
        self._initialTimeMinutes = State(initialValue: todoItem.wrappedValue.timeInMinutes)
        
        // 初始化计时时间（秒）
        // 默认为倒计时模式，将分钟转换为秒
        // 注意：这里使用了todoItem.wrappedValue来获取实际的TodoItem值
        // 因为todoItem是Binding类型，需要通过wrappedValue访问实际值
        self._timeInSeconds = State(initialValue: todoItem.wrappedValue.timeInMinutes * 60) // 转换为秒
        
        // 默认使用倒计时模式，如果todoItem的timeInMinutes为0，则切换到正计时模式
        if todoItem.wrappedValue.timeInMinutes == 0 {
            self._isCountdownMode = State(initialValue: false)
            self._timeInSeconds = State(initialValue: 0) // 正计时从0开始
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // 顶部标题
            Text(todoItem.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // 计时模式切换
            Picker("计时模式", selection: $isCountdownMode) {
                Text("倒计时").tag(true)
                Text("正计时").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .onChange(of: isCountdownMode) { newValue in
                // 切换模式时重置计时器
                resetTimer()
            }
            
            // 大圆形计时显示
            ZStack {
                // 外圈和进度圈只在倒计时模式下显示
                if isCountdownMode {
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
                }
                
                // 时间文本 - 在两种模式下都显示
                VStack {
                    Text(timeString)
                        .font(.system(size: 60, weight: .bold))
                    
                    Text(isCountdownMode ? "剩余时间" : "已用时间")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 280, height: 280) // 确保在正计时模式下也保持相同的空间
            
            // 时间调整滑块（仅在倒计时模式且非运行状态下显示）
            if isCountdownMode && !isRunning {
                VStack {
                    Text("\(initialTimeMinutes) 分钟")
                        .font(.headline)
                    
                    Slider(value: Binding<Double>(
                        get: { Double(initialTimeMinutes) },
                        set: { 
                            initialTimeMinutes = Int($0)
                            // 更新todoItem的timeInMinutes
                            todoItem.timeInMinutes = initialTimeMinutes
                            // 重置计时器以应用新时间
                            resetTimer()
                        }
                    ), in: 1...60, step: 1)
                    .padding(.horizontal)
                }
            }
            
            // 控制按钮
            HStack(spacing: 40) {
                // 放弃按钮
                Button(action: {
                    // 显示确认对话框
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
            .padding(.top, 20)
            
            // 完成按钮
            Button(action: {
                // 停止计时器并保存时间
                saveTimeToTodoItem()
                // 关闭视图
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
            .padding(.top, 20)
        }
        .padding()
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
                // 每次更新时保存当前时间到TodoItem
                self.saveTimeToTodoItem()
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
    }
    
    // 保存时间到TodoItem
    private func saveTimeToTodoItem() {
        if isCountdownMode {
            // 倒计时模式：保存已用时间（初始时间减去剩余时间）
            let usedTimeInMinutes = initialTimeMinutes - (timeInSeconds / 60)
            // 保留原始设定的时间值
            todoItem.timeInMinutes = initialTimeMinutes
            // 记录实际使用的时间到新属性
            todoItem.usedTimeInMinutes = max(usedTimeInMinutes, 0)
        } else {
            // 正计时模式：直接保存已用时间（秒转分钟，向上取整）
            let minutes = Int(ceil(Double(timeInSeconds) / 60.0))
            // 正计时模式下，设定时间保持为0（表示无限制），实际使用时间记录到usedTimeInMinutes
            todoItem.timeInMinutes = 0
            todoItem.usedTimeInMinutes = minutes
        }
    }
}

#Preview {
    NavigationStack {
        CountdownView(todoItem: .constant(TodoItem.sampleActive))
    }
}