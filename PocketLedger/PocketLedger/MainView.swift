import SwiftUI

struct MainView: View {
    @State private var recentGoals: [GoalModel] = []
    @State private var recentReceipts: [Recepit] = []
//    @Binding var selection:Int
    @State private var receiptItems: [RecepitItem] = []
    @State private var daysSinceLastBudgetAction: Int?
    @State private var hasgoal: Bool?
    
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
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    NavigationLink(destination: MonthlyReportView()) {
                        Text("Month Report")
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity,maxHeight: 80 ,alignment: .center)
                    }
                    Spacer()
                }
                
                
                // financial goals
                Section(header:
                    HStack {
                        NavigationLink(destination: FinancialGoalView()) {
                            Text("Financial goals")
                                .font(.headline)
                            Image(systemName: "plus")
                                            .foregroundColor(.blue)
                                            .padding()
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                )
                {
                }
                
                NavigationLink(destination: ScanView()) {
                    Text("Scan")
                        .foregroundColor(.blue)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
                }
                .padding()
                
                Spacer()
                if self.hasgoal ?? false{
                    budgetReminderView
                }
                
                Section(header:
                    HStack {
                        NavigationLink(destination: HistoryView()) {
                            Text("Receipts")
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowInsets(EdgeInsets())
                ) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(recentReceipts, id: \.id) { receipt in
                                NavigationLink(destination: ReceiptView(receipt: receipt)) {
                                    ReceiptItemView(receipt: receipt)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("PocketLedger", displayMode: .inline)
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
                PersistenceController.shared.hasAnyGoals{ exist in
                    if exist{
                        self.hasgoal = true
                    }else{
                        self.hasgoal = false
                    }
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
