//
//  TransactionTypeTableVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 04/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class SelectTransactionTypeVC: UIViewController {
    
    //var delegate: Delegate?
    var setTransactionVC: ((TransactionType) -> Void)?
    var transactionId: TransactionType?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewCenter: UIView!
    
    var tableHeight: CGFloat!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableHeight = tableView.contentSize.height
        self.viewCenter.frame = CGRect(x: 0, y: 0 - tableHeight, width: view.frame.width, height: view.frame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.viewCenter.center.y += self.tableHeight
                        //self.view.center.y += self.tableHeight
        }, completion: nil)
    }
    
    // По кнопке Готово скрываем таблицу
    func done() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear],
                       animations: {
                        self.viewCenter.center.y -= self.tableHeight
                        self.view.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            //self.delegate?.setTransactionVC(transaction: self.transactionId!)
            self.view.removeFromSuperview()
        })
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectTransactionTypeVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = TransactionType(id: indexPath.row)!.name
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.navigationController?.isNavigationBarHidden = true
        tableView.deselectRow(at: indexPath, animated: true)
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear],
                       animations: {
                        //self.view.center.y -= self.tableHeight
                        self.viewCenter.center.y -= self.tableHeight
                        self.view.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            //self.navigationController?.isNavigationBarHidden = false
            self.setTransactionVC?(TransactionType(id: indexPath.row)!)
            self.view.removeFromSuperview()
        })
    }
    
    func animHide() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear],
                       animations: {
                        self.view.center.y -= self.tableHeight
                        self.view.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            self.view.removeFromSuperview()
        })
    }
}

extension UIView{
    func animShow(){
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.center.y += self.bounds.height
                        self.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    func animHide(){
        UIView.animate(withDuration: 1, delay: 0, options: [.curveLinear],
                       animations: {
                        self.center.y -= self.bounds.height
                        self.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            self.isHidden = true
        })
    }
}
