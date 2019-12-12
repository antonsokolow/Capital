//
//  AccountTableViewCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 01/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var accountAmount: UILabel!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var accountIcon: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
