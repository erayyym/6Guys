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
        "Food", "Drink", "Pet Supplies", "utilities", "Tuition"
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
