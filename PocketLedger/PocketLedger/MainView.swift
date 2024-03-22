import SwiftUI

struct MainView: View {
    @State private var recentGoals: [GoalModel] = []
    @State private var recentReceipts: [Recepit] = []

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
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ) {
//                    ForEach(recentGoals, id: \.id) { goalModel in
//                        FinancialGoalRowView(goalModel: goalModel)
//                       }
                }
                
//                // Set financial goal with a clickable button
//                Section(header:
//                    HStack {
//                        Text("Set Financial Goals:")
//                            .font(.headline)
//                        Spacer()
//                        Button(action: {
//                            
//                        }) {
//                            Image(systemName: "plus.circle.fill") // Using SF Symbols for the button icon
//                                .foregroundColor(.black)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                ) {
//                    ForEach(recentGoals, id: \.id) { goalModel in
//                        FinancialGoalRowView(goalModel: goalModel)
//                    }
//                }
                
                NavigationLink(destination: ScanView()) {
                    Text("Scan")
                        .foregroundColor(.blue)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
                }
                .padding()
                
                Spacer()
                
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
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
