//
//  ScanViewModel.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/3/17.
//

import Foundation

//store

struct Recepit: Identifiable {
    var id = UUID()
    var recepitId: String = ""
    var date: Date = Date()
    var totalPrice: Double = 0.0
    var recepitImage: Data? = nil

}
extension Recepit {
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Format date as needed
        return dateFormatter.string(from: self.date)
    }
}
struct RecepitItem {
    var id = UUID()
    var category: String = ""
    var date: Date = Date()
    var name: String = ""
    var price: Double = 0.0
    var recepitId: String = ""

}
