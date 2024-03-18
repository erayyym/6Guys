//
//  ScanViewModel.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/3/17.
//

import Foundation

//store
struct Recepit {
    var id = UUID()
    var recepitId: String = ""
    var date: Date = Date()
    var totalPrice: Double = 0.0
    var recepitImage: Data? = nil

}

struct RecepitItem {
    var id = UUID()
    var category: String = ""
    var date: Date = Date()
    var name: String = ""
    var price: Double = 0.0
    var recepitId: String = ""

}
