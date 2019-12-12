//
//  ErrorHandler.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 22.08.2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation
import YandexMobileMetrica
import YandexMobileMetricaCrashes
import os.log

class ErrorHandler {
    static var shared = ErrorHandler()
    
    var debug = false
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
    let dateFormatter = DateFormatter()
    
    private init() {
        print("Инициализация AppMetrica SDK")
        // Инициализация AppMetrica SDK.
        #if DEBUG
            self.debug = true
        #else
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return
        }
        if (bundleIdentifier == "biz.deasoft.ios.capital") {
            // Капитал классик
            let configuration = YMMYandexMetricaConfiguration.init(apiKey: "e237cee8-cef1-463d-af8c-b355a87b11dc")
            YMMYandexMetrica.activate(with: configuration!)
        } else {
            // Капитал Realm
            let configuration = YMMYandexMetricaConfiguration.init(apiKey: "79f64d7e-458e-49a3-ab8f-9f41392f4717")
            YMMYandexMetrica.activate(with: configuration!)
        }
        #endif
    
    }
    
    func reportError(message: String) {
        
        let date = dateFormatter.string(from: Date())
        
        let result = "\(date)  version: \(appVersion)"
        let params : [String : Any] = [message: result]
        
        if(debug) {
            os_log("[Error] %{PUBLIC}@", log: OSLog.default, type: .error, message)
        } else {
            YMMYandexMetrica.reportEvent("Error", parameters: params, onFailure: nil)
        }
        
    }
    
    func reportEvent(message: String) {
        
        let date = dateFormatter.string(from: Date())
        
        let result = "\(date)  version: \(appVersion)"
        let params : [String : Any] = [message: result]
        
        if(debug) {
            os_log("[Event] %{PUBLIC}@", log: OSLog.default, type: .default, message)
        } else {
            YMMYandexMetrica.reportEvent("Event", parameters: params, onFailure: nil)
        }
    }

}
