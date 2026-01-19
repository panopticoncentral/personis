//
//  Item.swift
//  Personae
//
//  Created by Paul Vick on 1/19/26.
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
