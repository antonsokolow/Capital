//
//  CurrencyCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 01/02/2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {
    
    @IBOutlet weak var name: KLabel!
    @IBOutlet weak var currency: KLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "CurrencyCell"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
