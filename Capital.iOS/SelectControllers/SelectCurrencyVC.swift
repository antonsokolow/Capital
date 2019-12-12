//
//  SelectCurrencyVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 01/02/2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import UIKit
import CoreData

class SelectCurrencyVC: SelectVC {
    @IBOutlet weak var tableView: UITableView!

    var viewModel = SelectCurrencyVM()
    
    static func storyboardInstance() -> SelectCurrencyVC? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? SelectCurrencyVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.tableFooterView = UIView()
        
        viewModel.reload = self.reload
        viewModel.prepareData()
    }
    

    func reload(changes: ViewModelChange) {
        tableView.applyChanges(changes: changes)
    }

}

extension SelectCurrencyVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeaderInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyListCell.reuseIdentifier()) as! CurrencyListCell
        
        cell.viewModel = viewModel.getCurrencyListCellVM(at: indexPath)
        
        return cell
    }
}

extension SelectCurrencyVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let property = self.property {
            self.delegate?.properties.setProperty(name: property, value: viewModel.getValue(at: indexPath).symbol)
            if let indexPath = updateIndexPath {
                self.delegate?.update(indexPath: indexPath)
            }
        }
        
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            // otherwise, dismiss it
            dismiss(animated: true, completion: nil)
        }
    }
}
