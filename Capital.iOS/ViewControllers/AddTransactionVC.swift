//
//  addTransactionVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 04/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class AddTransactionVC: UIViewController {
    
    private var transactionTitle: String? {
        didSet{
            selectTypeButton.setTitle((transactionTitle ?? "") + "  ", for: .normal)
        }
    }
    let selectTypeButton =  UIButton(type: .custom)
    private var controller: AccountVC?
    private var selectController: SelectTransactionTypeVC?
    var transaction = TransactionType.expense
    
    static func storyboardInstance() -> AddTransactionVC? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "AddTransactionVC") as? AddTransactionVC
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .lightContent .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background2")!)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem?.isEnabled = false
        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        // Remove transparent navigation bar
//        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = nil
//        self.navigationController?.navigationBar.tintColor = .white
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.barTintColor = KColor.darkBackground
        
        
        showSelectTypeButton()
        presentTransactionVC()
    }
    
    
    func unlockSaveButton(value: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = value
    }
    
    func setTransactionVC(transaction: TransactionType) {
        self.transaction = transaction
        //controller.view.removeFromSuperview()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.setHidesBackButton(false, animated:false);
        selectTypeButton.setImage(UIImage(named: "navigate-up-arrow"), for: .normal)
        selectTypeButton.isEnabled = true
        presentTransactionVC()
        transactionTitle = transaction.name
    }
    
    private func presentTransactionVC() {
        if let viewController = self.controller {
            // Обновляем контроллер
            viewController.entity = Entity.transaction(type: transaction)
            viewController.prepareData()
            viewController.tableView.reloadData()
        } else if let viewController = AccountVC.storyboardInstance() {
            // создаем новый контроллер
            controller = viewController
            viewController.entity = Entity.transaction(type: transaction)
            viewController.properties.setProperty(name: "createdon", value: Date())
            //viewController.delegate = self
            viewController.unlockSave = unlockSaveButton
            addChild(viewController)
            view.addSubview(viewController.view)
            //controller.didMove(toParent: self)
        }
    }
    

    
    func presentSelectVC(name: String) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "SelectTransactionTypeVC") as? SelectTransactionTypeVC {
            //viewController.delegate = self
            viewController.setTransactionVC = setTransactionVC
            viewController.transactionId = transaction
            
            selectController = viewController
            addChild(viewController)
            view.addSubview(viewController.view)
            //selectController.didMove(toParent: self)
        }
        
        
    }
    
    func showSelectTypeButton() {
        selectTypeButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        selectTypeButton.setTitleColor(UIColor.white, for: .normal)
        transactionTitle = transaction.name
        selectTypeButton.titleEdgeInsets.left = 0
        selectTypeButton.setImage(UIImage(named: "navigate-up-arrow"), for: .normal)
        selectTypeButton.setImage(UIImage(named: "navigate-down-arrow"), for: .selected)
        
        selectTypeButton.semanticContentAttribute = .forceRightToLeft
        selectTypeButton.addTarget(self, action: #selector(self.clickOnSelectTypeButton), for: .touchUpInside)
        selectTypeButton.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.navigationItem.titleView = selectTypeButton
    }
    

    @objc func clickOnSelectTypeButton(button: UIButton) {
        
        selectTypeButton.isEnabled = false
        selectTypeButton.setImage(UIImage(named: "navigate-down-arrow"), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        self.navigationItem.setHidesBackButton(true, animated:false);
        //controller.view.removeFromSuperview()
        presentSelectVC(name: "SelectTransactionTypeVC")
    }
    
    @objc func done() {
        //self.navigationItem.setHidesBackButton(false, animated:true);
        if let selectController = selectController {
            selectController.done()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.setHidesBackButton(false, animated:false);
        selectTypeButton.setImage(UIImage(named: "navigate-up-arrow"), for: .normal)
        selectTypeButton.isEnabled = true
        //controller.view.removeFromSuperview()
        //presentVC(name: transaction.viewController)
    }
    
    @objc func save() {
        if let controller = controller {
            controller.saveData()
        }
        navigationController?.popViewController(animated: true)
    }

}


