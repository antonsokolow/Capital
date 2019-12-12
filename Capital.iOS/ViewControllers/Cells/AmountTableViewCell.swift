//
//  AmountTableViewCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 06/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class AmountTableViewCell: UITableViewCell {

    @IBOutlet weak var AmountTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    var cellDelegate: SelectValueDelegate?
    var property: String?
    var amountEntered: String?
    
    
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "AmountCell"
    }
    
    @IBAction func amountEditingChanged(_ sender: UITextField) {
        
        if let text = sender.text, let name = property {
            let number = NSDecimalNumber(decimal: text.decimalValue)  //(string: text.decimalValue) 
            if number == NSDecimalNumber.notANumber {
                cellDelegate?.properties.setProperty(name: name, value: nil)
            } else {
                cellDelegate?.properties.setProperty(name: name, value: number)
            }
        }
    }
    @IBAction func amountEditindDidBegin(_ sender: UITextField) {
        print("amountEditindDidBegin", sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        AmountTextField.delegate = self
        
        let decimalSeparator = NSLocale.current.decimalSeparator ?? "."
        AmountTextField.text = "0" + decimalSeparator + "00"
        if let property = self.property, let value = cellDelegate?.properties.getProperty(name: property) as? Decimal {
            AmountTextField.text = value.formattedStringDecimal
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension AmountTableViewCell: UITextFieldDelegate {
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
                let number = text.decimalValue
                textField.text = number.formattedStringDecimal
            }
        }
    }
}

extension String {
    var formatAsNumber: String {
        let decimalSeparator = NSLocale.current.decimalSeparator ?? "."
        let charSet = CharacterSet.init(charactersIn: "0123456789" + decimalSeparator)
        var s:String = ""
        for unicodeScalar in self.unicodeScalars
        {
            if charSet.contains(unicodeScalar) {
                if unicodeScalar.value == decimalSeparator.utf8CString[0] {
                    s.append(".")
                } else {
                    s.append(String(unicodeScalar))
                }
            }
        }
        return s
    }
}

extension String {
    var formatAsNumberLocale: String {
        let decimalSeparator = NSLocale.current.decimalSeparator ?? "."
        let charSet = CharacterSet.init(charactersIn: "0123456789" + decimalSeparator)
        var s:String = ""
        for unicodeScalar in self.unicodeScalars
        {
            if charSet.contains(unicodeScalar) {
                s.append(String(unicodeScalar))
            }
        }
        return s
    }
}

extension String {
    static let numberFormatter = NumberFormatter()
    var decimalValue: Decimal {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return Decimal(result.doubleValue)
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return Decimal(result.doubleValue)
            }
        }
        return 0.00
    }
}
