//
//  KLabel.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 13/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

@IBDesignable class KLabel: UILabel {
    
    override func awakeFromNib() {
        font = UIFont(name: "Helvetica Neue", size: 16.0)
        textColor = KColor.darkText
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
