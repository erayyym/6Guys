//
//  PocketLedgerApp.swift
//  PocketLedger
//
//  Created by Jerry Zhou on 3/14/24.
//

import SwiftUI

@main
struct PocketLedgerApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        persistenceController.createTables()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
