//
//  Budget.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 12/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData

public class Budget: NSManagedObject {
    
    var monthyear: Monthyear {
        set {
            self.month = Int64(newValue.month)
            self.year = Int64(newValue.year)
        }
        
        get {
            return Monthyear(month: self.month, year: self.year)
        }
    }
    
    private var _monthSpent: Decimal?

    
    func monthSpent(monthyear: Monthyear) -> Decimal {
        var amount: Decimal = 0.00
        
        guard let periodStart = monthyear.getPeriodStart, let periodEnd = monthyear.getPeriodEnd else {
            return 0
        }
        
        guard let trs = self.category?.transactions, let transactions = trs.allObjects as? [Transaction] else { return 0 }
        
        let monthTransactions = Set(transactions.filter {
            guard let createdon = $0.createdon else {
                ErrorHandler.shared.reportError(message: "BudgetViewVM: 89")
                return false
                
            }
            return createdon >= periodStart && createdon <= periodEnd
            
        })
        
        if(self.category?.itemType == CategoryType.income) {
            amount = monthTransactions.reduce(0) { $0 + $1.getAmountTo().amount }
        } else {
            amount = monthTransactions.reduce(0) { $0 + $1.getAmount().amount }
        }
        return amount
    }
    
    
    var itemType: CategoryType {
        get {
            guard let type = self.type, let categoryType = CategoryType(rawValue: type) else {
                fatalError()
            }
            return categoryType
        }
    }
    
        
    func create(type: CategoryType, properties: PropertyContainer) {
        self.setValue(type.rawValue, forKey: "type")
        
        for property in properties.getProperties() {
            switch property.name {
            case "monthyear":
                if let monthyear = property.value as? Monthyear {
                    self.setValue(monthyear.month, forKey: "month")
                    self.setValue(monthyear.year, forKey: "year")
                }
            case "amount":
                if let amount = properties.getPropertyValue(name: property.name) as? NSDecimalNumber {
                    self.setValue(amount, forKey: "amount")
                }
            case "monthly":
                // Надо найти категорию и установить для нее значение повторяемости
                if let value = property.value as? NSNumber {
                    if let amount = properties.getPropertyValue(name: "amount") as? NSDecimalNumber, let category = properties.getPropertyValue(name: "category") as? Category {
                        category.amount = amount
                        category.monthly = value
                    }
                }
            default:
                self.setValue(property.value, forKey: property.name)
            }
            
        }
    }
    
    func update(properties: PropertyContainer) {
        
        for property in properties.getUpdatedProperties() {
            switch property.name {
            case "monthyear":
                if let monthyear = property.value as? Monthyear {
                    self.setValue(monthyear.month, forKey: "month")
                    self.setValue(monthyear.year, forKey: "year")
                }
            case "amount":
                if let amount = properties.getPropertyValue(name: property.name) as? NSDecimalNumber {
                    self.setValue(amount, forKey: "amount")
                }
            case "monthly":
                // Надо найти категорию и установить для нее значение повторяемости
                if let value = property.value as? NSNumber {
                    self.category?.monthly = value
                }
            default:
                self.setValue(property.value, forKey: property.name)
            }
        }
    }
    
    func getProperties() -> PropertyContainer {
        var properties = PropertyContainer()
        for (name, values) in  self.entity.propertiesByName {
            if let _ = values as? NSAttributeDescription {
                if let value = self.value(forKey: name) {
                    properties.setProperty(name: name, value: value)
                }
            } else if let a = values as? NSRelationshipDescription, !a.isToMany {
                if let value = self.value(forKey: name) {
                    properties.setProperty(name: name, value: value)
                }
            }
            if let monthly = self.category?.monthly {
                properties.setProperty(name: "monthly", value: monthly)
            } else {
                properties.setProperty(name: "monthly", value: true)
            }
        }
        return properties
    }
    
}
