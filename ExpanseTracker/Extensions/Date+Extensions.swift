//
//  Date+Extensions.swift
//  ExpanseTracker
//
//  Created by Gytis Ptasinskas on 05/03/2024.
//

import SwiftUI

extension Date {
    var startofMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return calendar.date(from: components) ?? self
    }
    
    var endfMonth: Date {
        let calendar = Calendar.current
        
        return calendar.date(byAdding: .init(month: 1, minute: -1), to: self.startofMonth) ?? self
    }
}
