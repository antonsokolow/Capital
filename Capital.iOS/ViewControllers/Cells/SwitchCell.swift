//
//  SwitchCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 02/12/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    
    @IBOutlet weak var title: KLabel!
    @IBOutlet weak var switchOutlet: UISwitch!
    
    var cellDelegate: SelectValueDelegate?
    var property: String?
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "SwitchCell"
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 50.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let property = self.property, cellDelegate?.properties.getPropertyValue(name: property) == nil {
            cellDelegate?.properties.setProperty(name: property, value: false)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if let property = self.property {
            cellDelegate?.properties.setProperty(name: property, value: sender.isOn)
        }
    }
    
}
