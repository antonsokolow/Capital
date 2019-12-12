//
//  AllDataStore.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 20.08.2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation

class AllDataStore {
    static var shared = AllDataStore()
    
    private init() { }
    
    var accounts = [Account]()
    var categories = [Category]()
    var budget = [Budget]()
    var transactions = [Monthyear: [Transaction]]()
    
}


