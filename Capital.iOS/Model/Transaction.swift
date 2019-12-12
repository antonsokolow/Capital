//
//  Transaction.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 14/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData

public class Transaction: NSManagedObject, Item {
    
    var itemType: TransactionType {
        get {
            guard let type = self.type, let transactionType = TransactionType(rawValue: type) else {
                fatalError("Не указан тип счета! Какой ужас!!!")
            }
            return transactionType
        }
    }
    
    func getAmount(account: Account) -> Money {
        var amount: Decimal = 0.00
        if self.accountto == account {
            amount += self.amountto as Decimal? ?? 0.0
        }
        if self.account == account {
            amount -= self.amount as Decimal? ?? 0.0
        }
        return Money(amt: amount, currency: account.currency)
    }
    
    func getAmount() -> Money {
        guard let account = self.account, let amount = self.amount as Decimal? else { return Money(amt: 0, currency: Money.baseCurrency) }

        return Money(amt: amount, currency: account.currency)
    }
    
    func getAmountTo() -> Money {
        guard let account = self.accountto, let amount = self.amountto as Decimal? else { return Money(amt: 0, currency: Money.baseCurrency) }
        
        return Money(amt: amount, currency: account.currency)
    }

    func create(type: TransactionType, properties: PropertyContainer) {
        self.setValue(type.rawValue, forKey: "type")
        for property in properties.getProperties() {
            self.setValue(property.value, forKey: property.name)
        }
    }
    
    func update(properties: PropertyContainer) {
        
        for property in properties.getUpdatedProperties() {
            self.setValue(property.value, forKey: property.name)
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
        }
        
        return properties
    }
}
