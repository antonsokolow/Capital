//
//  Validate.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 08/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, SelectValueDelegate {
    
    // Variables to initiate view controller
    // Pass them before open view
    var entity: Entity?
    var item: Any?
    
    var cells: [Field] = []
    
    var properties = PropertyContainer() {
        didSet {
            reloadData()
        }
    }
    
    var editIndexPath: IndexPath?
    
    var updateIndexPath: IndexPath?
    
    func checkIfValid() -> Bool {
        var result = true
        for cell in cells {
            switch cell {
            case .account( _, let property, _):
                if properties.getPropertyValue(name: property) == nil {
                    result = false
                }
            case .amount(let property, _):
                if let number = properties.getPropertyValue(name: property) as? NSDecimalNumber {
                    if number == NSDecimalNumber.notANumber {
                        result = false
                    }
                } else { result = false }
                
            case .balance(let property):
                if properties.getPropertyValue(name: property) == nil {
                    result = false
                }
            case .category(_, let property):
                if properties.getPropertyValue(name: property) == nil {
                    result = false
                }
            case .name(let property):
                if properties.getProperty(name: property) == nil {
                    result = false
                }
            case .namewithicon(let property):
                if (properties.getProperty(name: property) == nil) {
                    result = false
                }
            case .cash:
                break
            case .date(let property):
                if properties.getPropertyValue(name: property) == nil {
                    result = false
                }
            case .monthyear(let property):
                if properties.getPropertyValue(name: property) == nil {
                    result = false
                }
            case .datePicker:
                break
            case .monthPicker:
                break
            case .comment:
                break
            case .textView:
                break
            case .checkbox:
                break
            case .button:
                break
            case .currency(let property, let title):
                if properties.getPropertyValue(name: property) == nil {
                    result = false
                }
                break
            }
        }
        return result
    }
    
    func reloadData() {
    }
    
    func saveData() {
        // Save
        guard let entity = self.entity, checkIfValid() else {
            ErrorHandler.shared.reportError(message: "DataViewController: 100")
            return
        }
        
        entity.save(item: item, properties: properties)
    }
    
    
    func deleteItem() {
    }
    
    func update(indexPath: IndexPath) {}
    
    public func pushController(viewController: UIViewController) {
        // push your controller here
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension DataViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let field = cells[indexPath.row]
        let cellIdentifier = field.cellIdentifier
        switch field {
        case .name(let property):
            let cell = tableView.dequeueReusableCell(withIdentifier: NameTableViewCell.reuseIdentifier()) as! NameTableViewCell
            cell.nameTextField.text = properties.getPropertyValue(name: property) as? String
            cell.cellDelegate = self
            return cell
        case .namewithicon(let property):
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NameWithIconCell
            if let name = properties.getPropertyValue(name: property) as? String {
                cell.nameTextField.text = name
            }
            if let icon = properties.getPropertyValue(name: "icon") as? String {
                cell.iconButton.imageView?.image = UIImage(named: icon)
            }
            cell.property = property
            cell.cellDelegate = self
            cell.pushHandler = pushController
            return cell
        case .balance(let property):
            let cell = tableView.dequeueReusableCell(withIdentifier: BalanceCell.reuseIdentifier()) as! BalanceCell
            cell.title.text = field.name
            if let balance = properties.getPropertyValue(name: property) as? Decimal {
                cell.balance.text = balance.formattedStringDecimal
            }
            cell.property = property
            cell.cellDelegate = self
            cell.balance.delegate = cell
            return cell
        case .cash:
            ErrorHandler.shared.reportError(message: "DataViewController: 163")
            fatalError()
        case .account(_, let property, let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.reuseIdentifier()) as! AccountCell
            if let account = properties.getPropertyValue(name: property) as? Account {
                cell.name.text = account.name
            } else {
                cell.name.text = title
            }
            return cell
        case .amount(let property, let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: AmountTableViewCell.reuseIdentifier()) as! AmountTableViewCell
            if let amount = properties.getPropertyValue(name: property) as? Decimal {
                cell.AmountTextField.text = amount.formattedStringDecimal
            }
            cell.property = property
            cell.titleLabel.text = title
            cell.cellDelegate = self
            cell.AmountTextField.delegate = cell
            return cell
        case .category(_, let property):
            let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.reuseIdentifier()) as! AccountCell
            if let category = properties.getPropertyValue(name: property) as? Category {
                
                cell.name.text = category.name
                if let index = cells.firstIndex(where: {$0.id == "switch"}) {
                    switch cells[index] {
                    case .checkbox(let property, _):
                        let monthly = category.monthly ?? false
                        properties.setProperty(name: property, value: monthly)
                    default:
                        break
                    }
                }
            } else {
                cell.name.text = field.name
            }
            return cell
        case .date(let property):
            let cell = tableView.dequeueReusableCell(withIdentifier: DateTableViewCell.reuseIdentifier()) as! DateTableViewCell
            if let created = properties.getPropertyValue(name: property) as? Date {
                cell.updateText(text: field.name, date: created, format: .date)
            }
            
            return cell
        case .monthyear(let property):
            let cell = tableView.dequeueReusableCell(withIdentifier: DateTableViewCell.reuseIdentifier()) as! DateTableViewCell
            
            if let monthyear = properties.getPropertyValue(name: property) as? Monthyear {
                let calendar = Calendar.current
                var components = DateComponents()
                
                components.month = monthyear.month + 1
                components.year = monthyear.year
                
                if let newDate = calendar.date(from: components) {
                    cell.updateText(text: field.name, date: newDate, format: .month)
                }
                
            }
            return cell
        case .datePicker(let property):
            let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerTableViewCell.reuseIdentifier()) as!  DatePickerTableViewCell
            if let createdon = properties.getPropertyValue(name: property) as? Date {
                cell.updateCell(date: createdon, indexPath: indexPath)
            }
            cell.cellDelegate = self
            cell.property = property
            return cell
        case .monthPicker(let property):
            let cell = tableView.dequeueReusableCell(withIdentifier:   MonthPickerTableViewCell.reuseIdentifier()) as!  MonthPickerTableViewCell
            if let createdon = properties.getPropertyValue(name: property) as? Date {
                cell.updateCell(date: createdon, indexPath: indexPath)
            }
            cell.cellDelegate = self
            cell.property = property
            
            return cell
        case .comment(let property):
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier()) as!  CommentCell
            if let comment = properties.getPropertyValue(name: property) as? String {
                cell.textField.text = comment
            }
            cell.property = property
            cell.cellDelegate = self
            return cell
        case .textView(let property):
            let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.reuseIdentifier()) as!  TextViewCell
            if let comment = properties.getPropertyValue(name: property) as? String {
                cell.updateText(text: comment)
            }
            cell.property = property
            cell.cellDelegate = self
            return cell
        case .checkbox(let property, let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.reuseIdentifier()) as! SwitchCell
            if let value = properties.getPropertyValue(name: property) as? Bool {
                cell.switchOutlet.setOn(value, animated: true)
            } else {
                cell.switchOutlet.setOn(false, animated: true)
            }
            cell.title.text = title
            cell.property = property
            cell.cellDelegate = self
            return cell
        case .button(let property, let title, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseIdentifier()) as! ButtonCell
            // Чтобы при тапе по ячейке не было видно селекта
            cell.selectionStyle = .none
            
            cell.button.setTitle(title, for: .normal)
            cell.property = property
            cell.buttonTouched = deleteItem
            return cell
        case .currency(let property, let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.reuseIdentifier()) as! CurrencyCell
            if let currency = properties.getPropertyValue(name: property) as? String {
                cell.currency.text = currency
            } else {
                cell.currency.text = "-"
            }
            
            cell.name.text = title
            return cell
        }
    }
}


extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
