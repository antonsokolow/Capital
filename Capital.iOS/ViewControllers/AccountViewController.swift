//
//  SecondViewController.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 01/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData

@IBDesignable class AccountViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    //var data = [AccountDataModel]()
    //var modelController: AccountListVM!
    var viewModel: AccountViewVM!
    var selectedIdx: Int? // id секции которую надо обновить при возвращении
    
    var alertController: UIAlertController?
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .lightContent .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AccountViewVM()
        viewModel.reload = self.reload
        
        viewModel.fetchData()
        tableView.tableFooterView = UIView()
        
        self.navigationItem.title = NSLocalizedString("Accounts", comment: "")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    func reload(changes: ViewModelChange) {
        tableView.applyChanges(changes: changes)
        //tableView.reloadSections([idx], with: .automatic)
    }
    
    func showTransactionList(account: Account) {
        if let TransactionListVC = TransactionListVC.storyboardInstance() {
            // initialize all your class properties
            // nextViewController.property1 = …
            // nextViewController.property2 = …
            TransactionListVC.account = account
            
            // either push or present the nextViewController,
            // depending on your navigation structure
            // present(nextViewController, animated: true, completion: nil)
            
            // or push
            navigationController?.pushViewController(TransactionListVC, animated: true)
        }
    }
    
    func showEditAccount(account: Account) {
        if let viewController = AccountVC.storyboardInstance() {
            // initialize all your class properties
            // nextViewController.property1 = …
            // nextViewController.property2 = …
            //viewController.account = account
            viewController.entity = Entity.account(type: account.itemType)
            viewController.item = account
            //if let type = account.type { viewController.type = AccountType(rawValue: type) }
            
            // either push or present the nextViewController,
            // depending on your navigation structure
            // present(nextViewController, animated: true, completion: nil)
            
            // or push
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func showDeleteAccount(account: Account, at indexPath: IndexPath) {
        let entity = Entity.account(type: account.itemType)
        self.alertController = UIAlertController(title: nil, message: entity.deleteMessage, preferredStyle: .actionSheet)
        self.alertController?.addAction(UIAlertAction(title: NSLocalizedString("Удалить", comment: "Default action"), style: .destructive, handler: { _ in
            
            //DataStore.shared.delete(entity: entity, item: account)
            self.viewModel.remove(account: account, at: indexPath)
            
            // Update table view
            //self.viewModel.data[indexPath.section].accounts.remove(at: indexPath.row)
            //self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }))
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        self.alertController?.addAction(cancelAction)
        
        self.present(self.alertController!, animated: true) {
            self.alertController?.view.superview?.subviews.first?.isUserInteractionEnabled = true
            self.alertController?.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionSheetBackgroundTapped)))
        }
    }
    
    func showTransfer(account: Account) {
        // Окно транзакции перевода денег
    }
}

// MARK: - Table View Protocols

extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = AccountHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 48))
        
        headerView.delegate = self
        headerView.secIndex = section
        headerView.toggleBtn.setTitle(viewModel.headerTitle(section: section), for: .normal)
        headerView.toggleBtn.isSelected = viewModel.isSectionExpanded(section: section)
        headerView.backgroundColor = UIColor.white
        
        headerView.totalLabel.text = viewModel.totalBudget(section: section)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AccountTableViewCell
        
        
        cell.accountName.text = viewModel.accountName(indexPath: indexPath)
        cell.accountAmount.text = viewModel.accountAmount(indexPath: indexPath)
        
        cell.accountIcon.image = viewModel.accountIcon(indexPath: indexPath)
        
        cell.infoLabel.attributedText = viewModel.infoLabelText(indexPath: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let account = self.viewModel.getAccount(at: indexPath)
            self.showDeleteAccount(account: account, at: indexPath)
            // Reset state
            success(true)
        })
        deleteAction.image = UIImage(named: "delete")
        deleteAction.backgroundColor = .red
        
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.showEditAccount(account: self.viewModel.getAccount(at: indexPath))
            
            // Reset state
            success(true)
        })
        editAction.image = UIImage(named: "more")
        editAction.backgroundColor = .lightGray
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let account = self.viewModel.getAccount(at: indexPath)
        
        // iOS 11 Сразу показываем транзакции
        // Редактирование по свайпу
        if #available(iOS 11, *) {
            self.showTransactionList(account: account)
            return
        } else {
            
        }
        
        // iOS 10.3
        // Показываем меню
        self.alertController = UIAlertController(title: account.name, message: nil, preferredStyle: .actionSheet)
        self.alertController?.addAction(UIAlertAction(title: NSLocalizedString("Редактировать", comment: "Default action"), style: .default, handler: { _ in
            self.selectedIdx = indexPath.section
            self.showEditAccount(account: account)
        }))
        self.alertController?.addAction(UIAlertAction(title: NSLocalizedString("Транзакции", comment: "Default action"), style: .default, handler: { _ in
            self.showTransactionList(account: account)
        }))
        let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        self.alertController?.addAction(cancelAction)

        self.present(alertController!, animated: true) {
            self.alertController?.view.superview?.subviews.first?.isUserInteractionEnabled = true
            self.alertController?.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionSheetBackgroundTapped)))
        }
    }
    
    // To dismiss Action Sheet on Tap
    @objc func actionSheetBackgroundTapped() {
        self.alertController?.dismiss(animated: true, completion: nil)
    }
    

}

extension AccountViewController: HeaderDelegate {
    func callHeader(idx: Int) {
        viewModel.toggleSectionExpanded(section: idx)
        tableView.reloadSections([idx], with: .automatic)
    }
    
    func addItem(idx: Int) {
        self.selectedIdx = idx
        if let viewController = AccountVC.storyboardInstance() {
            //viewController.type = data[idx].itemType
            guard let type = viewModel.getSectionType(section: idx) else {
                ErrorHandler.shared.reportError(message: "AccountViewController: 258")
                return
            }
            viewController.entity = Entity.account(type: type)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}


