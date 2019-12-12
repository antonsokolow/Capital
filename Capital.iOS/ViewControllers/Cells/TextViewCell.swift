//
//  TextViewCell.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 30/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class TextViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    var cellDelegate: SelectValueDelegate?
    var property: String?
    let placeholder = "Комментарий"
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "TextViewCell"
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 160.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        
        textView.text = placeholder
        textView.textColor = KColor.lightText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Update text
    func updateText(text: String) {
        textView.text = text
        textView.textColor = KColor.darkText
    }

}

extension TextViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, let name = property {
            if text.isEmpty {
                cellDelegate?.properties.removeProperty(name: name)
            } else {
                cellDelegate?.properties.setProperty(name: name, value: text)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == KColor.lightText {
            textView.text = nil
            textView.textColor = KColor.darkText
        }
    }
    
}
