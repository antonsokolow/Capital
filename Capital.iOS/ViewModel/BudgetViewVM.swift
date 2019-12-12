//
//  BudgetModelController.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 11/02/2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData

class BudgetViewVM: NSObject {
    var monthyear: Monthyear
    var data = [BudgetDataModel]()
    var budgets = [Budget]()
    var coreDataManager: CoreDataManager
    
    var reload: ((_ changes: ViewModelChange) -> Void)?
    
    init(monthyear: Monthyear) {
        
        self.monthyear = monthyear
        self.coreDataManager = CoreDataManager()
        
        super.init()
        // Слушаем изменения в Core Data
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    // MARK: - Fetch Modify and Remove Data
    
    func fetchData() {
        createMonthlyBudgets()
        
        coreDataManager.fetchBudgets(monthyear: monthyear) { budgets in
            self.budgets = budgets
        }
        
        for value in CategoryType.allCases {
            data.append(BudgetDataModel(headerName: value, isExpandable: true))
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfRowsInSection(section: Int) -> Int {
        return data[section].isExpanded ? 1 : 0
    }
    
    func numberOfSections() -> Int {
        return data.count
    }
    
    func headerTitle(section: Int) -> String {
        guard let header = AccountType(id: section)  else {
            return ""
        }
        return header.name + "   "
    }
    
    func heightForRowAt(indexPath: IndexPath) -> CGFloat {
        if data[indexPath.section].isExpanded {
            // вычисляем высоту строки так чтобы поместилась вся коллекция
            let cellsInRow = 3
            let numberOfRows: Int = budgetsInSection(section: indexPath.section).count / cellsInRow + (budgetsInSection(section: indexPath.section).count % cellsInRow > 0 ? 1 : 0)
            return CGFloat(numberOfRows * 160)
        } else {
            return 0
        }
    }
    
    func heightForHeaderInSection(section: Int) -> CGFloat {
        return 48
    }
    
    func budgetsInSection(section: Int) -> [Budget] {
        return budgets.filter { $0.itemType == CategoryType(id: section) }.sorted { $0.order < $1.order }
    }
    
    func monthSpent(at indexPath: IndexPath) -> Decimal {
        let budget = budgetsInSection(section: indexPath.section)[indexPath.row]
        
        return budget.monthSpent(monthyear: monthyear)
    }
    
    func totalSpent(section: Int) -> Decimal {
        var totalSpent: Decimal = 0.0
        for budget in budgetsInSection(section: section) {
            totalSpent += budget.monthSpent(monthyear: monthyear)
        }
        
        return totalSpent
    }
    
    // Создаем ежемесячные бюджеты
    func createMonthlyBudgets() {
        // Проверяем наличие ежемесячных бюджетов
        let now = Monthyear.getNow()
        if monthyear > now {
            for categoryType in CategoryType.allCases {
                let categories = DataStore.shared.getCategories(type: categoryType, monthly: true)
                for category in categories {
                    if DataStore.shared.getBudget(category: category, monthyear: monthyear) == nil {
                        // Создаем бюджет
                        let budget = Budget(context: DataHandler.shared.viewContext)
                        budget.year = Int64(monthyear.year)
                        budget.month = Int64(monthyear.month)
                        budget.amount = category.amount
                        budget.category = category
                        budget.type = category.type
                    }
                }
            }
        }
    }

    
    // Возвращает баланс по счетам
    // Если указан текущий месяц, то актуальный остаток денег
    // Если месяц еще не наступил, то счетаем все предыдущие месяцы
    func getTotalBalance(type: AccountType) -> Money {
        var balance = Money(amt: 0.0, currency: Money.baseCurrency)
        let now = Monthyear.getNow()
        if monthyear > now {
            let previousMonth = monthyear.getPreviousMonth()
            balance = previousMonth.getBudgetIncome() - previousMonth.getBudgetExpense() + getStartBalance(type: type, monthyear: previousMonth)
        } else {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
            let predicate = NSPredicate(format: "type == %@", type.rawValue)
            //let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
            //request.sortDescriptors = [sortDescriptor]
            request.predicate = predicate
            request.returnsObjectsAsFaults = false
            do {
                let result = try DataHandler.shared.viewContext.fetch(request)

                // Если месяц текущий считаем баланс каждого счета
                for data in result as! [NSManagedObject] {
                    if let item = data as? Account, let itemBalance = getBalance(account: item, monthyear: monthyear) as Money? {
                        balance = balance + itemBalance
                    }
                }

            } catch {
                ErrorHandler.shared.reportError(message: "BudgetModelController: 137")
            }

        }
        return balance
    }
    
    func getBalance(account: Account, monthyear: Monthyear) -> Money {
        guard let periodStart = monthyear.getPeriodStart, let periodEnd = monthyear.getPeriodEnd else {
            return Money(amt: 0.0, currency: account.currency)
        }
        var amount = Money(amt: 0.0, currency: account.currency)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "(account == %@ OR accountto == %@) AND createdon >= %@ AND createdon < %@", argumentArray: [account, account, periodStart, periodEnd])
        //let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        //request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try DataHandler.shared.viewContext.fetch(request)
            for data in result as! [NSManagedObject] {
                if let transaction = data as? Transaction {
                    amount = amount + transaction.getAmount(account: account)
                }
            }
        } catch {
            ErrorHandler.shared.reportError(message: "BudgetViewVM: 171")
        }

        return amount
    }

    func getStartBalance(type: AccountType, monthyear: Monthyear) -> Money {
        let now = Monthyear.getNow()
        var startBalance: Money = Money(amt: 0.0, currency: Money.baseCurrency)
        if monthyear > now {
            // Показываем планируемый остаток по счетам
            let previousMonth = monthyear.getPreviousMonth()
            startBalance = getStartBalance(type: type, monthyear: previousMonth) + previousMonth.getBudgetIncome() - previousMonth.getBudgetExpense()
        } else {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
            let predicate = NSPredicate(format: "type == %@", type.rawValue)
            //let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
            //request.sortDescriptors = [sortDescriptor]
            request.predicate = predicate
            request.returnsObjectsAsFaults = false
            do {
                let result = try DataHandler.shared.viewContext.fetch(request)

                // Считаем баланс каждого счета
                for data in result as! [NSManagedObject] {
                    if let item = data as? Account, let itemBalance = item.getStartBalance(monthyear: monthyear) as Money? {
                        startBalance = startBalance + itemBalance
                    }
                }

            } catch {
                ErrorHandler.shared.reportError(message: "BudgetViewVM: 202")
            }
        }
        return startBalance
    }
    
    
    // MARK: - Core Data Observer
    @objc func contextObjectsDidChange(_ notification: Notification) {
        var modifications = [IndexPath]()
        var insertions = [IndexPath]()
        var deletions = [IndexPath]()
        var sections = [Int]()
        var isInitial = true
        var changes: ViewModelChange
        
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
            for object in updatedObjects {
                // Изменили данные
                if let item = object as? Budget {
                    isInitial = true
                }
                
            }
        }

        
        guard let reload = self.reload else { return }
        
        createMonthlyBudgets()
        
        coreDataManager.fetchBudgets(monthyear: monthyear) { budgets in
            self.budgets = budgets
        }
        
        if(isInitial) {
            changes = ViewModelChange.initial
        } else {
            changes = ViewModelChange.update(deletions: deletions, insertions: insertions, modifications: modifications, sections: sections)
        }
        reload(changes)
    }
}
