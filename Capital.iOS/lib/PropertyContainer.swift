//
//  TransactionVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 04/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit


struct PropertyContainer {

    private var properties = [(name: String, value: Any?, isUpdated: Bool)]()

    /// Устанавливает свойство, связанное с именем.
    /// Если свойство уже существует, значение будет заменено.
    /// Если свойство не существует, оно будет добавлено со значением.
    ///
    /// - parameter name:        Имя параметра.
    ///
    /// - returns: Void.
    mutating func setProperty(name: String, value: Any?) {
        if let index = properties.firstIndex(where: {$0.name == name}) {
            properties[index].value = value
            properties[index].isUpdated = true
        } else {
            let property: (name: String, value: Any?, isUpdated: Bool) = (name: name, value: value, isUpdated: false)
            self.properties.append(property)
        }
    }
    
    /// Выборка свойства по имени.
    ///
    /// - parameter name:        Имя параметра.
    ///
    /// - returns: Property
    func getProperty(name: String) -> Any? {
        if let property = properties.first(where: {$0.name == name}) {
            return property
        } else {
            return nil
        }
        
    }
    
    /// Выборка значения свойства по имени.
    ///
    /// - parameter name:        Имя параметра.
    ///
    /// - returns: Any. Значение параметра.
    func getPropertyValue(name: String) -> Any? {
        if let property = properties.first(where: {$0.name == name}) {
            return property.value
        } else {
            return nil
        }
        
    }
    
    /// Выборка всех имеющихся свойст.
    ///
    /// - returns: [String]. Возвращает массив имен параметров.
    func getProperties() -> [(name: String, value: Any?, isUpdated: Bool)] {
        
        return properties
    }
    
    /// Выборка всех имеющихся свойст.
    ///
    /// - returns: [String]. Возвращает массив имен параметров.
    func getUpdatedProperties() -> [(name: String, value: Any?, isUpdated: Bool)] {
        return properties.filter({$0.isUpdated == true})
    }
    
    /// Удаление свойства, связанного с определенным именем.
    ///
    /// - parameter name:        Имя параметра.
    ///
    /// - returns: Void.
    mutating func removeProperty(name: String) {
        if let index = properties.firstIndex(where: {$0.name == name}) {
            properties.remove(at: index)
        }
    }
    
    /// Удаление всех дополнительных свойств.
    ///
    /// - parameter name:        Имя параметра.
    ///
    /// - returns: Void.
    func removeProperties() {
        
    }
}
