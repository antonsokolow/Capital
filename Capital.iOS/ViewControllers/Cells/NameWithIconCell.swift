//
//  NameWithIconCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 21/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class NameWithIconCell: UITableViewCell, SelectIcon {
    
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    var cellDelegate: SelectValueDelegate?
    var property: String?
    var pushHandler: ((UIViewController) -> Void)?
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "NameWithIconCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func selectIcon(name: String) {
        //icon = name
        iconButton.imageView?.image = UIImage(named: name)
        cellDelegate?.properties.setProperty(name: "icon", value: name)
    }
    
    @IBAction func nameTextFieldChanged(_ sender: UITextField) {
        if let text = sender.text, let name = property {
            if text.isEmpty {
                cellDelegate?.properties.removeProperty(name: name)
            } else {
                cellDelegate?.properties.setProperty(name: name, value: text)
            }
        }
    }
    
    @IBAction func iconButtonTapped(_ sender: UIButton) {
        print("icon button tapped")
        if let viewController = SelectIconVC.storyboardInstance() {
            viewController.selectIconDelegate = self
            pushHandler?(viewController)
            //navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
