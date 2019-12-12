//
//  TransactionListVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 08/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData

class TransactionListVC: UIViewController {
    
    static func storyboardInstance() -> TransactionListVC? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TransactionListVC") as! TransactionListVC
        return controller
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monthYearPickerView: UIView!
    @IBOutlet weak var textFieldPicker: UITextField!
    private var datePicker: MonthYearPickerView?
    @IBOutlet weak var balanceLabel: UILabel!
    var data = [Transaction]()
    var account: Account?
    var category: Category?
    var blurEffectView: UIVisualEffectView?
    var monthyear: Monthyear?
    var tapGesture: UITapGestureRecognizer?
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .lightContent .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let monthyear = self.monthyear ?? Monthyear.getNow()
        prepareView()
        
        prepareData(monthyear: monthyear)
        
        textFieldPicker.delegate = self
        prepareMonthYearPicker()
        
        // Слушаем изменения в Core Data
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        
    }
    
    @objc func contextObjectsDidChange(_ notification: Notification) {
        let monthyear = self.monthyear ?? Monthyear.getNow()
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
            for object in insertedObjects {
                if let item = object as? Transaction {
                    data.insert(item, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
            for object in updatedObjects {
                if let item = object as? Transaction {
                    if let index = data.firstIndex(where: {$0.objectID == item.objectID}) {
                        let indexPath = IndexPath(row: index, section: 0)
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
        
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
            for object in deletedObjects {
                if let item = object as? Transaction {
                    if let index = data.firstIndex(where: {$0.objectID == item.objectID}) {
                        let indexPath = IndexPath(row: index, section: 0)
                        data.remove(at: index)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
        if let account = self.account {
            balanceLabel.text = account.getBalance(monthyear: monthyear).formattedString
        } else {
            balanceLabel.text = ""
        }
    }
    
    func update(monthyear: Monthyear) {
        prepareData(monthyear: monthyear)
        if let account = self.account {
            balanceLabel.text = account.getBalance(monthyear: monthyear).formattedString
        } else {
            balanceLabel.text = ""
        }
        
        tableView.reloadData()
    }
    
    
    // Обновляем таблицу после удаления транзакции
    func delete(indexPath: IndexPath) {
        data.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func prepareView() {
        self.navigationItem.title = "Транзакции"
        let monthyear = self.monthyear ?? Monthyear.getNow()
        self.textFieldPicker.text = String(format: "%@ %d", DateFormatter().standaloneMonthSymbols[monthyear.month].capitalized, monthyear.year)
        if let account = self.account {
            self.balanceLabel.text = account.getBalance(monthyear: monthyear).formattedString
        } else {
            balanceLabel.text = ""
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTransaction))
        
        tableView.tableFooterView = UIView()
        monthYearPickerView.addBorder(side: .bottom, thickness: 1.0, color: #colorLiteral(red: 0.7764705882, green: 0.8235294118, blue: 0.9215686275, alpha: 1), leftOffset: 0.0)
    }
    
    func prepareData(monthyear: Monthyear) {
        if let account = self.account {
            data = account.getTransactions(monthyear: monthyear)
        } else if let category = self.category {
            data = DataStore.shared.getTransactions(monthyear: monthyear, account: nil, category: category)
        } else {
            data = DataStore.shared.getTransactions(monthyear: monthyear)
        }
    }
    
    func prepareMonthYearPicker() {
        datePicker = MonthYearPickerView()
        datePicker?.backgroundColor = .white
        
        datePicker?.years = []
        var year = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
        for _ in 1...15 {
            datePicker?.years.append(year)
            year -= 1
        }
        
        
        textFieldPicker.inputView = datePicker
        
        datePicker?.onDateSelected = { (month: Int, year: Int) in
            let monthyear = Monthyear(month: month-1, year: year)
            self.textFieldPicker.text = String(format: "%@ %d", DateFormatter().standaloneMonthSymbols[monthyear.month].capitalized, monthyear.year)
            let newPosition = self.textFieldPicker.beginningOfDocument
            self.textFieldPicker.selectedTextRange = self.textFieldPicker.textRange(from: newPosition, to: newPosition)
            
            self.update(monthyear: monthyear)
            
            self.tableView.reloadData()
        }
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer ) {
        view.endEditing(true)
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView!)
    }
    
    func removeBlurEffect() {
        blurEffectView?.removeFromSuperview()
//
//        let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
//        blurredEffectViews.forEach{ blurView in
//            blurView.removeFromSuperview()
//        }
    }
    
    @objc func addTransaction() {
        if let viewController = AddTransactionVC.storyboardInstance() {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension TransactionListVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)) )
        view.addGestureRecognizer(tapGesture!)
        let newPosition = textField.beginningOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        //addBlurEffect()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tapGesture = self.tapGesture {
            view.removeGestureRecognizer(tapGesture)
        }
        //removeBlurEffect()
    }
}

extension TransactionListVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var amount: Decimal
        let cellIdentifier = "CashCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CashTableViewCell
        
        let transaction = data[indexPath.row]

        if let account = self.account {
            amount = transaction.getAmount(account: account).amount
            cell.accountNameLabel.text = transaction.createdon?.convertToString(dateformat: .date)
            cell.dateLabel.text = transaction.comment
        } else if self.category != nil {
            if let account = transaction.account {
                amount = transaction.getAmount(account: account).amount
            } else if let account = transaction.accountto {
                amount = transaction.getAmount(account: account).amount
            } else {
                amount = 0
            }
            cell.accountNameLabel.text = transaction.createdon?.convertToString(dateformat: .date)
            cell.dateLabel.text = transaction.comment
        } else {
            if let account = transaction.account {
                amount = transaction.getAmount(account: account).amount
                cell.accountNameLabel.text = account.name
                cell.dateLabel.text = account.name
            } else if let account = transaction.accountto {
                amount = transaction.getAmount(account: account).amount
                cell.accountNameLabel.text = account.name
                cell.dateLabel.text = account.name
            } else {
                amount = 0
            }
            cell.accountNameLabel.text = transaction.createdon?.convertToString(dateformat: .date)
        }
        if amount < 0 {
            cell.amountLabel.textColor = KColor.redText
            
        } else {
            cell.amountLabel.textColor = KColor.greenText
        }

        
        
        cell.amountLabel.text = amount.formattedStringDecimalPrefix
        //cell.dateLabel.text = transaction.createdon?.convertToString(dateformat: .date)
        
        switch transaction.itemType {
        case .expense:
            cell.categoryLabel.text = transaction.category?.name
        case .income:
            cell.categoryLabel.text = transaction.category?.name
        case .transfer:
            cell.categoryLabel.text = transaction.itemType.name
        case .balance:
            cell.categoryLabel.text = transaction.itemType.name
        case .asset:
            cell.categoryLabel.text = transaction.itemType.name
        case .assetsell:
            cell.categoryLabel.text = transaction.itemType.name
        case .takingcredit:
            cell.categoryLabel.text = transaction.itemType.name
        case .repayment:
            cell.categoryLabel.text = transaction.itemType.name
        case .new:
            cell.categoryLabel.text = transaction.itemType.name
        case .newdebet:
            cell.categoryLabel.text = transaction.itemType.name
        case .newcredit:
            cell.categoryLabel.text = transaction.itemType.name
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = AccountVC.storyboardInstance() {
            let transaction = data[indexPath.row]
            
            viewController.entity = Entity.transaction(type: transaction.itemType)
            viewController.item = transaction
            viewController.editIndexPath = indexPath
            navigationController?.pushViewController(viewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
