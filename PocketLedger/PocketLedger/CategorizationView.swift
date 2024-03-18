import SwiftUI

struct SummaryItem: Identifiable {
    let id = UUID()
    var merchant: String
    var money: String
    var category: String
}

struct SummaryView: View {
    @Binding private var recepit: Recepit
    @Binding private var receiptItems: [RecepitItem]
    
    init(recepit: Binding<Recepit>, receiptItems:Binding< [RecepitItem]>) {
        self._recepit = recepit
        self._receiptItems = receiptItems
    }
    
    
    @State private var items: [SummaryItem] = [
        SummaryItem(merchant: "Pickled Cabbage", money: "24.99", category: "Food"),
        SummaryItem(merchant: "Ribs and Frozen Tofu", money: "10.99", category: "Food"),
        SummaryItem(merchant: "Wings", money: "10.99", category: "Food"),
        SummaryItem(merchant: "Earphones", money: "0.99", category: "Drink")
    ]

    // Add more categories as needed
    let categories = [
        "Food",
        "Drink",
        "Electronics",
        "Clothing",
        "Mortgage or Rent",
        "Property Taxes",
        "Home Insurance",
        "Maintenance and Repairs",
        "Utilities (electricity, water, sewage, gas)",
        "Car Payment",
        "Auto Insurance",
        "Fuel",
        "Public Transportation",
        "Groceries",
        "Dining Out",
        "Snacks and Coffee",
        "Health Insurance",
        "Out-of-Pocket Medical Expenses",
        "Personal Care Items",
        "Childcare",
        "Child Support or Alimony",
        "Pet Care",
        "Credit Card Payments",
        "Student Loans",
        "Personal Loans",
        "Emergency Fund",
        "Retirement Savings (401(k), IRA)",
        "College Savings",
        "Investment Accounts",
        "Streaming Services",
        "Hobbies",
        "Sports and Fitness",
        "Vacations and Travel",
        "Tuition",
        "Books and Supplies",
        "Online Courses",
        "Clothes",
        "Shoes",
        "Accessories",
        "Charitable Donations",
        "Gifts for Holidays and Special Occasions",
        "Bank Fees",
        "Postage and Shipping",
        "Technology Upgrades (phones, laptops)",
        "Subscription Services"
    ]

    
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
                Button("Confirm") {
                    // Handle the confirm action here
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
        .foregroundColor(.white)
        .padding(4)
        .background(Color.green)
        .cornerRadius(8)
    }
}

//struct SummaryView_Previews: PreviewProvider {
//    static var previews: some View {
//        SummaryView()
//    }
//}
