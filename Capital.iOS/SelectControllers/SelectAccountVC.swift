//
//  SelectAccountVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 04/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class SelectAccountVC: SelectVC {

    @IBOutlet weak var tableView: UITableView!
    var data = [AccountDataModel]()
    var propertyName: String!
    
    static func storyboardInstance() -> SelectAccountVC? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? SelectAccountVC
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .lightContent .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
//        if let itemType = type as? AccountType {
//            data = DataStore.shared.getAccounts(type: itemType)
//        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension SelectAccountVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data[section].accounts.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].accountType?.name
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SelectAccountCell
        
        
        cell.name.text = data[indexPath.section].accounts[indexPath.row].name
        let accountBalance = data[indexPath.section].accounts[indexPath.row].balance
        cell.balance.text = accountBalance.formattedString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.properties.setProperty(name: propertyName, value: data[indexPath.section].accounts[indexPath.row])
        if let indexPath = updateIndexPath {
            self.delegate?.update(indexPath: indexPath)
        }
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            // otherwise, dismiss it
            dismiss(animated: true, completion: nil)
        }
    }
}
