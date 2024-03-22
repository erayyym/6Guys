//
//  AddFinancialGoalView.swift
//  PocketLedger
//
//  Created by Searen Da on 3/21/24.
//

import SwiftUI

struct AddFinancialGoalView: View {
    @State private var goal = ""
    @State private var amount = ""
    @State private var selectedDate = Date()
    @Environment(\.presentationMode) var presentationMode
    var onGoalAdded: (() -> Void)? 

    var body: some View {
        Form {
            Section(header: Text("Set Goal")) {
                TextField("Goal", text: $goal)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Due Date", selection: $selectedDate, displayedComponents: .date)
            }
            
            Section {
                Button(action: saveGoal) {
                    Text("Submit")
                }
            }
        }
        .navigationBarTitle("Add Financial Goal", displayMode: .inline)
        .navigationBarItems(trailing: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    private func saveGoal() {
        guard let amount = Double(amount) else {
            return
        }
        
        let newGoal = GoalModel(goal: goal, amount: amount, date: selectedDate, createDate: Date())
        PersistenceController.shared.insertGoal(goal: newGoal) { success in
            if success {
                self.onGoalAdded?()
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Failed to save the financial goal.")
            }
        }
    }

}
