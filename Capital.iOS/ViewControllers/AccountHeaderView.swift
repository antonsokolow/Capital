//
//  HeaderView.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 01/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit


class AccountHeaderView: UIView {
    
    var secIndex: Int?
    var delegate: HeaderDelegate?
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        self.addSubview(toggleBtn)
        self.addSubview(addBtn)
        self.addSubview(totalLabel)
        
        self.addBorder(side: .bottom, thickness: 1.0, color: #colorLiteral(red: 0.7764705882, green: 0.8235294118, blue: 0.9215686275, alpha: 1), leftOffset: 16.0)
        
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) has not been implemented")
    }
    

    
    lazy var addBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: frame.size.width - self.frame.height + 6, y: self.frame.origin.y, width: self.frame.height, height: self.frame.height))
        //btn.setTitle("+", for: UIControl.State.normal)
        btn.setImage(UIImage(named: "circle-add"), for: .normal)
        //btn.layer.cornerRadius = 0.5 * btn.bounds.size.width
        btn.clipsToBounds = true
        //btn.backgroundColor = UIColor.green
        btn.addTarget(self, action: #selector(onClickAddItem(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var toggleBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: self.frame.origin.x + 16, y: self.frame.origin.y, width: addBtn.frame.origin.x - 8, height: self.frame.height))
        btn.backgroundColor = UIColor.clear
        btn.setTitleColor(#colorLiteral(red: 0.137254902, green: 0.2196078431, blue: 0.3725490196, alpha: 1), for: .normal)
        btn.titleLabel?.font =  .systemFont(ofSize: 16)
        btn.contentHorizontalAlignment = .left
        btn.titleEdgeInsets.left = 0
        btn.setImage(UIImage(named: "triangleExpanded"), for: .normal)
        btn.setImage(UIImage(named: "triangleCollapsed"), for: .selected)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.addTarget(self, action: #selector(onClickHeaderView), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var totalLabel: UILabel = {
        let labelWidth: CGFloat = 180.0
        let label = UILabel(frame: CGRect(x: frame.size.width - addBtn.frame.width - labelWidth - 10 + 20, y: 14, width: labelWidth, height: 20))
        label.text = "10 000 | 40 000"
        label.font = label.font.withSize(12)
        label.textAlignment = .right
        label.backgroundColor = UIColor.clear
        label.textColor = #colorLiteral(red: 0.137254902, green: 0.2196078431, blue: 0.3725490196, alpha: 1)
        
        return label
    }()
    
    @objc func onClickHeaderView() {
        if let idx = secIndex {
            delegate?.callHeader(idx: idx)
        }
    }
    
    @objc func onClickAddItem(_ sender: UIButton) {
        //Button Tapped and open your another ViewController
        if let idx = secIndex {
            delegate?.addItem(idx: idx)
        }
        
    }
}
