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
            Text("Hi there?")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                print("点击添加按钮")
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
            }
        }
        
//        .background(.ultraThinMaterial) // 👈 这是毛玻璃关键
//        .clipShape(RoundedRectangle(cornerRadius: 0)) // 可根据设计加圆角
//        .overlay(
//            Divider(), alignment: .bottom
//        )
    }
}
