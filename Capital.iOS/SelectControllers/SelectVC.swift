//
//  SelectVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 08/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class SelectVC: UIViewController {
    
    var type: Any?
    var delegate: SelectValueDelegate?
    var property: String?
    var updateIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
