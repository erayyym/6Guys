//
//  ReceiptItemView.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/3/21.
//

import Foundation
import SwiftUI

struct ReceiptItemView: View {
    let receipt: Recepit
    
    var body: some View {
        VStack {
            if let imageData = receipt.recepitImage,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.gray)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text("No Image Available")
                                            .foregroundColor(.white)
                                    )
            }
            
            Text(String(format: "$%.2f", receipt.totalPrice))
                .font(.headline)
        }
    }
}
