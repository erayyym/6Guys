//
//  HistoryView.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/3/21.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @State private var groupedReceipts: [(String, [Recepit])] = []
    
    var body: some View {
        List {
            ForEach(groupedReceipts, id: \.0) { section in
                Section(header: Text("\(section.0)")) {
                    ForEach(section.1) { receipt in
                        NavigationLink(destination: ReceiptView(receipt: receipt)) {
                            HStack {
                                if let imageData = receipt.recepitImage,  let uiImage = UIImage(data: imageData)  {
                                    
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                    
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                    
                                }
                                
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text(receipt.formattedDate)
                                    Text(String(format: "$%.2f", receipt.totalPrice))
                                        .font(.headline)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                    
                    .onDelete { indexSet in
                        for index in indexSet {
                            let recepit = section.1[index]
                            PersistenceController.shared.deleteReceiptAndItems(for: recepit.recepitId)
                                                            loadData()
                        }
                    }
                }
                
            }
            .navigationBarTitle("Recepits", displayMode: .inline)
            
        }
        .onAppear() {
                    loadData()
        }
        
    }
    func loadData() {
        let receiptsGroupedByMonth = PersistenceController.shared.fetchReceiptsGroupedByMonth()
        groupedReceipts = receiptsGroupedByMonth.map { $0 }
    }
    
}
