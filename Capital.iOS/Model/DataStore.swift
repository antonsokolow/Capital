//
//  DataStore.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 04/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData
import os.log

struct DataStore {
    static var shared = DataStore()
    
    var accounts: [Account] {
        get {
            return getAccounts(type: AccountType.cash)
        }
    }
    
    var categories: [Category] {
        get {
            return getCategories(type: CategoryType.expense)
        }
    }
    
    var currentMonth = Date()
    //var categories = ["Автомобиль", "Дом", "Питание", "Дети"]
    //var items: [ShopItem] = [ShopItem(name: "Сгущенка"), ShopItem(name: "Молоко"), ShopItem(name: "Хлеб"), ShopItem(name: "Творог")]
    
    let context = DataHandler.shared.viewContext
    
    private init() { }
    

    
    func delete(entity: Entity, item: Any) {
        switch entity {
        case .account(_):
            guard let account = item as? Account else {
                fatalError()
            }
            DataStore.shared.deleteAccount(account: account)
        case .budget:
            guard let budget = item as? Budget else {
                fatalError()
            }
            DataStore.shared.deleteBudget(budget: budget)
        case .cash:
            break
        case .category:
            break
        case .transaction:
            guard let transaction = item as? Transaction else {
                fatalError()
            }
            DataStore.shared.deleteTransaction(transaction: transaction)
        }
    }
    
    func getAccounts(type: AccountType) -> [Account] {
        var items: [Account] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "type == %@", type.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Account {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 78, \(error)")
        }
        
        return items
    }
    
    func getCategories(type: CategoryType, monthly: Bool? = nil) -> [Category] {
        var items: [Category] = []
        var predicate: NSPredicate
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        if let monthly = monthly {
            predicate = NSPredicate(format: "type == %@ AND monthly == %@", argumentArray: [type.rawValue, monthly])
        } else {
            predicate = NSPredicate(format: "type == %@", type.rawValue)
        }
        
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Category {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 106")
        }
        
        return items
    }
    
    func getCurrencyRates() -> [CurrencyRate] {
        var items: [CurrencyRate] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRate")
        //let predicate = NSPredicate(format: "type == %@", type.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "symbol", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        //request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? CurrencyRate {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 128")
        }
        
