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
    
    private let createFinancialTableQuery = """
        CREATE TABLE Goals (
            id TEXT PRIMARY KEY,
            goal TEXT,
            amount REAL,
            date TEXT,
            createDate TEXT,
            achieved INTEGER,
            percent REAL,
            goalType TEXT,
            comparedPercent REAL,
            frequency REAL
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
        
        if executeQuery(query: createFinancialTableQuery) {
            print("Financial table created successfully")
        } else {
//            executeQuery(query: "Drop table Goals;")
//            executeQuery(query: createFinancialTableQuery)
            print("Error creating Financial Goals table")
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
//                    let columnText = String(cString: sqlite3_column_text(statement, i))
                    var columnText = " "
                    if i==5 {
                        if let cString = sqlite3_column_text(statement, i) {
                            columnText = String(cString: cString)
                        } else {
                            columnText = "0" // Assign a default value or handle this case as needed
                        }
                    } else {
                        columnText = String(cString: sqlite3_column_text(statement, i))
                    }
                    


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
//            print(item)
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
//    private func executeQueryWithParams(query: String, params: [Any?]) -> Bool {
//        var statement: OpaquePointer?
//        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
//            print("Error preparing query: \(String(cString: sqlite3_errmsg(db)))")
//            return false
//        }
//
//        for (index, param) in params.enumerated() {
//            let idx = Int32(index + 1)
//            let bindResult: Int32
//            switch param {
//            case let text as String:
//                bindResult = sqlite3_bind_text(statement, idx, text, -1, SQLITE_TRANSIENT)
//            case let real as Double:
//                bindResult = sqlite3_bind_double(statement, idx, real)
//            case let blob as Data:
//                bindResult = blob.withUnsafeBytes { bytes in
//                    sqlite3_bind_blob(statement, idx, bytes.baseAddress, Int32(bytes.count), SQLITE_TRANSIENT)
//                }
//            case nil:
//                bindResult = sqlite3_bind_null(statement, idx)
//            default:
//                print("Unsupported parameter type at index \(index)")
//                sqlite3_finalize(statement)
//                return false
//            }
//            
//            if bindResult != SQLITE_OK {
//                print("Error binding parameter at index \(index): \(String(cString: sqlite3_errmsg(db)))")
//                sqlite3_finalize(statement)
//                return false
//            }
//        }
//
//        if sqlite3_step(statement) != SQLITE_DONE {
//            print("Error executing query: \(String(cString: sqlite3_errmsg(db)))")
//            sqlite3_finalize(statement)
//            return false
//        }
//
//        sqlite3_finalize(statement)
//        return true
//    }
    
    func fetchReceipt(with receiptId: String) -> Recepit? {
        let query = "SELECT * FROM Receipts WHERE recepitId = '\(receiptId)';"
        let rows = fetchQuery(query: query)
        
        // Since receiptId should be unique, we expect at most one result
        if let row = rows.first {
            guard let idString = row["recepitId"],
                  let dateText = row["date"],
                  let totalPriceString = row["totalPrice"],
                  let totalPrice = Double(totalPriceString) else {
                print("Error: Could not parse receipt data.")
                return nil
            }
            
            let receiptImageString = row["receiptImage"]
            let receiptImageData = Data(base64Encoded: receiptImageString ?? "")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Use the date format that matches your database
            
            return Recepit(
                recepitId: idString,
                date: dateFormatter.date(from: dateText) ?? Date(),
                totalPrice: totalPrice,
                recepitImage: receiptImageData // This will be nil if the receiptImageString is nil
            )
        } else {
            return nil // No receipt found for the given receiptId
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
    
    func fetchMostRecentReceiptDate(completion: @escaping (Date?) -> Void) {
                let query = "SELECT MAX(date) FROM Receipts;"

                var mostRecentDate: Date? = nil
                var statement: OpaquePointer?

                if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                    if sqlite3_step(statement) == SQLITE_ROW {
                        if let dateString = sqlite3_column_text(statement, 0) {
                            let dateStr = String(cString: dateString)
                            mostRecentDate = dateFormatter.date(from: dateStr)
                        }
                    } else {
                        print("No rows found or error fetching the most recent date.")
                    }
                    sqlite3_finalize(statement)
                } else {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    print("Error preparing the query: \(errorMessage)")
                }

                completion(mostRecentDate)
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

    func dueDateText(from date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }

//    Goals
//    func insertGoal(goal: GoalModel, completion: @escaping (Bool) -> Void) {
//            let query = """
//                INSERT INTO Goals (id, goal, amount, date, createDate, achieved)
//                VALUES (?, ?, ?, ?, ?, ?);
//            """
//            
//            let dateString = dateFormatter.string(from: goal.date)
//            let createDateStrig = dateFormatter.string(from: goal.createDate)
//            let achieved = goal.achieved ? 1:0
//            completion(executeQueryWithParams(query: query, params: [goal.id.uuidString, goal.goal, goal.amount, dateString, createDateStrig, achieved]))
//        }
//    
//    func insertGoal(goal: GoalModel, completion: @escaping (Bool) -> Void) {
//        let query = """
//            INSERT INTO Goals (id, goal, amount, date, createDate, achieved)
//            VALUES (?, ?, ?, ?, ?, ?);
//        """
//        
//        let dateString = dateFormatter.string(from: goal.date)
//        let createDateStrig = dateFormatter.string(from: goal.createDate)
//        let achieved = goal.achieved ? 1:0
//        completion(executeQueryWithParams(query: query, params: [goal.id.uuidString, goal.goal, goal.amount, dateString, createDateStrig, achieved]))
//    }
    
    func insertGoal(goal: GoalModel, completion: @escaping (Bool) -> Void) {
        let query2 = "SELECT amount FROM Goals;"
        let rows = fetchQuery(query: query2)
        print(rows)
        let query = """
            INSERT INTO Goals (id, goal, amount, date, createDate, achieved, percent, goalType, comparedPercent, frequency)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        let dateString = dateFormatter.string(from: goal.date)
        let createDateStrig = dateFormatter.string(from: goal.createDate)
        let achieved = goal.achieved ? 1:0
        completion(executeQueryWithParams(query: query, params: [goal.id.uuidString, goal.goal, goal.amount, dateString, createDateStrig, achieved, goal.percent, goal.goalType, goal.comparedPercent, goal.frequency]))
    }


        
        func deleteGoal(goalId: String, completion: @escaping (Bool) -> Void) {
            let query = "DELETE FROM Goals WHERE id = ?;"
            
            completion(executeQueryWithParams(query: query, params: [goalId]))
        }
        
        

//        func fetchGoals(completion: @escaping ([GoalModel]) -> Void) {
//            let query = "SELECT * FROM Goals ORDER BY createDate DESC;"
//            let rows = fetchQuery(query: query)
//            var goals = [GoalModel]()
//            
//            for row in rows {
//                if let idString = row["id"],
//                   let goal = row["goal"],
//                   let amountString = row["amount"],
//                   let amount = Double(amountString),
//                   let achievedString = row["achieved"],
//                   let achieved = Int(achievedString),
//
//                   let dateString = row["date"],
//                   let createDateStr = row["createDate"],
//                   let id = UUID(uuidString: idString),
//                   let date = dateFormatter.date(from: dateString),
//                   let createDate = dateFormatter.date(from: createDateStr) {
//                    
//                    let goalModel = GoalModel(id: id, goal: goal, amount: amount, date: date, createDate: createDate, achieved: achieved == 0 ? true : false)
//                    goals.append(goalModel)
//                }
//            }
//            
//            completion(goals)
//        }
    
    func fetchGoals(completion: @escaping ([GoalModel]) -> Void) {
        let query = "SELECT * FROM Goals ORDER BY createDate DESC;"
        let rows = fetchQuery(query: query)
        var goals = [GoalModel]()
        
        for row in rows {
            if let idString = row["id"],
               let goal = row["goal"],
               let amountString = row["amount"],
               let amount = Double(amountString),
               let achievedString = row["achieved"],
               let achieved = Int(achievedString),
               let comparedPercentString = row["comparedPercent"],
               let comparedPercent = Double(comparedPercentString),
               let frequencyString = row["frequency"],
               let frequency = Double(frequencyString),
               let percentString = row["percent"],
               let percent = Double(percentString),
               let dateString = row["date"],
               let createDateStr = row["createDate"],
               let id = UUID(uuidString: idString),
               let goalType = row["goalType"],
               let date = dateFormatter.date(from: dateString),
               let createDate = dateFormatter.date(from: createDateStr) {
                
                let goalModel = GoalModel(id: id, goal: goal, amount: amount, date: date, createDate: createDate, achieved: achieved == 1 ? true : false, percent: percent, goalType: goalType, comparedPercent: comparedPercent, frequency: frequency)
                goals.append(goalModel)
            }
        }
        
        completion(goals)
    }
    
    func hasAnyGoals(completion: @escaping (Bool) -> Void) {
        let query = "SELECT EXISTS(SELECT 1 FROM Goals);"
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let exists = sqlite3_column_int(statement, 0) != 0
                completion(exists)
            } else {
                print("Error checking for goals")
                completion(false)
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing query")
            completion(false)
        }
    }

    
    
    func updateGoal(goal: GoalModel, completion: @escaping (Bool) -> Void) {
        let query = """
          UPDATE Goals
          SET goal = ?,
              amount = ?,
              date = ?,
              achieved = ?,
              percent = ?,
              goalType = ?,
              comparedPercent = ?,
              frequency = ?
          WHERE id = ?;
"""
        
        let dateString = dateFormatter.string(from: goal.date)
        let achievedValue = goal.achieved ? 1 : 0
        
        completion(executeQueryWithParams(query: query, params: [goal.goal, goal.amount, dateString, achievedValue, goal.percent, goal.goalType, goal.comparedPercent, goal.frequency ,goal.id.uuidString]))
    }
    
    func fetchLatestTwoGoals(completion: @escaping ([GoalModel]) -> Void) {
        let query = "SELECT * FROM Goals ORDER BY createDate DESC LIMIT 2;"
        let rows = fetchQuery(query: query)
        var goals = [GoalModel]()
        
        for row in rows {
            if let idString = row["id"],
               let goal = row["goal"],
               let amountString = row["amount"],
               let amount = Double(amountString),
               let achievedString = row["achieved"],
               let achieved = Int(achievedString),
               let dateString = row["date"],
               let createDateStr = row["createDate"],
               let percentString = row["percent"],
               let percent = Double(percentString),
               let id = UUID(uuidString: idString),
               let goalType = row["goalType"],
               let comparedPercentString = row["comparedPercent"],
               let comparedPercent = Double(comparedPercentString),
               let frequencyString = row["frequency"],
               let frequency = Double(frequencyString),
               let date = dateFormatter.date(from: dateString),
               let createDate = dateFormatter.date(from: createDateStr) {
                
                let goalModel = GoalModel(id: id, goal: goal, amount: amount, date: date, createDate: createDate, achieved: achieved == 1 ? true : false, percent: percent, goalType: goalType, comparedPercent: comparedPercent, frequency: frequency)
                goals.append(goalModel)
            }
        }
        
        completion(goals)
    }
}
