//
//  SelectIconVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 20/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit


class SelectIconVC: UIViewController, UICollectionViewDataSource {
    
    let imagesArray = ["assistance",
                    "bill",
                    "birthday",
                    "book",
                    "children",
                    "coffee-cup",
                    "cooking",
                    "credit",
                    "currency",
                    "dumbbell",
                    "envelope",
                    "fashion",
                    "fastfood",
                    "fork",
                    "gamepad",
                    "hand",
                    "handbag",
                    "house",
                    "idea",
                    "image",
                    "jump-rope",
                    "medicine",
                    "milk",
                    "money",
                    "monitor",
                    "payment",
                    "percent",
                    "profit",
                    "salon",
                    "sedan-car-front",
                    "shopping-cart",
                    "stethoscope",
                    "taxi",
                    "training",
                    "washing-machine",
                    "car",
                    "car-2",
                    "skull",
                    "smartphone",
                    "smoking",
                    "bike",
                    "jigsaw"]
    
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    var selectIconDelegate: SelectIcon?
    
//    static func storyboardInstance() -> SelectIconVC? {
//        let storyboard = UIStoryboard(name: "AddCategoryVC", bundle: nil)
//        guard let controller = storyboard.instantiateViewController(withIdentifier: "SelectIconVC") as? SelectIconVC else {
//            fatalError("Can't instantiate ViewController")
//        }
//        return controller
//    }
    
    static func storyboardInstance() -> SelectIconVC? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? SelectIconVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imagesArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "Cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! IconCollectionViewCell
    
        cell.imageView.image = UIImage(named: imagesArray[indexPath.row])
    
        return cell
    }

}

extension SelectIconVC: UICollectionViewDelegate {
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIconDelegate?.selectIcon(name: imagesArray[indexPath.row])
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            // otherwise, dismiss it
            dismiss(animated: true, completion: nil)
        }
    }
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
}
