//
//  CashTableViewCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 22/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class CashTableViewCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var categoryLabel: KLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
