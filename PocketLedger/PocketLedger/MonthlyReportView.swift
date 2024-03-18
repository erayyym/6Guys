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
                .onChange(of: selectedDate) { _ in
                    fetchMonthlyReports()
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
}
