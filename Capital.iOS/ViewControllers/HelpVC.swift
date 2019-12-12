//
//  HelpVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 28/12/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import WebKit
import SystemConfiguration

class HelpVC: UIViewController {
    var webView: WKWebView!
    
    override func loadView() {
        let congiguration = WKWebViewConfiguration()
        congiguration.allowsInlineMediaPlayback = true
        congiguration.allowsPictureInPictureMediaPlayback = true
        congiguration.mediaTypesRequiringUserActionForPlayback = []
        webView = WKWebView(frame: .zero, configuration: congiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .lightContent .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateURL()

        webView.allowsBackForwardNavigationGestures = false
        
        navigationItem.title = NSLocalizedString("Help", comment: "Помощь")
        
        // Transparent navigation bar
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
        //self.navigationController?.navigationBar.tintColor = .red
        //self.navigationController?.navigationBar.barTintColor = KColor.darkBackground
    }
    
    func updateURL() {
        var url: URL
        if Net.shared.isConnectedToNetwork() == true {
            // Показываем online справку
            url = URL(string: "https://kapital-app.com/help-mobile.html")!
        } else {
            // показываем offline справку
            guard let path = Bundle.main.url(forResource: "www/help", withExtension: "html") else {
                ErrorHandler.shared.reportError(message: "HelpVC: 57")
                return
            }
            url = path
        }
        webView.load(URLRequest(url: url))
    }
    
    @objc func statusManager(_ notification: Notification) {
        updateURL()
    }
    
    @objc func backTapped() {
        webView.goBack()
    }

    
}

extension HelpVC: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.canGoBack {
            //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(backTapped))
            //navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back-filled"), style: .plain, target: self, action:  #selector(backTapped))
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action:  #selector(backTapped))
            navigationItem.leftBarButtonItem?.tintColor = .white
            //navigationItem.leftBarButtonItem?.setBackButtonBackgroundImage(UIImage(named: "back-filled"), for: .normal, barMetrics: .default)
            //navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
            
            //navigationItem.leftBarButtonItem?.image = UIImage(named: "back-filled")
            
//            //create a new button
//            let button = UIButton(type: .custom)
//            //set image for button
//            button.setImage(UIImage(named: "back-filled"), for: .normal)
//            //add function for button
//            button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
//            //set frame
////            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
////            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
//            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//
//            let barButton = UIBarButtonItem(customView: button)
//            //assign button to navigationbar
//            navigationItem.leftBarButtonItem = barButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    
}

