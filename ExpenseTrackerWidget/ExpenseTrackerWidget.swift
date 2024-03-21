//
//  ExpenseTrackerWidget.swift
//  ExpenseTrackerWidget
//
//  Created by Gytis Ptasinskas on 20/03/2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WidgetEntry] = []
        
        entries.append(.init(date: .now))

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
}

struct ExpenseTrackerWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        FilterTransactionView(startDate: .now.startofMonth, endDate: .now.endfMonth) { transactions in
            CardView(income: total(transactions, category: .income), expense: total(transactions, category: .expense))
        }
    }
}

struct ExpenseTrackerWidget: Widget {
    let kind: String = "ExpenseTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
                ExpenseTrackerWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .modelContainer(for: Transaction.self)
        }
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
        .configurationDisplayName("Expense Tracker")
        .description("Quickly glance and check your expenses")
    }
}

#Preview(as: .systemSmall) {
    ExpenseTrackerWidget()
} timeline: {
    WidgetEntry(date: .now)
}
