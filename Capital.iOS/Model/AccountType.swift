//
//  AccountType.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 03/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

enum AccountType: String, ItemType {
    case cash
    case asset
    case credit
    case debt
    
    init?(id : Int) {
        switch id {
        case 0: self = .cash
        case 1: self = .asset
        case 2: self = .credit
        case 3: self = .debt
        default: return nil
        }
    }
    
    var name: String {
        switch self {
        case .cash: return NSLocalizedString("Cash", comment: "")
        case .asset: return NSLocalizedString("Assets", comment: "")
        case .credit: return NSLocalizedString("Credits", comment: "")
        case .debt: return NSLocalizedString("Debts", comment: "")
        }
    }
    
    var icon: String {
        switch self {
        case .cash: return "wallet"
        case .asset: return "funds"
        case .credit: return "credit-card"
        case .debt: return "bank"
        }
    }
    
    var accountName: String {
        switch self {
        case .cash: return "Счёт"
        case .asset: return "Актив"
        case .credit: return "Кредитная карта"
        case .debt: return "Обязательство"
        }
    }
    
    // Indicate if account is debit or credit
    var isreceipt: Bool {
        switch self {
        case .cash: return true
        case .asset: return true
        case .credit: return false
        case .debt: return false
        }
    }
    
    var section: Int {
        switch self {
        case .cash: return 0
        case .asset: return 1
        case .credit: return 2
        case .debt: return 3
        }
    }
    
    var cells: [Field] {
        switch self {
        case .cash:
            return [ Field.name(property: "name"), Field.balance(property: "balance"), Field.currency(property: "currencyCode", title: "Валюта") ]
        case .asset:
            return [ Field.name(property: "name"), Field.balance(property: "balance"), Field.amount(property: "goal", title: "Цель"), Field.currency(property: "currencyCode", title: "Валюта") ]
        case .credit:
            return [ Field.name(property: "name"), Field.balance(property: "balance"), Field.amount(property: "limit", title: "Кредитный лимит"), Field.currency(property: "currencyCode", title: "Валюта") ]
        case .debt:
            return [ Field.name(property: "name"), Field.balance(property: "balance"), Field.currency(property: "currencyCode", title: "Валюта") ]
        }
    }
}
