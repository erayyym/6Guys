//
//  MonthlyReviewView.swift
//  PocketLedger
//
//  Created by 倪达辰 on 18/3/24.
//

import Foundation
import SwiftUI

struct MonthlyReportView: View {
    @State private var selectedDate = Date()
    @State private var monthlyReports: [MonthlyReport] = []
    
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
                .onAppear() {
                    fetchMonthlyReports()
                }
                .onChange(of: selectedDate) { _ in
                    fetchMonthlyReports()
                }
            
            if !monthlyReports.isEmpty {
                Text("Month: \(formattedMonth(from: selectedDate))")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                let data = convertToChartData(monthlyReports)
                BarChart(categories: data)
                    .frame(height: 250)
                    .padding(.horizontal)
                    .id(UUID())
            } else {
                Text("No data available")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    func fetchMonthlyReports() {
        let formattedDate = formattedMonth(from: selectedDate)
        monthlyReports = PersistenceController.shared.fetchMonthlyReports(for: formattedDate)
    }
    
    func formattedMonth(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter.string(from: date)
    }
    
    func convertToChartData(_ reports: [MonthlyReport]) -> [String: Double] {
        var data: [String: Double] = [:]
        for report in reports {
            for (category, total) in report.categoryTotals {
                data[category, default: 0] += total
            }
        }
        return data
    }
}
