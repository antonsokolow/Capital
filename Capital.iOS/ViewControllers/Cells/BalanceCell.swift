//
//  BalanceCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 08/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class BalanceCell: UITableViewCell {
    
    @IBOutlet weak var balance: UITextField!
    @IBOutlet weak var title: UILabel!
    var cellDelegate: SelectValueDelegate?
    var property: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let decimalSeparator = NSLocale.current.decimalSeparator ?? "."
        
        if let property = self.property, let value = cellDelegate?.properties.getProperty(name: property) as? String {
            balance.text = value
        } else {
            balance.text = "0" + decimalSeparator + "0"
        }
    }
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "BalanceCell"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func balanceChanged(_ sender: UITextField) {
        if let text = sender.text, let name = property {
            let number = NSDecimalNumber(decimal: text.decimalValue)
            if number == NSDecimalNumber.notANumber {
                cellDelegate?.properties.setProperty(name: name, value: nil)
            } else {
                cellDelegate?.properties.setProperty(name: name, value: number)
            }
        }
    }
}

extension BalanceCell: UITextFieldDelegate {
    override func willChangeValue(forKey key: String) {
        print("willChangeValue", key)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //print("shouldChangeCharactersIn", range, string, textField.text)
        
        //amountEntered?.insert(string, at: range.location)
        //print("###", amountEntered, range, string)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            let number = NSDecimalNumber(string: text.formatAsNumber)
            if number == 0 {
                textField.text = ""
            } else {
                textField.text = text.formatAsNumberLocale
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            if text.isEmpty {
                let decimalSeparator = NSLocale.current.decimalSeparator ?? "."
                textField.text = "0" + decimalSeparator + "0"
            } else {
                let number = NSDecimalNumber(decimal: text.decimalValue)
                if number == NSDecimalNumber.notANumber {
                    //textField.text = "0" + decimalSeparator + "0"
                } else {
                    textField.text = number.decimalValue.formattedStringDecimal
                }
            }
        }
    }
}
