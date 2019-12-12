//
//  CategoryCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 11/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "CategoryCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
