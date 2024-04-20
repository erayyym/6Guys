import SwiftUI

struct SummaryItem: Identifiable {
    let id = UUID()
    var merchant: String
    var money: String
    var category: String
}

struct SummaryView: View {
    @Environment(\.dismiss) private var dismiss
    var onSubmit: (() -> Void)?
    @Binding private var recepit: Recepit
    @Binding private var receiptItems: [RecepitItem]
    @State private var date:Date = Date()
    
    init(recepit: Binding<Recepit>, receiptItems:Binding< [RecepitItem]>, onSubmit: (() -> Void)?) {
        self._recepit = recepit
        self._receiptItems = receiptItems
        self.onSubmit = onSubmit
    }
    
    func uuidToString(_ uuid: UUID) -> String {
        return uuid.uuidString
    }

    
    func submitToDB() {
        let totalPrice = receiptItems.reduce(0.0) { $0 + $1.price }
        recepit.totalPrice = totalPrice
        if self.receiptItems.isEmpty || totalPrice == 0 {
            return
        }
        recepit.date = date
        for index in 0...self.receiptItems.count - 1 {
            self.receiptItems[index].date = date
//            self.receiptItems[index].id = UUID()
        }
        
//        recepit.id = UUID()
        let newReceId = UUID()
        let newReceiptId = uuidToString(newReceId)
        let existingReceipt = PersistenceController.shared.fetchReceipt(with: newReceiptId)
            
        if existingReceipt != nil {
            // Handle the error - the UUID already exists in the database
            print("Error: Receipt with the same UUID already exists.")
            return
        } else {
            recepit.recepitId = newReceiptId
<<<<<<< Updated upstream
            print("也是直接给他submit修好了好吧老底")
=======

>>>>>>> Stashed changes
            for index in receiptItems.indices {
                // Assign a new UUID to each receipt item to ensure it is unique
                receiptItems[index].recepitId = recepit.recepitId
            }
            
            PersistenceController.shared.insertReceipt(receipt: recepit){ success in
                if success {
                    // sucess
                    print("recepit save sucess")
                    PersistenceController.shared.insertReceiptItems(items: receiptItems) { success in
                        if success {
                            // sucess
                            let all = PersistenceController.shared.fetchReceiptItems(for: recepit.recepitId)
                            print(all)
                            print("receiptItems save sucess")
                            dismiss()
                            onSubmit?()
                            
                        } else {
                            // failure
                            print("receiptItems save failure")
                        }
                    }
                    
                    
                } else {
                    // failure
                    print("recepit save failure")
                    
                }
            }
            
        }
    }
    
//    
//    @State private var items: [SummaryItem] = [
//        SummaryItem(merchant: "Pickled Cabbage", money: "24.99", category: "Food"),
//        SummaryItem(merchant: "Ribs and Frozen Tofu", money: "10.99", category: "Food"),
//        SummaryItem(merchant: "Wings", money: "10.99", category: "Food"),
//        SummaryItem(merchant: "Earphones", money: "0.99", category: "Drink")
//    ]
//
//    // Add more categories as needed
//    let categories = [
//        "Food", "Drink", "utilities", "Tuition"
//    ]

    
    var body: some View {
        NavigationView {
            List {
                ForEach($receiptItems, id: \.id) { $item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text("$\(item.price)")
                        }
                        Spacer()
                        CategoryView(category: $item.category, categories: categories)
                    }
                }
            }
            .navigationTitle("Summary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("submit") {
                        submitToDB()
                    }
                }
            }
        }
    }
}

// A subview for category with a dropdown menu
struct CategoryView: View {
    @Binding var category: String
    var categories: [String]

    var body: some View {
        Menu {
            ForEach(categories, id: \.self) { categoryOption in
                Button(categoryOption) {
                    category = categoryOption
                }
            }
        } label: {
            Label {
                Text(category)
            } icon: {
                // Change the icon as per your design
                Image(systemName: "chevron.down")
                .font(.system(size: 12))
            }
        }
        .foregroundColor(.yellow)
        .padding(4)
        .background(Color.black)
        .cornerRadius(8)
    }
}

//struct SummaryView_Previews: PreviewProvider {
//    static var previews: some View {
//        SummaryView()
//    }
//}
