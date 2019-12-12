//
//  DatePickerTableViewCell.swift
//  LicenseVC
//
//  Created by Anton Sokolov on 26/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class MonthPickerTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var monthPicker: MonthYearPickerView!
    
    var indexPath: IndexPath!
    var cellDelegate: SelectValueDelegate?
    var property: String?
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "MonthPickerCell"
    }
    
    // Nib name
    class func nibName() -> String {
        return "MonthPickerTableViewCell"
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
        //monthPicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
        monthPicker.onDateSelected = { (month: Int, year: Int) in
            self.monthDidChange(month: month, year: year)
        }
        
    }
    
    func updateCell(date: Date, indexPath: IndexPath) {
        //monthPicker.setDate(date, animated: true)
        self.indexPath = indexPath
    }
    
    func monthDidChange(month: Int, year: Int) {
        if let property = self.property {
            cellDelegate?.properties.setProperty(name: property, value: (month: month, year: year))
        }
    }
    
}

