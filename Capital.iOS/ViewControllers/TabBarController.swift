//
//  TabBarController.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 06/11/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    static func storyboardInstance() -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.backgroundImage = getImageWithColor(color: KColor.lightBackground, size: CGSize(width: 1.0, height: 1.0))
        tabBar.shadowImage = getImageWithColor(color: KColor.lightText, size: CGSize(width: 1.0, height: 1.0))
    }
    
    // The `shadowImage` property is the one that we will use to set the custom top border.
    // We will create the `UIImage` of 1x5 points size filled with the red color and assign it to the `shadowImage` property.
    // This image then will get repeated and create the red top border of 5 points width.
    
    // A helper function that creates an image of the given size filled with the given color.
    // http://stackoverflow.com/a/39604716/1300959
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage
    {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    

}


extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
