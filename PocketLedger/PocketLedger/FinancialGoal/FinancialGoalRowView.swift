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
    
    var body: some View {
        HStack(){
            Image(systemName: "circle")
                .resizable()
                .frame(width: 10, height: 10)
                .padding(.horizontal,12)
            VStack(){
                Text(String(format: "save $%.2f for \(goalModel.goal)", goalModel.amount))
                Text("Due: \(dueDateText)")
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

struct GoalModel {
    var id = UUID()
    var goal: String = ""
    var amount: Double = 0.0
    var date:Date = Date()
    var createDate:Date = Date()
    var achieved: Bool = false

}
