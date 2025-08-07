//
//  TodoItem.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/5.
//

import Foundation
import SwiftUI

struct TodoItem: Identifiable {
    
    // MARK: - Basic Setting
    let id = UUID()
    var title: String
    var timeInMinutes: Int? = nil
    var description: String? = ""
    var notes: String = ""
    
    // MARK: - Date Set
    var isAllDay: Bool = false
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    
    
    // MARK: - 拓展属性
    var isCompleted: Bool = false
    
    var timeText: String? {
        if let minutes = timeInMinutes {
            return "\(minutes) min"
        }
        return nil
    }

}