        return items
    }
    
    func getCategoryByName(name: String) -> Category? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: "name == %@", argumentArray: [name])
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                if let category = result[0] as? Category {
                    return category
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 147")
        }
        return nil
    }
    
    func getBudgets(type: CategoryType, month: Int, year: Int) -> [Budget] {
        var items: [Budget] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let predicate = NSPredicate(format: "type == %@ AND month == %@ AND year == %@", argumentArray: [type.rawValue, month, year])
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Budget {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 168")
        }
        
        return items
    }
    
    func getBudget(category: Category, createdon: Date) -> Budget? {
        var budget: Budget?
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy"
        guard let year = Int(dateFormatter.string(from: createdon)) else {
            return nil
        }
        
        dateFormatter.dateFormat = "M"
        guard let month = Int(dateFormatter.string(from: createdon)) else {
            return nil
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let predicate = NSPredicate(format: "category == %@ AND month == %@ AND year == %@", argumentArray: [category, month-1, year])
        //let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        //request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                if let item = result[0] as? NSManagedObject {
                    budget = item as? Budget
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 202")
        }
        
        return budget
    }
    
    func getBudget(category: Category, monthyear: Monthyear) -> Budget? {
        var budget: Budget?
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let predicate = NSPredicate(format: "category == %@ AND month == %@ AND year == %@", argumentArray: [category, monthyear.month, monthyear.year])
        //let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        //request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                if let item = result[0] as? NSManagedObject {
                    budget = item as? Budget
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 225")
        }
        
        return budget
    }
    
    func getTransactions(account: Account) -> [Transaction] {
        var items: [Transaction] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "account == %@ OR accountto == %@", argumentArray: [account, account])
        let sortDescriptor = NSSortDescriptor(key: "createdon", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Transaction {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 247")
        }
        
        return items
    }
    
    func getTransactions(account: Account, monthyear: Monthyear) -> [Transaction] {
        var items: [Transaction] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "account == %@ OR accountto == %@", argumentArray: [account, account])
        let sortDescriptor = NSSortDescriptor(key: "createdon", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Transaction {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 269")
        }
        
        return items
    }
    
    func getTransactions(monthyear: Monthyear) -> [Transaction] {
        var items: [Transaction] = []
        guard let periodStart = monthyear.getPeriodStart, let periodEnd = monthyear.getPeriodEnd else {
            return []
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "createdon >= %@ AND createdon < %@", argumentArray: [periodStart, periodEnd])
        let sortDescriptor = NSSortDescriptor(key: "createdon", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Transaction {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 295")
        }
        
        return items
    }
    
    func getTransactions(monthyear: Monthyear, account: Account?, category: Category?) -> [Transaction] {
        var items: [Transaction] = []
        var predicate: NSPredicate
        guard let periodStart = monthyear.getPeriodStart, let periodEnd = monthyear.getPeriodEnd else {
            return []
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        if let account = account {
            predicate = NSPredicate(format: "createdon >= %@ AND createdon < %@ AND account == %@", argumentArray: [periodStart, periodEnd, account])
        } else if let category = category {
            predicate = NSPredicate(format: "createdon >= %@ AND createdon < %@ AND category == %@", argumentArray: [periodStart, periodEnd, category])
        }
        else {
            predicate = NSPredicate(format: "createdon >= %@ AND createdon < %@", argumentArray: [periodStart, periodEnd])
        }
        
        let sortDescriptor = NSSortDescriptor(key: "createdon", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Transaction {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 330")
        }
        
        return items
    }
    
    func getCashList(account: Account) -> [Cash] {
        var items: [Cash] = []
        let context = DataHandler.shared.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cash")
        let predicate = NSPredicate(format: "account == %@", account)
        let sortDescriptor = NSSortDescriptor(key: "createdon", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Cash {
                    items.append(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 353")
        }
        
        return items
    }
    
    
    func getTotalBalance(type: AccountType) -> Decimal {
        var balance: Decimal = 0.00
        let context = DataHandler.shared.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "type == %@", type.rawValue)
        //let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        //request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Account, let itemBalance = item.balance as Decimal? {
                    balance += itemBalance
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 377")
        }
        
        return balance
    }
    
    func saveTransaction(type: TransactionType, properties: PropertyContainer) {
        
        let transaction = Transaction(context: context)

        if let account = properties.getPropertyValue(name: "account") as? Account {
            transaction.account = account
        }
        if let amount = properties.getPropertyValue(name: "amount") as? NSDecimalNumber {
            if amount != NSDecimalNumber.notANumber {
                transaction.amount = amount
            }
        }
        if let accountto = properties.getPropertyValue(name: "accountto") as? Account {
            transaction.accountto = accountto
        }
        
        if let amountto = properties.getPropertyValue(name: "amountto") as? NSDecimalNumber {
            if amountto != NSDecimalNumber.notANumber {
                transaction.amountto = amountto
            }
        }
        if let category = properties.getPropertyValue(name: "category") as? Category {
            transaction.category = category
        }
        
        if let createdon = properties.getPropertyValue(name: "createdon") as? Date {
            transaction.createdon = createdon
        } else {
            transaction.createdon = Date()
        }
        
        if let comment = properties.getPropertyValue(name: "comment") as? String {
            transaction.comment = comment
        }

        
        transaction.type = type.rawValue
        
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "DataStore")
        os_log("save transaction", log: log, type: .default)
        
        
        // Если бюджета на эту категорию нет, то создаем его
        if let category = properties.getPropertyValue(name: "category") as? Category,  let createdon = properties.getPropertyValue(name: "createdon") as? Date {
            if getBudget(category: category, createdon: createdon) == nil {
                let budget = Budget(context: context)
                
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateFormat = "yyyy"
                guard let year = Int(dateFormatter.string(from: createdon)) else {
                    return
                }
                
                dateFormatter.dateFormat = "M"
                guard let month = Int(dateFormatter.string(from: createdon)) else {
                    return
                }
                
                budget.year = Int64(year)
                budget.month = Int64(month-1)
                budget.amount = 0
                budget.category = category
                budget.type = category.type
            
            }
        }
        
    }
    
    // Заменяем всем транзакциям категорию
    func moveCategory(category: Category, categoryTo: Category) {
        // Меняем категорию у всех транзакций на новую
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "category == %@", category)
        //let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        //request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Transaction {
                    item.category = categoryTo
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 470")
        }
        
        // Удаляем существующие бюджеты
        let budgetRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let budgetPredicate = NSPredicate(format: "category == %@", category)
        budgetRequest.predicate = budgetPredicate
        budgetRequest.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(budgetRequest)
            for data in result as! [NSManagedObject] {
                if let item = data as? Budget {
                    context.delete(item)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "DataStore: 486")
        }
    }
    
    func deleteCategory(category: Category) {
        // Меняем категорию у всех транзакций на новую
        
        // удаляем категорию
        context.delete(category)
    }
    
    func deleteAccount(account: Account) {
        context.delete(account)
    }
    
    func deleteTransaction(transaction: Transaction) {
        context.delete(transaction)
    }
    
    func deleteBudget(budget: Budget) {
        if let category = budget.category, category.monthly == true {
            category.monthly = false
        }
        context.delete(budget)
    }
    
    func isTransactionsForCategoryExists(category: Category) -> Bool? {
        let context = DataHandler.shared.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "category == %@", category)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            return result.count > 0
        } catch {
            return nil
        }
    }
}
