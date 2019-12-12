//
//  BudgetCollectionView.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 03/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class BudgetCollectionView: UICollectionView {

    var type: CategoryType?
    var sdx: Int? // parent table section id
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    override func awakeFromNib() {
        
        //self.dataSource = self
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        self.addGestureRecognizer(longPressGesture)
        
    }
    
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = self.indexPathForItem(at: gesture.location(in: self)) else {
                break
            }
            self.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            self.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            self.endInteractiveMovement()
        default:
            self.cancelInteractiveMovement()
        }
    }

}

extension BudgetViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collection = collectionView as? BudgetCollectionView, let sdx = collection.sdx else {
            ErrorHandler.shared.reportError(message: "BudgetCollectionView: 54")
            return 0
        }
        return viewModel.budgetsInSection(section: sdx).count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CollectionViewCell
        {
            if let collection = collectionView as? BudgetCollectionView, let sdx = collection.sdx, let category = viewModel.budgetsInSection(section: sdx)[indexPath.row].category {
                cell.accountName.text = category.name
                cell.amountSpent.text = viewModel.monthSpent(at: IndexPath(row: indexPath.row, section: sdx)).formattedStringDecimal
                cell.amountSpent.textColor = category.itemType.color
                
                if let amount = viewModel.budgetsInSection(section: sdx)[indexPath.row].amount as Decimal? {
                    cell.amountBudget.text = amount.formattedStringDecimal
                }
                if let icon = viewModel.budgetsInSection(section: sdx)[indexPath.row].category?.icon {
                    cell.imageView.image = UIImage(named: icon)
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if let collection = collectionView as? BudgetCollectionView, let sdx = collection.sdx {
            
            let budgetsToMove = viewModel.budgetsInSection(section: sdx)
            if sourceIndexPath.item > destinationIndexPath.item {
                for i in destinationIndexPath.item..<sourceIndexPath.item {
                    budgetsToMove[i].order = Int64(i + 1)
                }
            } else {
                for i in (sourceIndexPath.item+1)...destinationIndexPath.item {
                    budgetsToMove[i].order = Int64(i-1)
                }
            }
            budgetsToMove[sourceIndexPath.item].order = Int64(destinationIndexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

extension BudgetViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let collection = collectionView as? BudgetCollectionView, let sdx = collection.sdx else {
            return
        }
        let budget = viewModel.budgetsInSection(section: sdx)[indexPath.row]
        guard let type = budget.type, let title = budget.category?.name, let transactionType = TransactionType(rawValue: type), let category = budget.category else {
            return
        }
        
        
        self.alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        self.alertController?.addAction(UIAlertAction(title: NSLocalizedString("Добавить", comment: "Add") + " " + transactionType.name.lowercased(), style: .default, handler: { _ in
            self.addTransactionForCategory(type: transactionType, category: category)
        }))
        self.alertController?.addAction(UIAlertAction(title: NSLocalizedString("Редактировать", comment: "Edit"), style: .default, handler: { _ in
            self.editBudget(budget: self.viewModel.budgetsInSection(section: sdx)[indexPath.row])
        }))
        self.alertController?.addAction(UIAlertAction(title: NSLocalizedString("Transactions", comment: "Transactions"), style: .default, handler: { _ in
            self.showTransactions(category: category)
        }))
        self.alertController?.addAction(UIAlertAction(title: NSLocalizedString("Удалить", comment: "Default action"), style: .destructive, handler: { _ in
            self.deleteBudget(collectionView: collectionView, indexPath: indexPath)
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
