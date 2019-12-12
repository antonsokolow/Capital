//
//  Fixer.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 30/01/2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation
import CoreData
import os.log

struct Fixer {
    static let apiEndPoint = "https://data.fixer.io/api/latest?access_key=8e3c8f3baf23a1582fe3fdec7fa258dd&format=1&base=\(Money.baseCurrencyCode)"
    
    static func updateCurrencyRates(completion: @escaping () -> ()) {
        if Net.shared.isConnectedToNetwork() != true {
            completion()
            return
        }
        
        var exchangeRates = [String: Double]()
        
        
        guard let url = NSURL(string: apiEndPoint) else {
            ErrorHandler.shared.reportError(message: "Fixer: 23")
            completion()
            return
        }
        
        let urlRequest = NSURLRequest(url: url as URL)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            // 1
            guard error == nil else {
                ErrorHandler.shared.reportError(message: "Fixer: 38, \(String(describing: error))")
                completion()
                return
            }
            // 2
            if let httpResponse = response as? HTTPURLResponse {
                //3
                if httpResponse.statusCode == 200 {
                    print("Everything is ok")
                }
                else {
                    print("Error fetching data")
                }
            }
            // 4
            guard let data = data else {
                ErrorHandler.shared.reportError(message: "Fixer: 54")
                completion()
                return
            }
            do {
                guard let exchangeDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                    ErrorHandler.shared.reportError(message: "Fixer: 60") //Could not convert JSON to dictionary
                    completion()
                    return
                }
                if let rates = exchangeDict["rates"] as? [String: Double] {
                    for rate in rates {
                        exchangeRates[rate.key] = rate.value
                        
                        
                        //Проверяем есть ли такая валюта в базе
                        let predicate = NSPredicate(format: "symbol == %@", rate.key)
                        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRate")
                        request.predicate = predicate
                        request.returnsObjectsAsFaults = false
                        
                        do {
                            let result = try DataHandler.shared.viewContext.fetch(request)
                            if(result.count < 1) {
                                //Если валюты в базе нет, то сохраняем
                                let currencyRate = CurrencyRate(context: DataHandler.shared.viewContext)
                                currencyRate.symbol = rate.key
                                currencyRate.rate = rate.value
                                
                                if let symbol = Currency(rawValue: rate.key), [Currency.EUR, Currency.GBP, Currency.RUB, Currency.USD].contains(symbol) {
                                    currencyRate.isFavorite = true
                                }
                            } else {
                                //Если валюта в базе есть обновляем значение
                                let currencyRate = result[0] as! CurrencyRate
                                currencyRate.symbol = rate.key
                                currencyRate.rate = rate.value
                            }
                        } catch {
                                ErrorHandler.shared.reportError(message: "Fixer: 89")
                        }
                    }
                }                // 5
                if let date = exchangeDict["date"] as? String, let updated = exchangeDict["timestamp"] as? Int {
                    print("updated:", date, updated)
                    //DataHandler.shared.saveContext()
                    UserDefaults.standard.set(updated, forKey: "CurrencyRatesUpdated")
                    UserDefaults.standard.set(Money.baseCurrencyCode, forKey: "BaseCurrencyCode")
                    completion()
                }
            }
            catch {
                ErrorHandler.shared.reportError(message: "Fixer: 102") //Error trying to convert JSON to dictionary
            }
        }
        // 5
        task.resume()
        
    }
}
