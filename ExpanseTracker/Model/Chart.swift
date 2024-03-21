//
//  Chart.swift
//  ExpanseTracker
//
//  Created by Gytis Ptasinskas on 20/03/2024.
//

import SwiftUI

struct ChartGroup: Identifiable {
    let id: UUID = .init()
    var date: Date
    var categories: [ChartCategory]
    var totalIncome: Double
    var totalExpense: Double
}

struct ChartCategory: Identifiable {
    let id: UUID = .init()
    var totalValue: Double
    var cateogry: Category
}
