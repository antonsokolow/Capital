//
//  CurrencyListCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 01/02/2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import UIKit

class CurrencyListCell: UITableViewCell {
    @IBOutlet weak var symbol: KLabel!
    @IBOutlet weak var rate: KLabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    let filledStar = UIImage(named: "filledStar")
    let emptyStar = UIImage(named:"emptyStar")
    let highlightedStar = UIImage(named:"highlightedStar")
    
    var viewModel: CurrencyListCellVM? {
        willSet(viewModel) {
            guard let viewModel = viewModel else { return }
            symbol.text = viewModel.symbol
            rate.text = viewModel.rateString
            //favoriteButton.backgroundColor = viewModel.isFavorite ? UIColor.red : UIColor.blue
            favoriteButton.isSelected = viewModel.isFavorite
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        favoriteButton.setImage(emptyStar, for: .normal)
        favoriteButton.setImage(highlightedStar, for: .selected)
        favoriteButton.setImage(filledStar, for: .highlighted)
        favoriteButton.setImage(filledStar, for: [.highlighted, .selected])
    }

    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "CurrencyListCell"
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 80.0
    }
    
    @IBAction func changeFavoriteState(_ sender: UIButton) {
        guard let viewModel = viewModel else { return }
        viewModel.toggleFavorite()
        favoriteButton.isSelected = viewModel.isFavorite
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
