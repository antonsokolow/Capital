//
//  Monthyear.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 12/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import Foundation
import CoreData

struct Monthyear {
    var value: (month: Int, year: Int) {
        get {
            return (self.month, self.year)
        }
        
        set {
            self.month = newValue.month
            self.year = newValue.year
        }
    }
    
    var name: String {
        get {
            if(Monthyear.getNow().year == year) {
                return DateFormatter().standaloneMonthSymbols[month].capitalized
            }
            return DateFormatter().standaloneMonthSymbols[month].capitalized + " " + "\(year)"
        }
    }
    
    var month: Int
    var year: Int
    
    init(month: Int, year: Int) {
        self.month = month
        self.year = year
    }
    
    init(month: Int64, year: Int64) {
        self.month = Int(month)
        self.year = Int(year)
    }
    
    init(monthyear: (month: Int, year: Int)) {
        self.month = monthyear.month
        self.year = monthyear.year
    }
    
    mutating func set(month: Int, year: Int) {
        self.month = value.month
        self.year = value.year
    }
    
    static func getNow() -> Monthyear {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        guard let month = Int(dateFormatter.string(from: now)) else {
            fatalError()
        }
        dateFormatter.dateFormat = "yyyy"
        guard let year = Int(dateFormatter.string(from: now)) else {
            fatalError()
        }
        let monthyear = Monthyear(month: month-1, year: year)
        
        return monthyear
    }
    
    func getExpense() -> Decimal {
        var expense: Decimal = 0.0
        let context = DataHandler.shared.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let predicate = NSPredicate(format: "type == %@ AND month == %@ AND year == %@", argumentArray: ["expense", self.month, self.year])
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Budget {
                    expense += item.amount! as Decimal
                }
            }
        } catch {
            fatalError()
        }
        
        return expense
    }
    
    func getIncome() -> Decimal {
        var income: Decimal = 0.0
        let context = DataHandler.shared.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let predicate = NSPredicate(format: "type == %@ AND month == %@ AND year == %@", argumentArray: ["income", self.month, self.year])
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Budget {
                    income += item.amount! as Decimal
                }
            }
        } catch {
            fatalError()
        }
        
        return income
    }
    
    func getBudgetExpense() -> Money {
        var expense: Decimal = 0.0
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let predicate = NSPredicate(format: "type == %@ AND month == %@ AND year == %@", argumentArray: ["expense", self.month, self.year])
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try DataHandler.shared.viewContext.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Budget {
                    expense += item.amount! as Decimal
                }
            }
        } catch {
            fatalError()
        }
        
        return Money(amt: expense, currency: Money.baseCurrency)
    }
    
    func getBudgetIncome() -> Money {
        var income: Decimal = 0.0
        let context = DataHandler.shared.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let predicate = NSPredicate(format: "type == %@ AND month == %@ AND year == %@", argumentArray: ["income", self.month, self.year])
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let item = data as? Budget {
                    income += item.amount! as Decimal
                }
            }
        } catch {
            fatalError()
        }
        
        return Money(amt: income, currency: Money.baseCurrency)
    }
    
    func getStartBalance() {
        let now = Monthyear.getNow()
        if self > now {
            // Считаем планируемый остаток
            
        } else {
            // Показываем начальный баланс текущего месяца
            
        }
    }
}

extension Monthyear {
    var getPeriodStart: Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        
        components.month = self.value.month+1
        components.year = self.value.year
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy" //give the formate according to your need
        
        if let newDate = calendar.date(from: components) {
            return newDate
        }
        return nil
    }

    var getPeriodEnd: Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        
        components.month = self.value.month+1
        components.year = self.value.year
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy" //give the formate according to your need
        
        if let newDate = calendar.date(from: components) {
            return newDate.getNextMonth()
        }
        return nil
    }
}

extension Monthyear: Equatable {
    static func > (lhs: Monthyear, rhs: Monthyear) -> Bool {
        return (lhs.year > rhs.year)  || (lhs.year == rhs.year && lhs.month > rhs.month)
    }
    
    static func < (lhs: Monthyear, rhs: Monthyear) -> Bool {
        return (lhs.year < rhs.year)  || (lhs.year == rhs.year && lhs.month < rhs.month)
    }
    
    static func == (lhs: Monthyear, rhs: Monthyear) -> Bool {
        return (lhs.year == rhs.year && lhs.month == rhs.month)
    }
}

extension Monthyear: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(month)
        hasher.combine(year)
    }
}

extension Monthyear {
    
    func getNextMonth() -> Monthyear {
        var nextMonth = self
        if self.month == 11 {
            nextMonth.month = 0
            nextMonth.year += 1
        } else {
            nextMonth.month += 1
        }
        return nextMonth
    }
    
    func getPreviousMonth() -> Monthyear {
        var previousMonth = self
        if self.month == 0 {
            previousMonth.month = 11
            previousMonth.year -= 1
        } else {
            previousMonth.month -= 1
        }
        return previousMonth
    }
}
