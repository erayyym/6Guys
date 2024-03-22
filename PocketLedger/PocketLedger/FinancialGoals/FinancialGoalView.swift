//
//  FinancialGoalView.swift
//  PocketLedger
//
//  Created by Searen Da on 3/21/24.
//

import SwiftUI

struct FinancialGoalView: View {
    @State private var goals: [GoalModel] = []

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
