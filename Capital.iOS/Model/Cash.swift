//
//  Entry.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 17/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import Foundation
import CoreData

public class Cash: NSManagedObject {

    
    
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
