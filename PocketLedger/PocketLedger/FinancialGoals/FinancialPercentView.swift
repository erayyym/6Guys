//
//  FinancialPercentView.swift
//  PocketLedger
//
//  Created by myr on 2024/4/20.
//

import SwiftUI

struct FinancialPercentView: View {
@State private var percent = ""
@Environment(\.presentationMode) var presentationMode
@Binding var goal: GoalModel?

var onPercentAdded: (() -> Void)?

var body: some View {
    Form {
        Section(header: Text("Set Percent")) {
            TextField("Percent", text: $percent)
                .keyboardType(.decimalPad)
        }

        Section {
            Button(action: savePercent) {
                Text("Submit")
            }
        }
    }
    .navigationBarTitle("Add Financial Percent", displayMode: .inline)
    .navigationBarItems(trailing: Button("Cancel") {
        presentationMode.wrappedValue.dismiss()
    })
}

private func savePercent() {
    guard let percentValue = Double(percent), percentValue <= 100 else {
        return
    }
    if var goal = goal {
        goal.percent = percentValue
        if Int(percentValue) == 100 {
            goal.achieved = true
        } else {
            goal.achieved = false
        }
        PersistenceController.shared.updateGoal(goal: goal) { success in
            if success {
                self.onPercentAdded?()
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Failed to update the financial goal.")
            }
        }
    }


}
}

