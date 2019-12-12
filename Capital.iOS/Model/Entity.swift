//
//  Entity.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 11/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import Foundation
import CoreData

enum Entity {
    case account(type: AccountType)
    case budget(type: CategoryType)
    case cash(isreceipt: Bool)
    case category(type: CategoryType)
    case transaction(type: TransactionType)
    
    var cells: [Field] {
        switch self {
        case .account(let type):
            return type.cells
        case .budget(let type):
            return type.cells
        case .cash(_):
            return [ Field.name(property: "name"), Field.amount(property: "amount", title: "Сумма")]
        case .category(_):
            return [ Field.namewithicon(property: "name"), Field.comment(property: "comment")]
        case .transaction(let type):
            return type.cells
        }
    }
    
    var cellsEdit: [Field] {
        switch self {
        case .account(let type):
            return type.cells
        case .budget(let type):
            return type.cells
        case .cash(_):
            return [ Field.name(property: "name"), Field.amount(property: "amount", title: "Сумма")]
        case .category:
            return [ Field.namewithicon(property: "name"), Field.comment(property: "comment")]
        case .transaction(let type):
            var cells = type.cells
            if type == TransactionType.newdebet || type == TransactionType.newcredit {
                return cells
            }
            cells.append(Field.button(property: "delete", title: "Удалить", action: {}))
            return cells
        }
    }
    
    func getProperties(item: Any) -> PropertyContainer {
        switch self {
            //1
        case .account(_):
            guard let account = item as? Account else {
                fatalError()
            }
            return account.getProperties()
            //2
        case .budget:
            guard let budget = item as? Budget else {
                fatalError()
            }
            return budget.getProperties()
            //3
        case .cash:
            guard let cash = item as? Cash else {
                fatalError()
            }
            return cash.getProperties()
            //4
        case .category:
            guard let category = item as? Category else {
                fatalError()
            }
            return category.getProperties()
            //5
        case .transaction(_):
            guard let transaction = item as? Transaction else {
                fatalError()
            }
            return transaction.getProperties()
        }
    }
    
    var title: String {
        switch self {
        case .account(let type):
            return type.accountName
        case .budget:
            return "Бюджет"
        case .cash:
            return "Транзакция"
        case .category:
            return "Категория"
        case .transaction(let type):
            return type.name
        }
    }
    
    var deleteMessage: String {
        switch self {
        case .account(_):
            return NSLocalizedString("Транзакции будут удалены", comment: "Транзакции будут удалены")
        case .budget:
            return "Удалить"
        case .cash:
            return "Удалить"
        case .category:
            return NSLocalizedString("Удалить", comment: "Удалить")
        case .transaction(_):
            return "Удалить"
        }
    }
    
    func save(item: Any?, properties: PropertyContainer ) {
        switch self {
        case .account(let type):
            if let account = item as? Account {
                // Edit
                account.update(properties: properties)
            } else {
                // Create New
                let account = Account(context: DataHandler.shared.viewContext)
                account.create(type: type, properties: properties)
            }
        case .budget(let type):
            if let budget = item as? Budget {
                // Edit
                budget.update(properties: properties)
            } else {
                // Create New
                let budget = Budget(context: DataHandler.shared.viewContext)
                budget.create(type: type, properties: properties)
            }
        case .cash:
            break
        case .category(let type):
            if let category = item as? Category {
                // Edit
                category.update(properties: properties)
            } else {
                // Create New
                let category = Category(context: DataHandler.shared.viewContext)
                category.create(type: type, properties: properties)
            }
        case .transaction(let type):
            if let transaction = item as? Transaction {
                // Edit
                transaction.update(properties: properties)
            } else {
                // Create New
                let transaction = Transaction(context: DataHandler.shared.viewContext)
                transaction.create(type: type, properties: properties)
                
                // Если бюджета на эту категорию нет, то создаем его
                if let category = properties.getPropertyValue(name: "category") as? Category,  let createdon = properties.getPropertyValue(name: "createdon") as? Date {
                    if category.getBudget(createdon: createdon) == nil {
                        let budget = Budget(context: DataHandler.shared.viewContext)
                        
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
        }
    }
}

