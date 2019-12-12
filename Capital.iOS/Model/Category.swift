//
//  Category.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 03/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData

public class Category: NSManagedObject, Item {
    
    var itemType: CategoryType {
        get {
            guard let type = self.type, let categoryType = CategoryType(rawValue: type) else {
                fatalError("Не указан тип категории! Какой ужас!!!")
            }
            return categoryType
        }
    }
    
    func create(type: CategoryType, properties: PropertyContainer) {
        guard let name = properties.getPropertyValue(name: "name") as? String else {
            fatalError()
        }
        
        if let comment = properties.getPropertyValue(name: "comment") as? String {
            self.comment = comment
        }
        
        let icon = properties.getPropertyValue(name: "icon") as? String ?? "funds"
        self.name = name
        self.type = type.rawValue
        self.icon = icon
    }
    
    func update(properties: PropertyContainer) {
        for property in properties.getUpdatedProperties() {
            self.setValue(property.value, forKey: property.name)
        }
    }
    
    func getBudget(createdon: Date) -> Budget? {
        var budget: Budget?
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy"
        guard let year = Int(dateFormatter.string(from: createdon)) else {
            return nil
        }
        
        dateFormatter.dateFormat = "M"
        guard let month = Int(dateFormatter.string(from: createdon)) else {
            return nil
        }
        
        let context = DataHandler.shared.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let predicate = NSPredicate(format: "category == %@ AND month == %@ AND year == %@", argumentArray: [self, month-1, year])
        //let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        //request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                if let item = result[0] as? NSManagedObject {
                    budget = item as? Budget
                }
            }
        } catch {
            print("Failed", "getItems")
        }
        
        return budget
    }
    
    func getProperties() -> PropertyContainer {
        var properties = PropertyContainer()
        for (name, _) in  self.entity.attributesByName {
            if let value = self.value(forKey: name){
                properties.setProperty(name: name, value: value)
            }
        }
        return properties
    }
}
