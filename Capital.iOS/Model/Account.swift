//
//  Account.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 07/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData
import os.log

public class Account: NSManagedObject, Item {
    
    var balance: Decimal {
        get {
            let monthyear = Monthyear.getNow()
            var amount: Decimal = 0.00
            
            guard let periodStart = monthyear.getPeriodStart, let periodEnd = monthyear.getPeriodEnd else {
                return 0
            }
            
            guard let trs = self.transactions, let transactionsExpense = trs.allObjects as? [Transaction] else { return 0 }
            guard let trsIncome = self.transactionsIncome, let transactionsIncome = trsIncome.allObjects as? [Transaction] else { return 0 }
            
            let expenseTransactions = Set(transactionsExpense.filter {
                guard let createdon = $0.createdon else {
                    ErrorHandler.shared.reportError(message: "Account.swift: 33")
                    return false
                    
                }
                return createdon >= periodStart && createdon <= periodEnd
                
            })
            let incomeTransactions = Set(transactionsIncome.filter {
                guard let createdon = $0.createdon else {
                    ErrorHandler.shared.reportError(message: "Account: 38")
                    return false
                }
                return createdon >= periodStart && createdon <= periodEnd
                
            })
            let allTransactions = expenseTransactions.union(incomeTransactions)
            
            amount = allTransactions.reduce(0) { $0 + $1.getAmount(account: self).amount }
            
            return amount
        }
    }
    
    var itemType: AccountType {
        get {
            guard let type = self.type, let accountType = AccountType(rawValue: type) else {
                ErrorHandler.shared.reportError(message: "Account: 55")
                return AccountType.cash
            }
            return accountType
        }
    }
    var money: Money {
        get {
            return Money(amt: balance, currency: currency)
        }
    }
    
    var currency: Currency {
        get {
            guard let symbol = self.currencyCode, let currency = Currency(rawValue: symbol) else {
                return Money.baseCurrency
            }
            return currency
        }
        set {
            currencyCode = newValue.rawValue
        }
    }
    
    // Indicate if account is debit or credit
    var isreceipt: Bool {
        return self.itemType.isreceipt
    }
    
    
    func create(type: AccountType, properties: PropertyContainer) {
        guard let name = properties.getPropertyValue(name: "name") as? String, let balance = properties.getPropertyValue(name: "balance") as? NSDecimalNumber, balance != NSDecimalNumber.notANumber, let currencyCode = properties.getPropertyValue(name: "currencyCode") as? String else {
                fatalError()
        }
        self.name = name
        self.type = type.rawValue
        self.currencyCode = currencyCode
        if let limit = properties.getPropertyValue(name: "limit") as? NSDecimalNumber {
            self.limit = limit
        }
        if let goal = properties.getPropertyValue(name: "goal") as? NSDecimalNumber {
            self.goal = goal
        }
        
        // Устанавливаем начальный баланс
        let transaction = Transaction(context: DataHandler.shared.viewContext)
        
        if self.isreceipt {
            transaction.accountto = self
            transaction.amountto = balance
            transaction.type = TransactionType.newdebet.rawValue
        } else {
            transaction.account = self
            transaction.amount = balance
            transaction.type = TransactionType.newcredit.rawValue
        }
        transaction.createdon = Date()
    }
    
    func update(properties: PropertyContainer) {
        if let name = properties.getPropertyValue(name: "name") as? String {
            self.name = name
        }
        if let symbol = properties.getPropertyValue(name: "currencyCode") as? String {
            self.currencyCode = symbol
        }
        // Корректировка баланса
        if let balance = properties.getPropertyValue(name: "balance") as? NSDecimalNumber {
            if balance != NSDecimalNumber.notANumber {
                // Делаем корректировку баланса

                var tproperties = PropertyContainer()
                if self.balance > balance as Decimal {
                    let amount = self.balance - (balance as Decimal)
                    tproperties.setProperty(name: "account", value: self)
                    tproperties.setProperty(name: "amount", value: amount)
                    DataStore.shared.saveTransaction(type: TransactionType.balance, properties: tproperties)
                } else if self.balance < balance as Decimal {
                    let amountto = (balance as Decimal) - self.balance

                    tproperties.setProperty(name: "accountto", value: self)
                    tproperties.setProperty(name: "amountto", value: amountto)
                    DataStore.shared.saveTransaction(type: TransactionType.balance, properties: tproperties)
                }
            }
        }
        if let limit = properties.getPropertyValue(name: "limit") as? NSDecimalNumber {
            self.limit = limit
        }
        if let goal = properties.getPropertyValue(name: "goal") as? NSDecimalNumber {
            self.goal = goal
        }
    }
    
    func getBalance() -> Decimal {
        
        let monthyear = Monthyear.getNow()
        
       // let _ = getStartTransaction(monthyear: monthyear)
        
        let balance = getBalance(monthyear: monthyear)
//
//        if self.itemType == AccountType.credit {
//            let limit = self.limit as Decimal? ?? 0
//            balance = limit + balance
//        }
        
        return balance
        
    }
    
