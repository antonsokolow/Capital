//
//  PageVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 08/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class PageVC: UIPageViewController, SetTitle {
    
    let searchController = UISearchController(searchResultsController: nil)
    var monthName: String?
    var budgetController: BudgetViewController?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .lightContent .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepereData()
        
        dataSource = self
        delegate = self
        
        
        // Отключаем листание по тапу
        for recognizer in self.gestureRecognizers {
            if recognizer is UITapGestureRecognizer {
                recognizer.isEnabled = false
            }
        }
        
        if #available(iOS 11, *) {
            //self.navigationController?.navigationBar.prefersLargeTitles = true
            
            //navigationController?.navigationBar.topItem?.title = "Июль"
            //navigationController?.navigationBar.topItem?.largeTitleDisplayMode = .always
            //navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
       // self.navigationItem.largeTitleDisplayMode = .never
//        self.navigationItem.largeTitleDisplayMode = .always
//        self.navigationItem.largeTitleDisplayMode = .automatic
//        self.navigationItem.searchController = searchController
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTransaction))
        //self.navigationItem.title = monthName
    }
    
    func prepereData() {
        
        let monthyear = Monthyear.getNow()
        
        let startingViewController: BudgetViewController = self.viewControllerAtIndex(monthyear, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        self.navigationItem.title = self.monthName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11, *) {
            navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
        
        self.navigationController?.presentTransparentNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.removeTransparentNavigationBar()
    }
    
    
    func setTitle(title: String) {
        
        self.monthName = title
        //self.navigationItem.title = title
    }
    
    @objc func addTransaction() {
        if let viewController = AddTransactionVC.storyboardInstance() {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}

extension PageVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func viewControllerAtIndex(_ index: Monthyear, storyboard: UIStoryboard) -> BudgetViewController? {
        // Return the data view controller for the given index.
        
        // Create a new view controller and pass suitable data.
        if (index.month >= 12) {
            return nil
        }
        guard let controller = BudgetViewController.storyboardInstance() else {
            ErrorHandler.shared.reportError(message: "PageVC: 108")
            return nil
        }
        
        controller.viewModel = BudgetViewVM(monthyear: index)
        
        controller.setTitleDelegate = self
        return controller
    }
    
    func indexOfViewController(_ viewController: BudgetViewController) -> Monthyear {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        
        return viewController.viewModel.monthyear
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! BudgetViewController)
        if (index.month == NSNotFound) || (index.year == NSNotFound) {
            return nil
        }
        if (index.month == 0) {
            index.month = 12 - 1
            index.year -= 1
        } else {
            index.month -= 1
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! BudgetViewController)

        if (index.month == NSNotFound) || (index.year == NSNotFound) {
            return nil
        }
        
        index.month += 1
        
        if index.month == 12 {
            index.month = 0
            index.year += 1
        }
        
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
    {
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if (completed)
        {
            //No need as we had Already managed This action in other Delegate
            self.navigationItem.title = self.monthName
            //navigationController?.navigationBar.topItem?.title = self.monthName
        }
        else
        {
            ///Update Current Index
        }
    }
    
    
}

extension Date {
    func getNextMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)
    }
    
    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
}

extension PageVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
