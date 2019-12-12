//
//  CollectionViewCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 02/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

@IBDesignable class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var amountBudget: UILabel!
    @IBOutlet weak var amountSpent: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.borderColor = KColor.border.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = imageView.frame.height/2
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 140.0
    }
}
