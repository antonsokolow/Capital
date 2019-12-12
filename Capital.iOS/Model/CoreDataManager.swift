//
//  CoreDataManager.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 19.08.2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: NSObject {
    
    var viewContext = DataHandler.shared.viewContext
    
    func fetchAccounts(completion: ([Account]) -> ()) {
        var items: [Account] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.returnsObjectsAsFaults = false
        do {
            let result = try viewContext.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Account {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "CoreDataManager: 30")
        }
        
        // Return items
        completion(
            items
        )
    }
    
    func fetchTransactions(completion: ([Transaction]) -> ()) {
        var items: [Transaction] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        request.returnsObjectsAsFaults = false
        do {
            let result = try viewContext.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Transaction {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "CoreDataManager: 51")
        }
        
        // Return items
        completion(
            items
        )
    }
    
    func fetchBudgets(monthyear: Monthyear, completion: ([Budget]) -> ()) {
        var items: [Budget] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let predicate = NSPredicate(format: "month == %@ AND year == %@", argumentArray: [monthyear.month,  monthyear.year])
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try viewContext.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Budget {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "CoreDataManager: 76")
        }
        
        // Return items
        completion(
            items
        )
    }
}
