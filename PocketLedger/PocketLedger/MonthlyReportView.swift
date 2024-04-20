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
    @State private var report: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                Text(report)
                    .padding()
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
        }
        .navigationBarTitle("Recepit report", displayMode: .inline)
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
        .padding(.horizontal, 12)
        .onAppear {
            fetchMonthlyReports()
            generateRepotAnalyse(data: fetchPastThreeMonthsData() ?? "") { result in
                report = result
            }
        }
        .onChange(of: selectedDate) { _ in
            fetchMonthlyReports()
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
    
    func fetchPastThreeMonthsData() -> String? {
        var pastThreeMonthsData: [String: [String: Double]] = [:]

        let currentDate = Date()

        let calendar = Calendar.current
        let pastThreeMonthsRange = calendar.date(byAdding: .month, value: -3, to: currentDate)! ..< currentDate

        var date = pastThreeMonthsRange.lowerBound
        while date < pastThreeMonthsRange.upperBound {
            let formattedMonthString = formattedMonth(from: date)
            
            let reports = PersistenceController.shared.fetchMonthlyReports(for: formattedMonthString)
            let chartData = convertToChartData(reports)
            pastThreeMonthsData[formattedMonthString] = chartData
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: pastThreeMonthsData, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                print("Failed to convert JSON data to string.")
                return nil
            }
        } catch {
            print("Error serializing JSON:", error)
            return nil
        }
    }
    
    private func generateRepotAnalyse(data: String, completion: @escaping (String) -> Void) {
        let question = "Input: \(data), Objective: Predict next month's expenditure amount (provide number), and generate a brief analysis statement on the spending trend on each category, including which category of expenditure is the highest, which category is the lowest, and the prediction for next month's expenditure. Please output a brief analysis report directly.No need for analysis process."
        
        let openAI = OpenAI()
        openAI.ask(question: question) { (answer) in
            if let answer = answer {
                print(answer)

                completion(answer)
            } else {
                completion("")
            }
        }
    }
}
