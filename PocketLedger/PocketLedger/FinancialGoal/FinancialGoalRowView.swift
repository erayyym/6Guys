//
//  FinancialGoalRowView.swift
//  PocketLedger
//
//  Created by Searen Da on 3/21/24.
//

import Foundation

struct FinancialGoalRowView:View{
    var goalModel: GoalModel
    
    var body: some View(){
        HStack(){
            Image(systemName: "circle")
                .resizable()
                .frame(width: 10, height: 10)
                .padding(.horizontal,12)
            VStack(){
                Text(string(format: "save $%.2f for \(goalModel.goal)", goalModel.amount))
                Text("Due: \(dueDatetext)")
                    .font(.subheadline)
            }
            Spacer()
        }
        .onTapGesture{
            
        }
    }
    
    var dueDateText: String {
        return PersistenceController.shared.dueDateText(from: goalModel.createDate)
    }
}
