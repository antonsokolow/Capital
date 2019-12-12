//
//  ButtonCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 05/12/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {

    var property: String?
    var buttonTouched: (() -> Void)?
    @IBOutlet weak var button: UIButton!
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "ButtonCell"
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 120.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.bounds.size.width)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonTouched(_ sender: UIButton) {
        buttonTouched?()
    }
    
}
