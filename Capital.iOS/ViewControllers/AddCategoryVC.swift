//
//  addCategoryVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 03/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class AddCategoryVC: UIViewController, SelectIcon {
    
    static func storyboardInstance() -> AddCategoryVC? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? AddCategoryVC
    }
    
    var categoryId: Int!
    var type: CategoryType!
    var icon: String?
    @IBOutlet weak var iconButton: UITextField!
    @IBOutlet weak var categoryIcon: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .lightContent .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        self.navigationItem.title = "Добавить"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        //navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        iconButton.becomeFirstResponder()
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil
        {
            print("Back button was pressed.")
        }
    }
    
    @objc func save() {
        let category = Category(context: DataHandler.shared.viewContext)
        category.name = iconButton.text
        category.type = type.rawValue
        category.icon = icon
        
        // if you use navigation controller, just pop ViewController:
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            // otherwise, dismiss it
            dismiss(animated: true, completion: nil)
        }
    }
    
    func selectIcon(name: String) {
        icon = name
        categoryIcon.imageView?.image = UIImage(named: name)
    }
    
    @IBAction func iconButtonTapped(_ sender: Any) {
        if let viewController = SelectIconVC.storyboardInstance() {
            viewController.selectIconDelegate = self
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func checkIfValid() -> Bool {
        let result = true
        
        navigationItem.rightBarButtonItem?.isEnabled = result
        return result
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
