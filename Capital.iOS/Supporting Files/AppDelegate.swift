//
//  AppDelegate.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 01/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData
import SQLite3
import zlib
import AdSupport
import SystemConfiguration
import CoreLocation
import Security

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var updateCurrencyRatesStarted = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        preloadData()
        //updateData()
        reachability()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        var vc: UIViewController
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil) //UIStoryboard(name: "OnboardingVC", bundle: nil)
        vc = storyboard.instantiateInitialViewController()!
        
        self.window?.rootViewController = vc
        
        
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        DataHandler.shared.saveContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //AppEventsLogger.activate(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DataHandler.shared.saveContext()
    }
    
    private func preloadData() {
        let preloadedDataKey = "didPreloadData"
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: preloadedDataKey) == true { return }
            
        guard let urlPath = Bundle.main.url(forResource: "PreloadedData", withExtension: "plist") else {
            return
        }
        
        if let data = NSDictionary(contentsOf: urlPath) {

            if let categories = data["Categories"] as? NSArray {
                for item in categories {
                    if let category = item as? NSDictionary, let name = category["name"] as? String, let type = category["type"] as? String, let order = category["order"] as? Int64, let icon = category["icon"] as? String, let comment = category["comment"] as? String {
                        let categoryObject = Category(context: DataHandler.shared.viewContext)
                        categoryObject.name = name
                        categoryObject.type = type
                        categoryObject.order = order
                        categoryObject.icon = icon
                        if comment.isEmpty {
                            categoryObject.comment = "Подсказка с описанием как использовать категорию"
                        } else {
                            categoryObject.comment = comment
                        }
                    }
                }
            }
            //try backgroundContext.save()
            //DataHandler.shared.saveContext()
            userDefaults.set(true, forKey: preloadedDataKey)
        
            
        }
    }
    
    private func updateData() {
            
            guard let urlPath = Bundle.main.url(forResource: "PreloadedData", withExtension: "plist") else {
                return
            }
        
                if let data = NSDictionary(contentsOf: urlPath) {
                    let commentText = "Подсказка с описанием как использовать категорию"
                    if let categories = data["Categories"] as? NSArray {
                        for item in categories {
                            if let category = item as? NSDictionary, let name = category["name"] as? String, let icon = category["icon"] as? String, let comment = category["comment"] as? String {
                                if let storedCategory =  DataStore.shared.getCategoryByName(name: name) {
                                    if storedCategory.comment == nil {
                                        if comment.isEmpty {
                                            storedCategory.comment = commentText
                                        } else {
                                            storedCategory.comment = comment
                                        }
                                        storedCategory.icon = icon
                                        
                                    }
                                }
                            }
                        }
                    }
                    //DataHandler.shared.saveContext()
                    
                }

        
    }
    
    
    func reachability() {
        do {
            Network.reachability = try Reachability(hostname: "https://kapital-app.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                ErrorHandler.shared.reportError(message: "AppDelegare: 144, \(error)")
            } catch {
                ErrorHandler.shared.reportError(message: "AppDelegare: 146, \(error)")
            }
        } catch {
            ErrorHandler.shared.reportError(message: "AppDelegare: 149, \(error)")
        }
    }
    
    func updateCurrencyRates() {
        if(updateCurrencyRatesStarted) { return }
        updateCurrencyRatesStarted = true
        
        if let updated = UserDefaults.standard.value(forKey: "CurrencyRatesUpdated") as? Int {
            let timeInterval = Int(Date().timeIntervalSince1970)
            if timeInterval - updated < 24 * 3600 * 60 {
                
                return
            }
        }

        ErrorHandler.shared.reportEvent(message: "Update Currency Rates")
        
        background {
            Fixer.updateCurrencyRates() {
                main {
                    let exchageData = DataStore.shared.getCurrencyRates().filter { $0.currency != nil }
                    
                    Money.exchange_rates = Set(exchageData.map {
                        ExchangeRate(currency: $0.currency!, rate: Decimal($0.rate))
                        
                    })
                    self.updateCurrencyRatesStarted = false
                }
            }
            
        }
    }
    
    @objc func statusManager(_ notification: Notification) {
        if Net.shared.isConnectedToNetwork() == true {
            if(!updateCurrencyRatesStarted) {
                updateCurrencyRates()
            }
        }
    }

}
