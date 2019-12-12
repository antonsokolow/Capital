//
//  AmountCellTableViewCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 13/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
    @IBOutlet weak var name: KLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "AccountCell"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
