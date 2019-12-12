//
//  DataHandler.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 06/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import Foundation
import CoreData

class DataHandler {
    static var shared = DataHandler()
    
    var isReadyToSave: Bool?
    
    private init() {
        // Show core data file path
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print("Core data file path:", paths[0])
        
        // Слушаем изменения в Core Data
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    lazy var cacheContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    lazy var updateContext: NSManagedObjectContext = {
        let _updateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        //_updateContext.parent = self.viewContext
        return _updateContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                ErrorHandler.shared.reportError(message: "DataHandler: 77 \(error), \(error.userInfo)")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveUpdateContext() {
        let context = updateContext
        if context.hasChanges {
            do {
                try context.save()
                viewContext.performAndWait {
                    do {
                        try viewContext.save()
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    @objc func contextObjectsDidChange(_ notification: Notification) {
        // Сохраняем данные на диск 
        
        if(isReadyToSave ?? false) { return }
        isReadyToSave = true
        delay(delay: 2) { [unowned self] in
            self.saveContext()
            self.isReadyToSave = false
        }

    }
}
