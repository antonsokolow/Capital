//
//  CurrencyListCellVM.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 18.08.2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation

class CurrencyListCellVM {
    private var currencyRate: CurrencyRate
    
    var symbol: String {
        return currencyRate.symbol ?? ""
    }
    var rate: Double {
        return currencyRate.rate
    }
    
    var rateString: String {
        return String(format:"%.2f", currencyRate.inverseRate)
    }
    
    var isFavorite: Bool {
        return currencyRate.isFavorite
    }
    
    
    init(currencyRate: CurrencyRate) {
        self.currencyRate = currencyRate
    }
    
    func toggleFavorite() {
        currencyRate.isFavorite = !currencyRate.isFavorite
        if let reload = reload {
            reload(currencyRate)
        }
    }
    
    var reload: ((_ currencyRate: CurrencyRate) -> Void)?
    
}
