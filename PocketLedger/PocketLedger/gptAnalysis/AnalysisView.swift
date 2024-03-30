//
//  AnalysisView.swift
//  PocketLedger
//
//  Created by Jerry Zhou on 3/14/24.
//

import SwiftUI

struct BarChartView: View {
    var totalByCategory: [String: Double]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                ForEach(totalByCategory.keys.sorted(), id: \.self) { key in
                    BarView(category: key, total: totalByCategory[key] ?? 0, maxWidth: geometry.size.width)
                }
            }
        }
    }
}

struct BarView: View {
    var category: String
    var total: Double
    var maxWidth: CGFloat
    
    var body: some View {
        HStack {
            Text(category)
                .frame(width: 100, alignment: .leading)
            
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.blue)
                .frame(width: CGFloat(total) / CGFloat(maxTotal()) * (maxWidth - 100), height: 20) // Subtract 100 for the label width
            
            Spacer()
            
            Text(String(format: "$%.2f", total))
        }
    }
    
    func maxTotal() -> Double {
        return 100
    }
}

struct CalendarView: View {
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        VStack {
            Text("Select Date").font(.headline)
            
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .frame(maxHeight: 400)
            
            Text("Selected date: \(selectedDate, formatter: dateFormatter)")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
}

struct AnalysisView: View {
    var items: [SummaryItem]

    // Computed property to calculate the total expenses for each category.
    private var totalByCategory: [String: Double] {
        Dictionary(grouping: items, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + (Double($1.money) ?? 0) } }
    }

    // AI Analysis based on the total expenses
    private var aiAnalysisMessage: String {
        let totalExpenses = totalByCategory.values.reduce(0, +)
        // Define the threshold for "too much" as an example, adjust as needed
        let threshold = 1000.0
        if totalExpenses > threshold {
            return "You've spent too much this month."
        } else {
            return "Your spending is within a reasonable range."
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Monthly Report").font(.title)

                BarChartView(totalByCategory: totalByCategory)
                    .frame(height: 300) // Adjust the height as needed

                // AI analysis message view
                Text(aiAnalysisMessage)
                    .font(.headline)
                    .padding()

                Divider()

                CalendarView() 
            }
        }
        .padding()
    }
}

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView(items: [
            SummaryItem(merchant: "Pickled Cabbage", money: "24.99", category: "Food"),
            SummaryItem(merchant: "Ribs and Frozen Tofu", money: "10.99", category: "Food"),
            SummaryItem(merchant: "Coke", money: "10.99", category: "Drink"),
            SummaryItem(merchant: "Earphones", money: "0.99", category: "Electronics")
        ])
    }
}
