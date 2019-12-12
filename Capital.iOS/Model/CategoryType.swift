//
//  CategoryType.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 03/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

enum CategoryType:  String, ItemType {
    case income
    case expense
    //case investment
    //case obligation
    
    init?(id : Int) {
        switch id {
        case 0: self = .income
        case 1: self = .expense
        //case 2: self = .investment
        //case 3: self = .obligation
        default: return nil
        }
    }
    
    var name: String {
        switch self {
        case .income: return NSLocalizedString("Revenue", comment: "")
        case .expense: return NSLocalizedString("Expenses", comment: "")
        //case .investment: return "Инвестиции"
        //case .obligation: return "Погашение обязательств"
        }
    }
    
    var color: UIColor {
        switch self {
        case .income: return KColor.greenText
        case .expense: return KColor.redText
        }
    }
    
    var section: Int {
        switch self {
        case .income: return 0
        case .expense: return 1
        }
    }
    
    // Поля для отображения карточки Бюджета
    var cells: [Field] {
        switch self {
        case .expense:
            return [
                Field.category(type: CategoryType.expense, property: "category"),
                Field.amount(property: "amount", title: "Бюджет"),
                Field.checkbox(property: "monthly", title: "Повторять каждый месяц"),
                Field.textView(property: "comment"),
                Field.button(property: "delete", title: "Удалить", action: {})
            ]
        case .income:
            return [
                Field.category(type: CategoryType.income, property: "category"),
                Field.amount(property: "amount", title: "Бюджет"),
                Field.checkbox(property: "monthly", title: "Повторять каждый месяц"),
                Field.textView(property: "comment"),
                Field.button(property: "delete", title: "Удалить", action: {})
            ]
        }
    }
}