    func getBalance(monthyear: Monthyear) -> Decimal {
        guard let periodStart = monthyear.getPeriodStart, let periodEnd = monthyear.getPeriodEnd else {
            return 0
        }
        var amount: Decimal = 0.00
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "(account == %@ OR accountto == %@) AND createdon >= %@ AND createdon < %@", argumentArray: [self, self, periodStart, periodEnd])
        //let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        //request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try DataHandler.shared.viewContext.fetch(request)
            for data in result as! [NSManagedObject] {
                if let transaction = data as? Transaction {
                    amount += transaction.getAmount(account: self).amount
                }
            }
        } catch {
            print("Failed", "getItems")
        }
        
        return amount
    }
    
    func getTransactions(monthyear: Monthyear) -> [Transaction] {
        var items: [Transaction] = []
        
        guard let periodStart = monthyear.getPeriodStart, let periodEnd = monthyear.getPeriodEnd else {
            return []
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "(account == %@ OR accountto == %@) AND createdon >= %@ AND createdon < %@", argumentArray: [self, self, periodStart, periodEnd])
        let sortDescriptor = NSSortDescriptor(key: "createdon", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try DataHandler.shared.viewContext.fetch(request)
            for data in result as! [NSManagedObject] {
                if let transaction = data as? Transaction {
                    items.append(transaction)
                }
            }
        } catch {
            print("Failed", "getItems")
        }
        
        return items
        
    }
    
//    func getBudgetBalance(monthyear: Monthyear) -> Decimal {
//        let now = Monthyear.getNow()
//        if monthyear > now {
//            // Показываем планируемый остаток по счетам
//            return getStartBalance(monthyear: monthyear)
//        } else {
//            // Считаем реальный остаток по счетам
//            return getBalance(monthyear: monthyear)
//        }
//    }
    
    
    func getStartBalance(monthyear: Monthyear) -> Money {
        let now = Monthyear.getNow()
        var startBalance: Money = Money(amt: 0.0, currency: currency)
        if monthyear > now {
            // Показываем планируемый остаток по счетам
            let previousMonth = monthyear.getPreviousMonth()
            startBalance = getStartBalance(monthyear: previousMonth) //+ previousMonth.getBudgetIncome() - previousMonth.getBudgetExpense()
        } else {
            // Ищем реальный начальный остаток по счету
            guard let transaction = getStartTransaction(monthyear: monthyear) else {
                return Money(amt: 0.0, currency: currency)
            }
            if self.isreceipt {
                guard let amount = transaction.amountto else {
                    return Money(amt: 0.0, currency: currency)
                }
                return Money(amt: amount.decimalValue, currency: currency)
            } else {
                guard let amount = transaction.amount else {
                    return Money(amt: 0.0, currency: currency)
                }
                return Money(amt: amount.decimalValue, currency: currency)
            }
        }
        return startBalance
    }
    
    func getStartTransaction(monthyear: Monthyear) -> Transaction? {
        if monthyear > Monthyear.getNow() { return nil } // Не может быть начальной транзакции у будущего месяца
        
        // Ищем транзакцию начального баланса
        guard let periodStart = monthyear.getPeriodStart, let periodEnd = monthyear.getPeriodEnd else {
            return nil
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        if self.isreceipt == true {
            let predicate = NSPredicate(format: "accountto == %@ AND createdon >= %@ AND createdon < %@ AND type == %@", argumentArray: [self, periodStart, periodEnd, TransactionType.newdebet.rawValue])
            request.predicate = predicate
        } else {
            let predicate = NSPredicate(format: "account == %@ AND createdon >= %@ AND createdon < %@ AND type == %@", argumentArray: [self, periodStart, periodEnd, TransactionType.newcredit.rawValue])
            request.predicate = predicate
        }
    
        request.returnsObjectsAsFaults = false
        do {
            let result = try DataHandler.shared.viewContext.fetch(request)
            if result.count > 0 {
                guard let transaction = result[0] as? Transaction else {
                    return nil
                }
                return transaction
            } else {
                // Создаем транзакцию Начальный баланс
                let transaction = Transaction(context: DataHandler.shared.viewContext)
                
                
                if self.isreceipt {
                    let balance = self.getBalance(monthyear: monthyear.getPreviousMonth()) as NSDecimalNumber
                    transaction.accountto = self
                    transaction.amountto = balance
                    transaction.type = TransactionType.newdebet.rawValue
                } else {
                    let balance = (0 - self.getBalance(monthyear: monthyear.getPreviousMonth())) as NSDecimalNumber
                    transaction.account = self
                    transaction.amount = balance
                    transaction.type = TransactionType.newcredit.rawValue
                }
                transaction.createdon = Date()
                
                return transaction
            }
        } catch {
            fatalError()
        }
    }
    
    
    
    class func getProp() -> [String] {
        let mirror = Mirror(reflecting: Account())
        return mirror.children.compactMap { $0.label }
    }
    
    func getProperties() -> PropertyContainer {
        var properties = PropertyContainer()
        
        for (name, _) in  self.entity.attributesByName {
            if let value = self.value(forKey: name) {
                properties.setProperty(name: name, value: value)
            }
        }
        let balance = self.balance
        properties.setProperty(name: "balance", value: balance)
        
        return properties
    }
}
