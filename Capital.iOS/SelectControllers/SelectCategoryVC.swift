//
//  SelectCategoryVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 06/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData

enum SelectActions {
    case select
    case delete
}

class SelectCategoryVC: SelectVC, DeleteValueDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var data = [Category]()
    var alertController: UIAlertController?
    var action: SelectActions = SelectActions.select
    var deleteDelegate: DeleteValueDelegate?
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    var gestureRecognizer: UITapGestureRecognizer?

    
    static func storyboardInstance() -> SelectCategoryVC? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? SelectCategoryVC
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .lightContent .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tableViewBackgroundTapped))
        tableView.addGestureRecognizer(longPressGesture)
        
        // Добавление категорий
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategory))
        
        tableView.tableFooterView = UIView()
        
        // Слушаем изменения в Core Data
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        
    }
    
    @objc func contextObjectsDidChange(_ notification: Notification) {
        
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
            for object in insertedObjects {
                if let category = object as? Category {
                    data.insert(category, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
            for object in updatedObjects {
                if let category = object as? Category {
                    if let index = data.firstIndex(where: {$0.objectID == category.objectID}) {
                        let indexPath = IndexPath(row: index, section: 0)
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
        
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
            for object in deletedObjects {
                if let category = object as? Category {
                    if let index = data.firstIndex(where: {$0.objectID == category.objectID}) {
                        let indexPath = IndexPath(row: index, section: 0)
                        data.remove(at: index)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
        //
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
//            guard let selectedIndexPath = tableView.indexPathForRow(at: gesture.location(in: tableView)) else {
//                break
//            }
            self.tableView.setEditing(true, animated: true)
            tableView.removeGestureRecognizer(longPressGesture)
            self.tableView.superview?.subviews.first?.addGestureRecognizer(gestureRecognizer!)
            //tableView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            break
            //self.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            break
            //self.endInteractiveMovement()
        default:
            break
            //self.cancelInteractiveMovement()
        }
    }
    
    // To dismiss Action Sheet on Tap
    @objc func tableViewBackgroundTapped() {
        self.tableView.setEditing(false, animated: true)
        self.tableView.superview?.subviews.first?.removeGestureRecognizer(gestureRecognizer!)
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func addCategory() {
        if let viewController = AccountVC.storyboardInstance() {
            guard let type = self.type as? CategoryType else {
                ErrorHandler.shared.reportError(message: "SelectCategoryVC: 124")
                return
            }
            viewController.entity = Entity.category(type: type)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    
    func deleteValue(category: Category) {
        if let indexPath = updateIndexPath {
            DataStore.shared.moveCategory(category: data[indexPath.row], categoryTo: category)
            DataHandler.shared.viewContext.delete(data[indexPath.row])
        } else {
            ErrorHandler.shared.reportError(message: "SelectCategoryVC: 138")
            return
        }
    }
    
    func rename(category: Category) {
        if let viewController = AccountVC.storyboardInstance() {
            guard let type = self.type as? CategoryType else {
                ErrorHandler.shared.reportError(message: "SelectCategoryVC: 146")
                return
            }
            viewController.entity = Entity.category(type: type)
            viewController.item = category
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}


extension SelectCategoryVC: UITableViewDataSource, UITableViewDelegate {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier()) as! CategoryCell
        
        cell.title.text = data[indexPath.row].name
        cell.comment.text = data[indexPath.row].comment
        if let icon = data[indexPath.row].icon {
            let origImage = UIImage(named: icon)
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            cell.icon.image = tintedImage
            cell.icon.tintColor = KColor.darkText
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch action {
        case .delete:
            // delete
            self.deleteDelegate?.deleteValue(category: data[indexPath.row])
        case .select:
            // select
            if let property = self.property {
                self.delegate?.properties.setProperty(name: property, value: data[indexPath.row])
                if let indexPath = updateIndexPath {
                    self.delegate?.update(indexPath: indexPath)
                }
            }
        }
        
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            // otherwise, dismiss it
            dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch action {
        case .delete:
            return false
        case .select:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if #available(iOS 11, *) { return .none }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.deleteCategory(indexPath: indexPath)
            
            // Reset state
            success(true)
        })
        deleteAction.image = UIImage(named: "delete")
        deleteAction.backgroundColor = .red
        
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.rename(category: self.data[indexPath.row])
            
            // Reset state
            success(true)
        })
        editAction.image = UIImage(named: "more")
        editAction.backgroundColor = .lightGray
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    // Для совместимости с iOS 10.3
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let rename = UITableViewRowAction(style: .normal, title: NSLocalizedString("Изменить", comment: "Изменить")) { action, index in
            //self.isEditing = false
            self.rename(category: self.data[indexPath.row])
        }
        rename.backgroundColor = UIColor.lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: NSLocalizedString("Удалить", comment: "Удалить")) { action, index in
            //self.isEditing = false
            print("delete button tapped")
            
            self.deleteCategory(indexPath: indexPath)
            
        }
        delete.backgroundColor = UIColor.red
        
        return [delete, rename]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.data[sourceIndexPath.row]
        data.remove(at: sourceIndexPath.row)
        data.insert(movedObject, at: destinationIndexPath.row)
        
        if sourceIndexPath.item > destinationIndexPath.item {
            for i in destinationIndexPath.item...sourceIndexPath.item {
                data[i].order = Int64(i)
            }
        } else {
            for i in sourceIndexPath.item...destinationIndexPath.item {
                data[i].order = Int64(i)
            }
        }
    }
    
    func deleteCategory(indexPath: IndexPath) {
        self.updateIndexPath = indexPath
        guard let result = DataStore.shared.isTransactionsForCategoryExists(category: self.data[indexPath.row]) else {
            ErrorHandler.shared.reportError(message: "SelectCategoryVC: 295")
            return
        }
        if result == true {
            self.alertController = UIAlertController(title: nil, message: "Транзакциям будет назначена новая категория", preferredStyle: .actionSheet)
            self.alertController?.addAction(UIAlertAction(title: NSLocalizedString("Выбрать категорию", comment: "Default action"), style: .destructive, handler: { _ in
                //Выбираем категорию
                if let viewController = SelectCategoryVC.storyboardInstance() {
                    viewController.deleteDelegate = self
                    if let type = self.data[indexPath.row].type, let categoryType = CategoryType(rawValue: type) {
                        var data = DataStore.shared.getCategories(type: categoryType)
                        if let offset = data.firstIndex(where: {$0.name == data[indexPath.row].name}) {
                            data.remove(at: offset)
                            viewController.data = data
                        }
                    }
                    viewController.action = SelectActions.delete
                    
                    
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }))
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            self.alertController?.addAction(cancelAction)
            
            self.present(self.alertController!, animated: true) {
                self.alertController?.view.superview?.subviews.first?.isUserInteractionEnabled = true
                self.alertController?.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionSheetBackgroundTapped)))
            }
            
            
            
            

        } else {
            DataHandler.shared.viewContext.delete(data[indexPath.row])
        }
        

    }
    
    // To dismiss Action Sheet on Tap
    @objc func actionSheetBackgroundTapped() {
        self.alertController?.dismiss(animated: true, completion: nil)
    }
}
