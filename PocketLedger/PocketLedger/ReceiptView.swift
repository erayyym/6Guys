//
//  ReceiptView.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/3/21.
//

import Foundation
import SwiftUI

struct ReceiptView: View {
    var receipt: Recepit {
        didSet {
            receiptItems = PersistenceController.shared.fetchReceiptItems(for: receipt.recepitId)
        }
    }
    @State private var receiptItems: [RecepitItem] = []

    @State var image: UIImage?
    
    var body: some View {
        ScrollView {
            VStack {
                if let imageData = receipt.recepitImage,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                }
                
                if !receiptItems.isEmpty {
                    Section(header:
                                HStack {
                        Text("Name")
                        Spacer()
                        Text("Cost")
                    }
                    ) {
                        ForEach(receiptItems.indices, id: \.self) { index in
                            HStack {
                                TextField("Name", text: Binding<String>(
                                    get: {
                                        return self.receiptItems[index].name
                                    },
                                    set: { newValue in
                                        self.receiptItems[index].name = newValue
                                    }
                                ))
                                .disabled(true)
                                .frame(maxWidth: .infinity)
                                
                                HStack {
                                    Text("$")
                                    TextField("Cost", text: Binding<String>(
                                        get: {
                                            return String(format: "%.2f", self.receiptItems[index].price)
                                        },
                                        set: { newValue in
                                            if let newValue = Double(newValue) {
                                                self.receiptItems[index].price = newValue
                                            }
                                            
                                        }
                                    ))
                                    .disabled(true)
                                    .frame(maxWidth: 60)
                                }
                            }
                        }
                        
                    }
                    
                    .padding()
                } else {
                    Text("No items found.")
                        .foregroundColor(.gray)
                }
                
            }
            .navigationBarTitle("Recepit detail", displayMode: .inline)

        }
        
        .onAppear() {
            receiptItems = PersistenceController.shared.fetchReceiptItems(for: receipt.recepitId)
        }
        
    }
}
