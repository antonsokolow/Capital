//
//  IconCollectionViewCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 20/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        imageView.layer.borderColor = KColor.border.cgColor
        imageView.layer.masksToBounds = true
        //imageView.clipsToBounds = false
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = imageView.frame.height/2
    }
    
}
