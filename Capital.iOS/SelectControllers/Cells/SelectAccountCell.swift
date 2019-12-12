//
//  SelectAccountCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 29/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class SelectAccountCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var balance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
