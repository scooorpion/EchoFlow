//
//  Item.swift
//  EchoFlow
//
//  Created by scooorpion on 2025/8/2.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
