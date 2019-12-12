//
//  FirstViewController.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 01/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData
import YandexMobileMetrica
import os.log


@IBDesignable class BudgetViewController: UIViewController {

    var viewModel: BudgetViewVM!
    
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var rootContainerView: UIView!
    @IBOutlet weak var totalBackgroundView: UIView!
    
    @IBOutlet weak var totalViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var totalBackgroundViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var rootContainerHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var totalBackgroundHeightAnchor: NSLayoutConstraint!
    
    var pageContainerInitialHeight = CGFloat()
    
    // old
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTransactionBtn: UIButton!
    //@IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    
    var navigationBarHeight: CGFloat = 64 // зависит от модели айфона
    
    var monthyear: Monthyear {
        get {
            return viewModel.monthyear
        }
    }
    
    var selectedIdx: Int?
    var alertController: UIAlertController?
    var setTitleDelegate: SetTitle?
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    var isExpanded = false
    
    
    static func storyboardInstance() -> BudgetViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? BudgetViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .lightContent .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.reload = self.reload
        
        viewModel.fetchData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        prepareView()
        
        updateTotal()
        
        setTitleDelegate?.setTitle(title: viewModel.monthyear.name)
        setTitleDelegate?.budgetController = self
        
    }
    
    func reload(changes: ViewModelChange) {
        tableView.applyChanges(changes: changes)
        updateTotal()
    }
    
    
    func prepareView() {
        
        containerScrollView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: totalView.frame.height, left: 0, bottom: 0, right: 0)
        
        pageContainerInitialHeight = totalView.frame.height
        
        if let navigationBarHeight = self.navigationController?.navigationBar.frame.height {
            self.navigationBarHeight = UIApplication.shared.statusBarFrame.height + navigationBarHeight
        }
        
        totalBackgroundHeightAnchor.constant = -tableView.contentOffset.y + navigationBarHeight

        
        // update table view content height
        tableView.layoutIfNeeded()
        
        tableView.tableFooterView = UIView()
        
        // adjust scroll view content height using rootContainer height anchor
        rootContainerHeightAnchor.constant = tableView.contentSize.height + pageContainerInitialHeight
    }
    
    func update() {
        tableView.reloadData()
        prepareView()
        updateTotal()
        
    }
    
    func updateTotal() {
        //totalLabel.text = DataStore.shared.getTotalBalance(type: AccountType.cash).formattedString
        
        totalLabel.text = viewModel.getTotalBalance(type: AccountType.cash).formattedString
        
        var totalSpent: Decimal = 0.0
        var totalEarn: Decimal = 0.0
        var budgetSpent: Decimal = 0.0
        var budgetEarn: Decimal = 0.0
        for i in viewModel.budgetsInSection(section: 0) {
            totalEarn += i.monthSpent(monthyear: monthyear)
            budgetEarn += i.amount! as Decimal
        }
        for i in viewModel.budgetsInSection(section: 1) {
            totalSpent += i.monthSpent(monthyear: monthyear)
            budgetSpent += i.amount! as Decimal
        }
        budgetLabel.text = (totalEarn - totalSpent).formattedStringDecimal + " | " + (budgetEarn - budgetSpent).formattedStringDecimal
    }
    
    func add(item: Any) {
//        guard let budget = item as? Budget else {
//            fatalError()
//        }
        //data.append(category)
    }
    
    func delete(indexPath: IndexPath) {
        
    }
    
    func deleteBudget(collectionView: UICollectionView, indexPath: IndexPath) {
//        guard let collection = collectionView as? BudgetCollectionView, let sdx = collection.sdx else {
//            return
//        }
//
//        DataStore.shared.deleteBudget(budget: viewModel.budgetsInSection(section: sdx)[indexPath.row])
//        viewModel.data[sdx].budgets.remove(at: indexPath.row)
//        collection.deleteItems(at: [indexPath])
//
//        updateTotal()
    }
    
    //MARK: - Private functions
    
    @IBAction func clickOnYearSelect(_ sender: UIButton) {
    }
    
    func addBudget(type: CategoryType, monthyear: Monthyear) {
        if let viewController = AccountVC.storyboardInstance() {
            viewController.entity = Entity.budget(type: type)
            viewController.properties.setProperty(name: "monthyear", value: monthyear)
            viewController.item = nil
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func editBudget(budget: Budget) {
        if let viewController = AccountVC.storyboardInstance() {
            viewController.entity = Entity.budget(type: budget.itemType)
            viewController.item = budget
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    func addTransactionForCategory(type: TransactionType, category: Category) {
        if let viewController = AccountVC.storyboardInstance() {
            
            viewController.entity = Entity.transaction(type: type)
            viewController.properties.setProperty(name: "category", value: category)
            viewController.properties.setProperty(name: "createdon", value: Date())
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func showTransactions(category: Category) {
        if let TransactionListVC = TransactionListVC.storyboardInstance() {
            TransactionListVC.category = category
            TransactionListVC.monthyear = monthyear
            navigationController?.pushViewController(TransactionListVC, animated: true)
        }
    }
    
}

// MARK: - UITableViewDataSource

extension BudgetViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = viewModel.data[section].categoryType else {
            return nil
        }
        let headerView = BudgetHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 48))
        headerView.toggleBtn.setTitle( header.name + "   ", for: .normal )
        
        headerView.delegate = self
        headerView.secIndex = section
        
        headerView.toggleBtn.isSelected = viewModel.data[section].isExpanded
        
        
        var totalSpent: Decimal = 0.0
        var totalBudget: Decimal = 0.0
        for i in viewModel.budgetsInSection(section: section) {
            totalSpent += i.monthSpent(monthyear: monthyear)
            if let amount = i.amount as Decimal? {
            totalBudget += amount
            }
        }
        let myString = NSMutableAttributedString()
        
        //var myAttribute = [ NSAttributedString.Key.foregroundColor: header.color, NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 12.0)! ]
        var myAttribute = [ NSAttributedString.Key.foregroundColor: header.color, NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 12.0)! ]
        let totalSpentText = NSAttributedString(string: totalSpent.formattedStringDecimal, attributes: myAttribute)
        myAttribute = [ NSAttributedString.Key.foregroundColor: KColor.darkText, NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 12.0)! ]
        let totalBudgetText = NSAttributedString(string: "| " + totalBudget.formattedStringDecimal, attributes: myAttribute)
        
        
        myString.append(totalSpentText)
        myString.append(totalBudgetText)
        
        headerView.totalLabel.attributedText = myString
        //headerView.totalLabel.text = totalSpent.formattedStringDecimal + " | " + totalBudget.formattedStringDecimal
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeaderInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BudgetTableViewCell
        
        cell.collectionView.type = viewModel.data[indexPath.section].categoryType
        cell.collectionView.sdx = indexPath.section
        //cell.collectionView.data = data[indexPath.section].budgets
        cell.collectionView.dataSource = self
        cell.collectionView.delegate = self
        
        cell.collectionView.reloadSections([0])
        
        return cell
        
    }
    
}

