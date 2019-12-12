//
//  TransactionType.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 04/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

enum TransactionType: String, ItemType {
    case expense
    case income
    case transfer
    case balance
    case asset
    case assetsell
    case takingcredit
    case repayment
    case new
    case newdebet
    case newcredit
    
    init?(id : Int) {
        switch id {
        case 0: self = .expense
        case 1: self = .income
        case 2: self = .transfer
        case 3: self = .asset
        case 4: self = .assetsell
        case 5: self = .takingcredit
        case 6: self = .repayment
        default: return nil
        }
    }
    
    var name: String {
        switch self {
        case .expense: return NSLocalizedString("Расход", comment: "Default action")
        case .income: return NSLocalizedString("Доход", comment: "Default action")
        case .transfer: return NSLocalizedString("Перевод средств", comment: "Default action")
        case .balance: return NSLocalizedString("Корректировка баланса", comment: "Default action")
        case .asset: return NSLocalizedString("Покупка актива", comment: "Default action")
        case .assetsell: return NSLocalizedString("Продажа актива", comment: "Default action")
        case .takingcredit: return NSLocalizedString("Взятие обязательств", comment: "Default action")
        case .repayment: return NSLocalizedString("Погашение обязательств", comment: "Default action")
        case .new: return NSLocalizedString("Начальный баланс", comment: "Default action")
        case .newdebet: return NSLocalizedString("Начальный баланс", comment: "Default action")
        case .newcredit: return NSLocalizedString("Начальный баланс", comment: "Default action")
        }
    }
    
    var cells: [Field] {
        switch self {
        case .expense:
            return [ Field.account(types: [AccountType.cash, AccountType.credit], property: "account", title: "Наличность"), Field.category(type: CategoryType.expense, property: "category"), Field.amount(property: "amount", title: "Сумма"), Field.date(property: "createdon"), Field.comment(property: "comment") ]
        case .income:
            return [ Field.account(types: [AccountType.cash], property: "accountto", title: "Наличность"), Field.category(type: CategoryType.income, property: "category"), Field.amount(property: "amountto", title: "Сумма"), Field.comment(property: "comment"), Field.date(property: "createdon") ]
        case .transfer:
            return [ Field.account(types: [AccountType.cash, AccountType.credit, AccountType.asset, AccountType.debt], property: "account", title: "Счёт"), Field.amount(property: "amount", title: "Сумма"), Field.account(types: [AccountType.cash, AccountType.credit, AccountType.debt, AccountType.asset], property: "accountto", title: "Счёт (куда)"), Field.amount(property: "amountto", title: "Сумма"), Field.date(property: "createdon"), Field.comment(property: "comment") ]
        case .balance:
            return [ Field.balance(property: "balance"), Field.date(property: "createdon") ]
        case .asset:
            return [ Field.account(types: [AccountType.cash, AccountType.credit], property: "account", title: "Наличность"), Field.amount(property: "amount", title: "Сумма"), Field.account(types: [AccountType.asset], property: "accountto", title: "Актив"), Field.amount(property: "amountto", title: "Сумма"), Field.date(property: "createdon"), Field.category(type: CategoryType.expense, property: "category") ]
        case .assetsell:
            return [ Field.account(types: [AccountType.asset], property: "account", title: "Наличность"), Field.amount(property: "amount", title: "Сумма"), Field.account(types: [AccountType.cash], property: "accountto", title: "Актив"), Field.amount(property: "amountto", title: "Сумма"), Field.date(property: "createdon"), Field.category(type: CategoryType.income, property: "category") ]
        case .takingcredit:
            return [ Field.account(types: [AccountType.credit, AccountType.debt], property: "account", title: "Обязательство"), Field.amount(property: "amount", title: "Сумма"), Field.account(types: [AccountType.cash, AccountType.credit], property: "accountto", title: "Наличность"), Field.amount(property: "amountto", title: "Сумма"), Field.date(property: "createdon"), Field.category(type: CategoryType.income, property: "category") ]
        case .repayment:
            return [ Field.account(types: [AccountType.cash, AccountType.credit], property: "account", title: "Наличность"), Field.amount(property: "amount", title: "Сумма"), Field.account(types: [AccountType.credit, AccountType.debt], property: "accountto", title: "Обязательство"), Field.amount(property: "amountto", title: "Основной долг"), Field.category(type: CategoryType.expense, property: "category"), Field.date(property: "createdon"), Field.comment(property: "comment") ]
        case .new:
            return [ Field.amount(property: "amount", title: "Сумма"), Field.comment(property: "comment"), Field.date(property: "createdon") ]
        case .newdebet:
            return [ Field.amount(property: "amountto", title: "Сумма"), Field.comment(property: "comment"), Field.date(property: "createdon") ]
        case .newcredit:
            return [ Field.amount(property: "amount", title: "Сумма"), Field.comment(property: "comment"), Field.date(property: "createdon") ]
        }
    }

}
