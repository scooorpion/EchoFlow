//
//  HeaderView.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/6.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("待办事项")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                print("点击添加按钮")
            }) {
                Image(systemName: "plus") // 使用纯粹的加号，更符合原生设计
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        // 1. 【关键点】为内容添加水平和底部边距，以确保它们在视觉上舒适
        // 注意：我们不需要加 .padding(.top)，因为 safeAreaInset 会自动处理
        .padding(.horizontal)
        .padding(.bottom, 10)
        
        // 2. 【关键点】添加背景。这里我们不直接用VStack包裹，而是使用 .background 修饰符
        // .frame(maxWidth: .infinity) 确保背景能横向撑满
        // .background(.ultraThinMaterial) 是实现苹果原生模糊效果的关键
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}


#Preview {
    HeaderView()
}
