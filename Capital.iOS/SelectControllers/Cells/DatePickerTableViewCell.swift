//
//  DatePickerTableViewCell.swift
//  LicenseVC
//
//  Created by Anton Sokolov on 24/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var indexPath: IndexPath!
    var cellDelegate: SelectValueDelegate?
    var property: String?
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "DatePickerCell"
    }
    
    // Nib name
    class func nibName() -> String {
        return "DatePickerTableViewCell"
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 162.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func initView() {
        datePicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
    }
    
    func updateCell(date: Date, indexPath: IndexPath) {
        datePicker.setDate(date, animated: true)
        self.indexPath = indexPath
    }
    
    @objc func dateDidChange(_ sender: UIDatePicker) {
        if let property = self.property {
            cellDelegate?.properties.setProperty(name: property, value: sender.date)
        }
    }
    
}
