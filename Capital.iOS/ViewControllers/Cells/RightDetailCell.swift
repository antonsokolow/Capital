//
//  RightDetailCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 30/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class RightDetailCell: UITableViewCell {

    @IBOutlet weak var titleLabel: KLabel!
    @IBOutlet weak var detailLabel: KLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
