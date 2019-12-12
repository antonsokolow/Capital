//
//  ExchangeRates.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 19.08.2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation

class ExchangeRates {
    static var shared = ExchangeRates()
    
    var exchange_rates: Set<ExchangeRate> = Set()
    
    var exchangeRates = [String: Decimal]()
    
    var accounts: [Account] = []
    var budgets: [Budget] = []
    var categories: [Category] = []
    var transactions: [Transaction] = []
    
    private init() {
        let exchageData = DataStore.shared.getCurrencyRates().filter { $0.currency != nil }
        
        exchange_rates = Set(exchageData.map {
            ExchangeRate(currency: $0.currency!, rate: Decimal($0.rate))
            
        })
    }
}
