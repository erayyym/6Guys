//
//  FinancialGoalRowView.swift
//  PocketLedger
//
//  Created by Searen Da on 3/21/24.
//

import Foundation
import SwiftUI

struct FinancialGoalRowView: View {
    var goalModel: GoalModel
    
    @State private var daysSinceLastBudgetAction: Int?
    @State private var selectedDate = Date()
    @State private var monthlyReports: [MonthlyReport] = []
    @State private var receiptItems: [RecepitItem] = []
    
//    var body: some View {
//        VStack{
////            budgetReminderView
//            HStack() {
//                Image(systemName: "circle")
//                    .resizable()
//                    .frame(width: 10, height: 10)
//                    .padding(.horizontal,12)
//                VStack(alignment: .leading) {
//                    Text(String(format: "Spend less than $ %.2f for \(goalModel.goal)", goalModel.amount))
//                    Text(String(format: "already spent: "))
//                    Text("Due: \(dueDateText)")
//                        .font(.subheadline)
//                }
//                Spacer()
//            }
//        }
    var body: some View {
        HStack() {
            Image(systemName: goalModel.achieved ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(.horizontal, 12)
                .foregroundColor(goalModel.achieved ? .green : .blue)
            VStack(alignment: .leading) {
                if goalModel.goalType == "Fixed" {
                    Text(String(format: "Save $ %.2f for \(goalModel.goal)", goalModel.amount))
                        .font(Font.system(size: 16).weight(.bold))
                        .foregroundColor(.blue)
                    
                    if Int(goalModel.percent) > 0 {
                        Text("Percent:\(Int(goalModel.percent))%")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(.blue)
                    }
                    
                    
                    Text("Due: \(dueDateText)")
                        .font(.subheadline)
                } else if goalModel.goalType == "Percent" {
                    Text(String(format: "Save %.0f%% compared to last month", goalModel.comparedPercent))
                        .font(Font.system(size: 16).weight(.bold))
                        .foregroundColor(.blue)
                    if Int(goalModel.percent) > 0 {
                        Text("Percent:\(Int(goalModel.percent))%")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(.blue)
                    }
                } else {
                    Text(String(format: "Save $ %.2f every %.0f days", goalModel.amount, goalModel.frequency))
                        .font(Font.system(size: 16).weight(.bold))
                        .foregroundColor(.blue)
                    if Int(goalModel.percent) > 0 {
                        Text("Percent:\(Int(goalModel.percent))%")
                            .font(Font.system(size: 14).weight(.semibold))
                            .foregroundColor(.blue)
                    }
                }
                
            }
            
        }
        .onTapGesture {
        }
        .onAppear(){
            PersistenceController.shared.fetchMostRecentReceiptDate {mostRecentDate in
                DispatchQueue.main.async {
                    guard let lastActionDate = mostRecentDate else {
                        // Handle case with no receipts or error
                        self.daysSinceLastBudgetAction = nil
                        return
                    }
                    
                    let currentDate = Date()
                    let calendar = Calendar.current
                    let dateComponents = calendar.dateComponents([.day], from: lastActionDate, to: currentDate)
                    self.daysSinceLastBudgetAction = dateComponents.day
                }
            }
        }
//        .onAppear(){
//            let formattedDate = convertDateToYearMonthFormat(dueDateText: dueDateText)
//            monthlyReports = PersistenceController.shared.fetchMonthlyReports(for: dueDateText)
//            print(monthlyReports)
//            print(formattedDate)
//        }
//        .onAppear(){
//            receiptItems = PersistenceController.shared.fetchReceiptItems(for: receipt.recepitId)
//            for item in receiptItems{
//                print(item.name)
//            }
//        }
    }
    
    
    func convertDateToYearMonthFormat(dueDateText: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MMM d, yyyy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // Use a POSIX locale to ensure consistency
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX") // Use a POSIX locale here too
        
        if let date = inputFormatter.date(from: dueDateText) {
            return outputFormatter.string(from: date)
        } else {
            return nil // In case the parsing fails
        }
    }

    
    private var dueDateText: String {
        return PersistenceController.shared.dueDateText(from: goalModel.createDate)
    }
}