extension BudgetViewController: HeaderDelegate {
    func callHeader(idx: Int) {
        viewModel.data[idx].isExpanded = !viewModel.data[idx].isExpanded
        self.isExpanded = viewModel.data[idx].isExpanded
        if #available(iOS 11, *) {
            tableView.performBatchUpdates({ () in
                tableView.reloadSections([idx], with: .automatic)
            },
                                          
                                          completion: {(result) in
                                            if self.tableView.contentSize.height + self.pageContainerInitialHeight < self.view.frame.height - self.navigationBarHeight {
                                                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn],
                                                               animations: {
                                                                self.rootContainerView.center.y += self.containerScrollView.contentOffset.y
                                                }, completion: {(result) in
                                                    self.rootContainerHeightAnchor.constant = self.tableView.contentSize.height + self.pageContainerInitialHeight
                                                })
                                            } else {
                                                self.rootContainerHeightAnchor.constant = self.tableView.contentSize.height + self.pageContainerInitialHeight
                                            }
                                            
            })
        } else {
            tableView.reloadSections([idx], with: .automatic)
        }
        
        
        // update table view content height
        //tableView.layoutIfNeeded()
        
        //if data[idx].isExpanded {
            // adjust scroll view content height using rootContainer height anchor
         //  rootContainerHeightAnchor.constant = tableView.contentSize.height + pageContainerInitialHeight
        //}
    }
    
    func addItem(idx: Int) {
        guard let categoryType = CategoryType(id: idx) else {
            ErrorHandler.shared.reportError(message: "BudgetViewController: 343")
            return
        }
        addBudget(type: categoryType, monthyear: monthyear)
    }
}


extension BudgetViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y - tableView.contentOffset.y
        totalViewTopAnchor.constant = y - pageContainerInitialHeight
        
        if totalViewTopAnchor.constant > 40 && totalViewTopAnchor.constant < pageContainerInitialHeight {
            totalView.alpha = CGFloat(totalViewTopAnchor.constant / pageContainerInitialHeight + 0.2)
        } else {
            totalView.alpha = 0
        }
        
        if pageContainerInitialHeight - scrollView.contentOffset.y > 0 {
            totalBackgroundHeightAnchor.constant = -tableView.contentOffset.y + navigationBarHeight - scrollView.contentOffset.y
        }
        
        if totalViewTopAnchor.constant > 0 || totalViewTopAnchor.constant == -pageContainerInitialHeight {
            totalViewTopAnchor.constant = 0
            totalBackgroundViewTopAnchor.constant = 0
        }
    }
}


extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

extension UINavigationController {
    
    public func presentTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        setNavigationBarHidden(false, animated:true)
    }
    
    public func hideTransparentNavigationBar() {
        setNavigationBarHidden(true, animated:false)
        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default), for:UIBarMetrics.default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
    }
    
    public func removeTransparentNavigationBar() {
        // Remove transparent navigation bar
        navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        navigationBar.shadowImage = nil
        navigationBar.tintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = KColor.darkBackground
    }
}
