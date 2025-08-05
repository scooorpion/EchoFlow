//
//  TodoItem.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import Foundation
import SwiftUI

struct TodoItem: Identifiable {
    let id = UUID()
    
    var title: String
    var iconName: String = "square" // 默认图标
    var timeInMinutes: Int? = nil
    var times: Int? = nil
    var status: Status = .none
    var isCompleted: Bool = false
    
    enum Status {
        case new, skip, done, none
    }
    
    // MARK: - 衍生属性
    
    var timeText: String? {
        if let minutes = timeInMinutes {
            return "\(minutes) min"
        }
        if let count = times {
            return "\(count) time"
        }
        return nil
    }
    
    var statusLabel: String? {
        switch status {
        case .new:
            return "★ New"
        case .skip:
            return "↩︎ Skip"
        case .done:
            return "✓ Done"
        case .none:
            return nil
        }
    }
    
    var statusColor: Color {
        switch status {
        case .new:
            return .pink
        case .skip:
            return .blue
        case .done:
            return .green
        case .none:
            return .clear
        }
    }
}
