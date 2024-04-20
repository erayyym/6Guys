//
//  AddFinancialGoalView.swift
//  PocketLedger
//
//  Created by Searen Da on 3/21/24.
//

import SwiftUI

//struct AddFinancialGoalView: View {
//    @State private var goal = ""
//    @State private var amount = ""
//    @State private var selectedDate = Date()
//    @Environment(\.presentationMode) var presentationMode
//    var onGoalAdded: (() -> Void)? 
//
//    var body: some View {
//        Form {
//            Section(header: Text("Set Goal")) {
//                TextField("Goal", text: $goal)
//                TextField("Amount", text: $amount)
//                    .keyboardType(.decimalPad)
//                DatePicker("Due Date", selection: $selectedDate, displayedComponents: .date)
//            }
//            
//            Section {
//                Button(action: saveGoal) {
//                    Text("Submit")
//                }
//            }
//        }
//        .navigationBarTitle("Add Financial Goal", displayMode: .inline)
//        .navigationBarItems(trailing: Button("Cancel") {
//            presentationMode.wrappedValue.dismiss()
//        })
//    }
//    
//    private func saveGoal() {
//        guard let amount = Double(amount) else {
//            return
//        }
//        
//        let newGoal = GoalModel(goal: goal, amount: amount, date: selectedDate, createDate: Date())
//        PersistenceController.shared.insertGoal(goal: newGoal) { success in
//            if success {
//                self.onGoalAdded?()
//                presentationMode.wrappedValue.dismiss()
//            } else {
//                print("Failed to save the financial goal.")
//            }
//        }
//    }
//
//}
struct AddFinancialGoalView: View {
    @Binding var goalType: String
    
    @State private var goal = ""
    @State private var amount = ""
    @State private var selectedDate = Date()
    
    @State private var percent = ""
    @State private var frequency = ""
    
    @Environment(\.presentationMode) var presentationMode
    var onGoalAdded: (() -> Void)?
    
    var body: some View {
        Form {
            if goalType == "Fixed" {
                Section(header: Text("Set Goal")) {
                    TextField("Goal", text: $goal)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Due Date", selection: $selectedDate, displayedComponents: .date)
                }
            } else if goalType == "Percent" {
                Section(header: Text("Set Goal (How much money (%) you want to save compared to last month?)")) {
                    TextField("Percent", text: $percent)
                        .keyboardType(.decimalPad)
                }
            } else if goalType == "Frequency" {
                Section(header: Text("Set Goal")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("every few days", text: $frequency)
                        .keyboardType(.decimalPad)
                }
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
        var newGoal:GoalModel
        if goalType == "Fixed"  {
            guard let amount = Double(amount) else {
                return
            }
            newGoal = GoalModel(goal: goal, amount: amount, date: selectedDate, createDate: Date(), goalType: goalType)
        }
        
        else if goalType == "Percent"  {
            guard let percentValue = Double(percent) else {
                return
            }
            newGoal = GoalModel(createDate: Date(), goalType: goalType, comparedPercent: percentValue)
        }
        
        else if goalType == "Frequency"  {
            guard let amount = Double(amount) else {
                return
            }
            guard let frequencyValue = Double(frequency) else {
                return
            }
            newGoal = GoalModel(amount: amount, createDate: Date(), goalType: goalType,  frequency: frequencyValue)
        } else {
            newGoal = GoalModel()
        }
        
        
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
