//
//  BudgetTableViewCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 02/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: BudgetCollectionView!
    var data = [Budget]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        setupLongPressGesture()
        
        
        }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .ended {
            let touchPoint = gestureRecognizer.location(in: self.collectionView)
            if let indexPath = self.collectionView.indexPathForItem(at: touchPoint) {
                // get the cell at indexPath (the one you long pressed)
                //let cell = self.collectionView.cellForItem(at: indexPath)
                
                // do stuff with the cell
            } else {
                print("couldn't find index path")
            }
        }
    }
    
}



extension Formatter {
    static let stringFormatters: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
}

extension Decimal {
    var formattedString: String {
        //return Formatter.stringFormatters.string(for: self) ?? ""
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
        formatter.numberStyle = .currency
        if let formattedAmount = formatter.string(from: self as NSNumber) {
            return ("\(formattedAmount)")
        } else {
            return ("\(self)")
        }
    }
}


extension Decimal {
    var formattedStringDecimal: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        if let formattedAmount = formatter.string(from: self as NSNumber) {
            return ("\(formattedAmount)")
        } else {
            return ("\(self)")
        }
    }
}

extension Decimal {
    var formattedStringDecimalPrefix: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.positivePrefix = "+"
        if let formattedAmount = formatter.string(from: self as NSNumber) {
            return ("\(formattedAmount)")
        } else {
            return ("\(self)")
        }
    }
}
