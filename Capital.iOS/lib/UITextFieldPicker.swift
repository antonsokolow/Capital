//
//  UITextFieldPicker.swift
//  Date Picker in a UITextField
//
//  Created by Anton Sokolov on 04/12/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class UITextFieldPicker: UITextField {
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
}
