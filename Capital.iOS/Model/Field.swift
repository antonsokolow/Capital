//
//  Field.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 19/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

enum Field {
    case account(types: [AccountType], property: String, title: String)
    case category(type: CategoryType, property: String)
    case amount(property: String, title: String)
    case balance(property: String)
    case name(property: String)
    case namewithicon(property: String)
    case cash(property: String, isreceipt: Bool, account: String)
    case date(property: String)
    case monthyear(property: String)
    case datePicker(property: String)
    case monthPicker(property: String)
    case comment(property: String)
    case textView(property: String)
    case checkbox(property: String, title: String)
    case button(property: String, title: String, action: () -> Void)
    case currency(property: String, title: String)
    
    
    var id: String {
        switch self {
        case .account: return "account"
        case .category: return "category"
        case .amount: return "amount"
        case .balance: return "balance"
        case .name: return "name"
        case .namewithicon: return "namewithicon"
        case .cash: return "cash"
        case .date: return "date"
        case .monthyear: return "monthyear"
        case .datePicker: return "datePicker"
        case .monthPicker: return "monthPicker"
        case .comment: return "comment"
        case .textView: return "textView"
        case .checkbox: return "switch"
        case .button: return "button"
        case .currency: return "currency"
        }
    }
    
    var name: String {
        switch self {
        case .account: return "Счёт"
        case .category: return "Категория"
        case .amount: return "Сумма"
        case .balance: return "Баланс"
        case .name: return "Название"
        case .namewithicon: return "Название"
        case .cash: return "Транзакция"
        case .date: return "Дата"
        case .monthyear: return "Период"
        case .datePicker: return "Выбор даты"
        case .monthPicker: return "Выбор месяца"
        case .comment: return "Комментарий"
        case .textView: return "Комментарий"
        case .checkbox: return ""
        case .button: return "Удалить"
        case .currency: return "Валюта"
        
        }
    }
    
    var cellIdentifier: String {
        switch self {
        case .account: return "AccountCell"
        case .category: return "CategoryCell"
        case .amount: return "AmountCell"
        case .balance: return "BalanceCell"
        case .name: return "NameCell"
        case .namewithicon: return "NameWithIconCell"
        case .cash: return "CashCell"
        case .date: return "DateCell"
        case .monthyear: return "MonthyearCell"
        case .datePicker: return "DatePickerCell"
        case .monthPicker: return "MonthPickerCell"
        case .comment: return "CommentCell"
        case .textView: return "TextViewCell"
        case .checkbox: return "SwitchCell"
        case .button: return "ButtonCell"
            case .currency: return "CurrencyCell"
        }
    }
}
