import SwiftUI

struct MainView: View {
    @State private var recentGoals: [GoalModel] = []
    
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
                
                // Set financial goal with a clickable button
                Section(header:
                    HStack {
                        Text("Set Financial Goals:")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            // Action for your button
                            // e.g., navigate to a new view or present a modal
                        }) {
                            Image(systemName: "plus.circle.fill") // Using SF Symbols for the button icon
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ) {
                    ForEach(recentGoals, id: \.id) { goalModel in
                        FinancialGoalRowView(goalModel: goalModel)
                    }
                }
                
                NavigationLink(destination: ScanView()) {
                    Text("Scan")
                        .foregroundColor(.blue)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
                }
                .padding()
                
                Spacer()
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
