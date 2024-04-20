//
//  FinancialGoalView.swift
//  PocketLedger
//
//  Created by Searen Da on 3/21/24.
//

import SwiftUI

struct FinancialGoalView: View {
    @State private var goals: [GoalModel] = []
    @State private var receiptItems: [RecepitItem] = []
    @State private var daysSinceLastBudgetAction: Int?
//    let receipt: Recepit
    
//    var budgetReminderView: some View {
//        Group {
//            if let days = daysSinceLastBudgetAction {
//                if days < 1{
//                    Text("You've been keeping your budgetting! Nice job!!")
//                        .foregroundColor(.primary)
//                        .font(.headline)
//                        .padding()
//                        .background(Color.gray)
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.gray, lineWidth: 2)
//                        )
//                        .padding(.horizontal)
//                }
//                else{
//                    Text("You have not done budgeting in \(days) days.")
//                        .foregroundColor(.white)
//                        .font(.headline)
//                        .padding()
//                        .background(Color.red)
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.red, lineWidth: 2)
//                        )
//                        .padding(.horizontal)
//                }
//             }
//            else{
//                Text("Lets start budgetting!")
//                    .foregroundColor(.blue)
//                    .font(.headline)
//                    .padding()
//                    .background(Color.clear)
//                    .cornerRadius(10)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.blue, lineWidth: 2)
//                    )
//                    .padding(.horizontal)
//            }
//        }
//    }

    var body: some View {
            List {
                ForEach(goals, id: \.id) { goalModel in
                    FinancialGoalRowView(goalModel: goalModel)
                }
                .onDelete(perform: deleteGoals)
            }
            .navigationBarTitle("Financial Goals")
            .navigationBarItems(trailing:
                NavigationLink(destination: AddFinancialGoalView(onGoalAdded: {
                fetchGoals()
            })) {
                    Image(systemName: "plus")
                }
            )
            .onAppear {
                fetchGoals()
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
        }

    private func fetchGoals() {
        PersistenceController.shared.fetchGoals { models in
            self.goals = models
        }
    }

    private func deleteGoals(at offsets: IndexSet) {
        for index in offsets {
            let goal = goals[index]
            PersistenceController.shared.deleteGoal(goalId: goal.id.uuidString) { success in
                if success {
                    self.goals.remove(at: index)
                } else {
                    print("Failed to delete goal with ID: \(goal.id)")
                }
            }
        }
    }

}
