//
//  KTextView.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 30/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
