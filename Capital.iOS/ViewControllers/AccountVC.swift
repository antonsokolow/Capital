//
//  EditAccountVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 16/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class AccountVC: DataViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var alertController: UIAlertController?
    var datePickerIndexPath: IndexPath?
    var unlockSave: ((Bool) -> ())?
    
    
    static func storyboardInstance() -> AccountVC? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? AccountVC
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .lightContent .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        

        tableView.tableFooterView = UIView()
        if(unlockSave == nil) {
            unlockSave = unlockSaveButton
        }
        prepareData()
    }
    
    @objc func save() {
        
        saveData()
        
        // Back to main controller
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            // otherwise, dismiss it
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func update(indexPath: IndexPath) {
        super.update(indexPath: indexPath)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        let field = cells[indexPath.row]
        switch field {
        case .category(_, _):
            if let index = cells.firstIndex(where: {$0.id == "switch"}) {
                switch cells[index] {
                case .checkbox(let property, _):
                    let switchIndexPath = IndexPath(row: index, section: indexPath.section)
                    tableView.reloadRows(at: [switchIndexPath], with: .automatic)
                default:
                    break
                }
            }
        default:
            break
        }
    }
    

    func prepareData() {
        
        guard let entity = self.entity else {
            ErrorHandler.shared.reportError(message: "AccountVC: 83")
            return
        }
        
        
        if let item = self.item {
            // Update item
            cells = entity.cellsEdit
            self.properties = entity.getProperties(item: item)
        } else {
            // Create new item
            cells = entity.cells
        }
        
        unlockSave?(checkIfValid())
        self.navigationItem.title = entity.title
    }
    
    override func reloadData() {
        super.reloadData()
        
        // Обновляем таблицу
        if let indexPath = updateIndexPath {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            if datePickerIndexPath == nil {
                updateIndexPath = nil
            }
        }
        
        // Разблокируем кнопку save если все параметры указаны
        // Если контроллер показывается внутри другого контроллера, то разблокируем кнопку save
        // родительского контроллера
        unlockSave?(checkIfValid())
    }
    
    func unlockSaveButton(value: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = value
    }

    override func deleteItem() {
        super.deleteItem()
        
        guard let entity = self.entity else {
            ErrorHandler.shared.reportError(message: "AccountVC: 126")
            return
        }
        self.alertController = UIAlertController(title: nil, message: entity.deleteMessage, preferredStyle: .actionSheet)
        self.alertController?.addAction(UIAlertAction(title: NSLocalizedString("Удалить", comment: "Default action"), style: .destructive, handler: { _ in            guard let item = self.item else {
                ErrorHandler.shared.reportError(message: "AccountVC: 133")
                return
            }
            DataStore.shared.delete(entity: entity, item: item)
            
            // Back to main controller
            if let nvc = self.navigationController {
                nvc.popViewController(animated: true)
            } else {
                // otherwise, dismiss it
                self.dismiss(animated: true, completion: nil)
            }
            
        }))
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        self.alertController?.addAction(cancelAction)
        
        self.present(self.alertController!, animated: true) {
            self.alertController?.view.superview?.subviews.first?.isUserInteractionEnabled = true
            self.alertController?.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionSheetBackgroundTapped)))
        }
    }
    
    // To dismiss Action Sheet on Tap
    @objc func actionSheetBackgroundTapped() {
        self.alertController?.dismiss(animated: true, completion: nil)
    }
    
    func indexPathToInsertDatePicker(indexPath: IndexPath) -> IndexPath {
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row < indexPath.row {
            return indexPath
        } else {
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
    
}

// MARK: - Table view delegate

extension AccountVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if datePickerIndexPath == indexPath {
            return DatePickerTableViewCell.cellHeight()
        } else if cells[indexPath.row].id == "textView" {
            return TextViewCell.cellHeight()
        } else if cells[indexPath.row].id == "button" {
            return ButtonCell.cellHeight()
        } else {
            return 50.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let datePickerIndexPath = self.datePickerIndexPath
        switch indexPath.section {
        case 0:
            if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath == indexPath {
                return
            }
            
            let field = cells[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            
            switch field {
                
            case .account(let types, let property, _):
                updateIndexPath = indexPath
                //Выбираем счет
                if let viewController = SelectAccountVC.storyboardInstance() {
                    viewController.delegate = self
                    viewController.propertyName = property
                    viewController.updateIndexPath = indexPath
                    
                    var data = [AccountDataModel]()
                    for value in types {
                        data.append(AccountDataModel(headerName: value, subType: DataStore.shared.getAccounts(type: value), isExpandable: true))
                    }
                    viewController.data = data
                    
                    navigationController?.pushViewController(viewController, animated: true)
                }
                
                
            case .category(let type, let property):
                updateIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
                //Выбираем категорию
                if let viewController = SelectCategoryVC.storyboardInstance() {
                    viewController.delegate = self
                    viewController.updateIndexPath = indexPath
                    viewController.property = property
                    viewController.type = type
                    var data = DataStore.shared.getCategories(type: type)
                    if let monthyear = properties.getPropertyValue(name: "monthyear") as? Monthyear {
                        let budgets = DataStore.shared.getBudgets(type: type, month: monthyear.month, year: monthyear.year)
                        for budget in budgets {
                            if let category = budget.category, let ix = data.firstIndex(of: category) {
                                data.remove(at: ix)
                            }
                        }
                    }
                    
                    viewController.data = data
                    viewController.action = SelectActions.select
                    
                    navigationController?.pushViewController(viewController, animated: true)
                }
                
            case .name:
                break
            case .namewithicon:
                break
            case .amount( _):
                tableView.deselectRow(at: indexPath, animated: false)
            case .balance:
                break
            case .cash:
                break
            case .date(let property):
                if datePickerIndexPath == nil {
                    updateIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
                    self.datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
                    cells.insert(Field.datePicker(property: property), at: self.datePickerIndexPath!.row)
                    tableView.insertRows(at: [self.datePickerIndexPath!], with: .fade)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            case .monthyear(_):
                break
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
            case .currency(let property, _):
                updateIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
                if let viewController = SelectCurrencyVC.storyboardInstance() {
                    viewController.delegate = self
                    viewController.updateIndexPath = indexPath
                    viewController.property = property
                    navigationController?.pushViewController(viewController, animated: true)
                }
            }
        case 1:
            switch indexPath.row {
            case 0:
                print("Строка 0")
            case 1:
                print("Строка 1")
            default:
                break
            }
        case 2: break
        // Do something
        default:
            break
        }
        
        if let datePickerIndexPath = datePickerIndexPath {
            
            tableView.beginUpdates()
            cells.remove(at: datePickerIndexPath.row)
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            self.datePickerIndexPath = nil
            tableView.endUpdates()
            
            updateIndexPath = nil
        }
    }
}
