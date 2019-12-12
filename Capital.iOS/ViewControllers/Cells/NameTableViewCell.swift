//
//  NameTableViewCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 19/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class NameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameTextField: UITextField!
    var cellDelegate: SelectValueDelegate?
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "NameCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func nameChanged(_ sender: UITextField) {
        if let text = sender.text {
            if text.isEmpty {
                cellDelegate?.properties.removeProperty(name: "name")
            } else {
                cellDelegate?.properties.setProperty(name: "name", value: text)
            }
        }
    }
    
    
}
