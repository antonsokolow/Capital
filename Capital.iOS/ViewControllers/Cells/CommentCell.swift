//
//  CommentCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 09/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//


import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var title: UILabel!
    var cellDelegate: SelectValueDelegate?
    var property: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "CommentCell"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if let text = sender.text, let name = property {
            if text.isEmpty {
                cellDelegate?.properties.removeProperty(name: name)
            } else {
                cellDelegate?.properties.setProperty(name: name, value: text)
            }
        }
    }
}

extension CommentCell: UITextFieldDelegate {
    override func willChangeValue(forKey key: String) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //print("shouldChangeCharactersIn", range, string, textField.text)
        
        //amountEntered?.insert(string, at: range.location)
        //print("###", amountEntered, range, string)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

