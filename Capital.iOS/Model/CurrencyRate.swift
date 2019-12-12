//
//  Currency.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 30/01/2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation
import CoreData

public class CurrencyRate: NSManagedObject {
    var currency: Currency? {
        get {
            guard let symbol = self.symbol else { return nil }
            return Currency(rawValue: symbol)
        }
    }
    
    var inverseRate: Double {
        get{
            return 1/rate
        }
    }
}
