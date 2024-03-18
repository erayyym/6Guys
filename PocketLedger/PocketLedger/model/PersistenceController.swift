//
//  Persistentcontroller.swift
//  PocketLedger
//
//  Created by 倪达辰 on 18/3/24.
//

import Foundation
import SQLite3

let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

class PersistenceController {
    static let shared = PersistenceController()
    
    
    private let createReceiptsTableQuery = """
          CREATE TABLE IF NOT EXISTS Receipts (
              recepitId TEXT PRIMARY KEY,
              date TEXT,
              totalPrice REAL,
              recepitImage BLOB
          );
      """
      
      private let createReceiptItemsTableQuery = """
          CREATE TABLE IF NOT EXISTS ReceiptItems (
              itemId INTEGER PRIMARY KEY AUTOINCREMENT,
              recepitId TEXT,
              name TEXT,
              category TEXT,
              price REAL,
              FOREIGN KEY(recepitId) REFERENCES Receipts(recepitId)
          );
      """
    
    private lazy var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter
        }()
    
    func createTables() {
        if executeQuery(query: createReceiptsTableQuery) {
            print("Receipts table created successfully")
        } else {
            print("Error creating Receipts table")
        }
        
        if executeQuery(query: createReceiptItemsTableQuery) {
            print("ReceiptItems table created successfully")
        } else {
            print("Error creating ReceiptItems table")
        }
    }
    
    init() {
        openDatabase()
        createTables()
    }
    
    private var db: OpaquePointer?
    
    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("recepit.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
    }
    
    func executeQuery(query: String) -> Bool {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            } else {
                print("Error executing query")
                return false
            }
        } else {
            print("Error preparing query")
            return false
        }
    }
    
    func fetchQuery(query: String) -> [[String: String]] {
        var result = [[String: String]]()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var row = [String: String]()
                for i in 0..<sqlite3_column_count(statement) {
                    let columnName = String(cString: sqlite3_column_name(statement, i))
                    let columnText = String(cString: sqlite3_column_text(statement, i))
                    row[columnName] = columnText
                }
                result.append(row)
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing query")
        }
        
        return result
    }
    
    deinit {
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
    }
    
    func insertReceipt(receipt: Recepit, completion: @escaping (Bool) -> Void) {
        let query = """
            INSERT INTO Receipts (recepitId, date, totalPrice, recepitImage)
            VALUES (?, ?, ?, ?);
        """
        
        let dateString = dateFormatter.string(from: receipt.date)
        
        var base64ImageString: String?
        if let imageData = receipt.recepitImage {
            base64ImageString = imageData.base64EncodedString()
        }
        
        completion(executeQueryWithParams(query: query, params: [receipt.recepitId, dateString, receipt.totalPrice, base64ImageString]))
    }


    func insertReceiptItem(item: RecepitItem, completion: @escaping (Bool) -> Void) {
        let query = """
            INSERT INTO ReceiptItems (recepitId, name, category, price)
            VALUES (?, ?, ?, ?);
        """
        
        completion(executeQueryWithParams(query: query, params: [item.recepitId, item.name, item.category, item.price]))
    }
    
    func insertReceiptItems(items: [RecepitItem], completion: @escaping (Bool) -> Void) {
        let query = """
            INSERT INTO ReceiptItems (recepitId, name, category, price)
            VALUES (?, ?, ?, ?);
        """
        
        var success = true
        
        for item in items {
            success = executeQueryWithParams(query: query, params: [item.recepitId, item.name, item.category, item.price])
            
            if !success {
                break
            }
        }
        
        completion(success)
    }

        
        private func executeQueryWithParams(query: String, params: [Any?]) -> Bool {
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                for (index, param) in params.enumerated() {
                    if let text = param as? String {
                        sqlite3_bind_text(statement, Int32(index + 1), text, -1, SQLITE_TRANSIENT)
                    } else if let real = param as? Double {
                        sqlite3_bind_double(statement, Int32(index + 1), real)
                    } else if let blob = param as? Data {
                        blob.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                            sqlite3_bind_blob(statement, Int32(index + 1), bytes.baseAddress, Int32(bytes.count), SQLITE_TRANSIENT)
                        }
                    } else if param == nil {
                        sqlite3_bind_null(statement, Int32(index + 1))
                    }
                }
                if sqlite3_step(statement) == SQLITE_DONE {
                    sqlite3_finalize(statement)
                    return true
                } else {
                    print("Error executing query")
                    return false
                }
            } else {
                print("Error preparing query")
                return false
            }
        }
    
    func fetchAllReceipts() -> [Recepit] {
        let query = "SELECT * FROM Receipts;"
        let rows = fetchQuery(query: query)
        var receipts = [Recepit]()
        for row in rows {
            if let recepitId = row["recepitId"],
               let dateString = row["date"],
               let totalPriceString = row["totalPrice"],
               let totalPrice = Double(totalPriceString),
               let base64String = row["recepitImage"],
               let imageData = Data(base64Encoded: base64String) {
                
                var receipt = Recepit(recepitId: recepitId,
                                      date: dateFormatter.date(from: dateString) ?? Date(),
                                      totalPrice: totalPrice)
                receipt.recepitImage = imageData
                receipts.append(receipt)
            }
        }
        return receipts
    }


        func fetchReceiptItems(for recepitId: String) -> [RecepitItem] {
            let query = "SELECT * FROM ReceiptItems WHERE recepitId = '\(recepitId)';"
            let rows = fetchQuery(query: query)
            var receiptItems = [RecepitItem]()
            for row in rows {
                if let name = row["name"],
                   let category = row["category"],
                   let priceString = row["price"],
                   let price = Double(priceString) {
                    let receiptItem = RecepitItem(category: category, name: name, price: price, recepitId: recepitId)
                    receiptItems.append(receiptItem)
                }
            }
            return receiptItems
        }

        func deleteReceiptAndItems(for recepitId: String) {
            let deleteReceiptQuery = "DELETE FROM Receipts WHERE recepitId = '\(recepitId)';"
            let deleteReceiptItemsQuery = "DELETE FROM ReceiptItems WHERE recepitId = '\(recepitId)';"
            
            executeQuery(query: deleteReceiptItemsQuery)
            executeQuery(query: deleteReceiptQuery)
        }
    
    func fetchReceiptsGroupedByMonth() -> [String: [Recepit]] {
        let query = """
            SELECT *
            FROM Receipts;
            """
        
        let rows = fetchQuery(query: query)
        var receiptsGroupedByMonth = [String: [Recepit]]()
        
        for row in rows {
            if let recepitId = row["recepitId"],
               let dateString = row["date"],
               let totalPriceString = row["totalPrice"],
               let totalPrice = Double(totalPriceString),
               let base64String = row["recepitImage"],
               let imageData = Data(base64Encoded: base64String) {
                
                let date = dateFormatter.date(from: dateString) ?? Date()
                let monthYear = monthYearString(from: date)
                
                var receipt = Recepit(recepitId: recepitId,
                                      date: date,
                                      totalPrice: totalPrice)
                receipt.recepitImage = imageData
                
                if var receiptsForMonth = receiptsGroupedByMonth[monthYear] {
                    receiptsForMonth.append(receipt)
                    receiptsGroupedByMonth[monthYear] = receiptsForMonth
                } else {
                    receiptsGroupedByMonth[monthYear] = [receipt]
                }
            }
        }
        
        return receiptsGroupedByMonth
    }

    private func monthYearString(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let year = components.year, let month = components.month else {
            return ""
        }
        return "\(year)-\(String(format: "%02d", month))"
    }
    
    func totalAmountForAllReceipts() -> Double {
           let receipts = fetchAllReceipts()
           return receipts.reduce(0.0) { $0 + $1.totalPrice }
       }
    
    func fetchMonthlyReports(for dateString: String) -> [MonthlyReport] {
        let query = """
            SELECT strftime('%Y-%m', date) AS month, category, SUM(price) AS total
            FROM Receipts AS r
            JOIN ReceiptItems AS ri ON r.recepitId = ri.recepitId
            WHERE strftime('%Y-%m', date) = '\(dateString)'
            GROUP BY month, category
            ORDER BY month;
        """
        
        let rows = fetchQuery(query: query)
        var monthlyReports = [MonthlyReport]()
        
        var currentMonth = ""
        var categoryTotals = [String: Double]()
        
        for row in rows {
            if let month = row["month"],
               let category = row["category"],
               let totalString = row["total"],
               let total = Double(totalString) {
                
                if month != currentMonth {
                    if !categoryTotals.isEmpty {
                        monthlyReports.append(MonthlyReport(month: currentMonth, categoryTotals: categoryTotals))
                    }
                    currentMonth = month
                    categoryTotals = [String: Double]()
                }
                
                categoryTotals[category] = total
            }
        }
        
        if !categoryTotals.isEmpty {
            monthlyReports.append(MonthlyReport(month: currentMonth, categoryTotals: categoryTotals))
        }
        
        return monthlyReports
    }


}
