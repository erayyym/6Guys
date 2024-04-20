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
//    let receipt: Recepit
    
    var budgetReminderView: some View {
        Group {
            if let days = daysSinceLastBudgetAction {
                if days < 1{
                    Text("You've been keeping your budgetting! Nice job!!")
                        .foregroundColor(.primary)
                        .font(.headline)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .padding(.horizontal)
                }
                else{
                    Text("You have not done budgeting in \(days) days.")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        )
                        .padding(.horizontal)
                }
             }
            else{
                Text("Lets start budgetting!")
                    .foregroundColor(.blue)
                    .font(.headline)
                    .padding()
                    .background(Color.clear)
                    .cornerRadius(10) 
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .padding(.horizontal)
            }
        }
    }
    
    var body: some View {
        budgetReminderView
        
        HStack() {
            Image(systemName: "circle")
                .resizable()
                .frame(width: 10, height: 10)
                .padding(.horizontal,12)
            VStack(alignment: .leading) {
                Text(String(format: "Spend less than $ %.2f for \(goalModel.goal)", goalModel.amount))
                Text(String(format: "already spent: "))
                Text("Due: \(dueDateText)")
                    .font(.subheadline)
            }
            Spacer()
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
        .onAppear(){
            let formattedDate = convertDateToYearMonthFormat(dueDateText: dueDateText)
            monthlyReports = PersistenceController.shared.fetchMonthlyReports(for: dueDateText)
            print(monthlyReports)
            print(formattedDate)
        }
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
