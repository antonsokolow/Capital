//
//  DataModel.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 01/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import Foundation
import CoreData

class BudgetDataModel {
    var categoryType: CategoryType?
    var isExpanded = false
    
    init(headerName: CategoryType, isExpandable: Bool) {
        self.categoryType = headerName
        self.isExpanded = isExpandable
    }
}

class AccountDataModel {
    var accountType: AccountType?
    var accounts = [Account]()
    var isExpanded = false
    
    init(headerName: AccountType, subType: [Account], isExpandable: Bool) {
        self.accountType = headerName
        self.accounts = subType
        self.isExpanded = isExpandable
    }
}

class AccountTableViewModel {
    var accountType: AccountType?
    var isExpanded = false
    
    init(headerName: AccountType, isExpandable: Bool) {
        self.accountType = headerName
        self.isExpanded = isExpandable
    }
}

class TableDataModel {
    var header: Any?
    var rows = [Any]()
    var isExpanded = false
    
    init(header: Any, rows: [Any], isExpandable: Bool) {
        self.header = header
        self.rows = rows
        self.isExpanded = isExpandable
    }
}
