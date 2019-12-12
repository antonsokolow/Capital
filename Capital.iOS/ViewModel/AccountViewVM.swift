//
//  File.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 12/02/2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData

class AccountViewVM: NSObject {
    private var data = [AccountTableViewModel]()
    private var accounts = [Account]()
    
    var coreDataManager: CoreDataManager
    
    var reload: ((_ changes: ViewModelChange) -> Void)?
    
    override init() {
        coreDataManager = CoreDataManager()
        super.init()
        // Слушаем изменения в Core Data
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfRowsInSection(section: Int) -> Int {
        return data[section].isExpanded ? accountsInSection(section: section).count : 0
    }
    
    func numberOfSections() -> Int {
        return AccountType.allCases.count
    }
    
    func headerTitle(section: Int) -> String {
        guard let header = AccountType(id: section)  else {
            return ""
        }
        return header.name + "   "
    }
    
    func heightForRowAt(indexPath: IndexPath) -> CGFloat {
        if data[indexPath.section].isExpanded {
            return 80
        }
        return 0
    }
    
    func accountsInSection(section: Int) -> [Account] {
        return accounts.filter { $0.itemType == AccountType(id: section) }
    }
    
    
    func getAccount(at indexPath: IndexPath) -> Account {
        let account = accountsInSection(section: indexPath.section)[indexPath.row]
        return account
    }
    
    func accountName(indexPath: IndexPath) -> String {
        guard let name = accountsInSection(section: indexPath.section)[indexPath.row].name else {
            return ""
        }
        return name
    }
    
    func isSectionExpanded(section: Int) -> Bool {
        return data[section].isExpanded
    }
    
    func toggleSectionExpanded(section: Int) {
        data[section].isExpanded = !data[section].isExpanded
    }
    
    func getSectionType(section: Int) -> AccountType? {
        return data[section].accountType
    }
    
    func accountAmount(indexPath: IndexPath) -> String {
        let account = accountsInSection(section: indexPath.section)[indexPath.row]
        var accountBalance = account.money
        // Для кредитной карты отображаем limit - balance
        if account.itemType == AccountType.credit {
            let limit = account.limit as Decimal? ?? 0
            accountBalance = accountBalance + limit
        }
        return accountBalance.formattedString
    }
    
    func accountIcon(indexPath: IndexPath) -> UIImage {
        guard let accountType = data[indexPath.section].accountType, let image = UIImage(named: accountType.icon) else {
            return UIImage()
        }
        return image
    }
    
    func infoLabelText(indexPath: IndexPath) -> NSAttributedString {
        let account = accountsInSection(section: indexPath.section)[indexPath.row]
        if account.type == AccountType.asset.rawValue,  let goal = account.goal as Decimal?, goal != 0 {
            let myString = NSMutableAttributedString()
            
            var myAttribute = [ NSAttributedString.Key.foregroundColor: KColor.lightText, NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 12.0)! ]
            let text1 = NSAttributedString(string: "Цель:", attributes: myAttribute)
            myAttribute = [ NSAttributedString.Key.foregroundColor: KColor.greenText, NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 12.0)! ]
            
            let text2 = NSAttributedString(string: " " + goal.formattedStringDecimal, attributes: myAttribute)
            
            myString.append(text1)
            myString.append(text2)
            
            return myString
        } else {
            return NSAttributedString(string: " ")
        }
    }
    
    func totalBudget(section: Int) -> String {
        var totalBudget: Decimal = 0.0
        totalBudget = accountsInSection(section: section).reduce(totalBudget) { $0 + $1.balance }
        
        return totalBudget.formattedStringDecimal
    }
    
    // MARK: - Fetch Modify and Remove Data
    
    func fetchData() {
        coreDataManager.fetchAccounts() { accounts in
            self.accounts = accounts
        }
        
        for value in AccountType.allCases {
            data.append(AccountTableViewModel(headerName: value, isExpandable: true))
        }
        
    }
    
    
    func remove(account: Account, at indexPath: IndexPath) {
        coreDataManager.viewContext.delete(account)
    }
    

    
    // MARK: - Core Data Observer
    @objc func contextObjectsDidChange(_ notification: Notification) {
        var modifications = [IndexPath]()
        var insertions = [IndexPath]()
        var deletions = [IndexPath]()
        var sections = [Int]()
        var isInitial = false
        var changes: ViewModelChange
        
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
            for object in insertedObjects {
                // Добавили данные
                if let transaction = object as? Transaction {
                    // При добавлени, изменении или удалении транзакции
                    // обновляем всю секцию
                    // TODO: реализовать метод обновления заголовка секции
                    
                    if let account = transaction.account {
                        sections.append(account.itemType.section)
                    }
                    if let account = transaction.accountto {
                        sections.append(account.itemType.section)
                    }
                }
                
                if let account = object as? Account {
                    accounts.append(account)
                    sections.append(account.itemType.section)
                }
            }
        }
        
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
            for object in updatedObjects {
                // Изменили данные
                if let transaction = object as? Transaction {
                    
                    if let account = transaction.account, data[account.itemType.section].isExpanded {
                        sections.append(account.itemType.section)
                    }
                    if let account = transaction.accountto, data[account.itemType.section].isExpanded {
                        sections.append(account.itemType.section)
                    }
                }
                
                if let account = object as? Account {
                    // Изменили данные в счете
                    if(!data[account.itemType.section].isExpanded) { return }
                    let accounts = self.accounts.filter { $0.itemType == account.itemType }
                    if let row = accounts.firstIndex(where: {$0.objectID == account.objectID}) {
                        let indexPath = IndexPath(row: row, section: account.itemType.section)
                        modifications.append(indexPath)
                    }
                }
            }
        }
        
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
            for object in deletedObjects {
                // Удалили данные
                if object is Transaction {
                    isInitial = true
                }
                
                if let account = object as? Account {
                    // Найдем и запомним indexPath
                    let accounts = self.accounts.filter { $0.itemType == account.itemType }
                    if let row = accounts.firstIndex(where: {$0.objectID == account.objectID}), data[account.itemType.section].isExpanded {
                        let indexPath = IndexPath(row: row, section: account.itemType.section)
                        deletions.append(indexPath)
                    }
                    
                    //  Теперь удаляем аккаунт из модели
                    if let index = self.accounts.firstIndex(where: {$0.objectID == account.objectID}) {
                        self.accounts.remove(at: index)
                    }
                }
            }
        }
        guard let reload = self.reload else { return }
        
        if(isInitial) {
            changes = ViewModelChange.initial
        } else {
            changes = ViewModelChange.update(deletions: deletions, insertions: insertions, modifications: modifications, sections: sections)
        }
        reload(changes)
    }
}
