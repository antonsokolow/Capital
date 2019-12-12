//
//  OnboardingVC.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 11/12/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import UIKit

class OnboardingVC: UIViewController {
    
    var swiftyOnboard: SwiftyOnboard!
    let colors:[UIColor] = [#colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 0.9921568627, alpha: 1),#colorLiteral(red: 0.2666860223, green: 0.5116362572, blue: 1, alpha: 1),#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1),#colorLiteral(red: 0.9980840087, green: 0.3723873496, blue: 0.4952875376, alpha: 1),#colorLiteral(red: 0.2666860223, green: 0.5116362572, blue: 1, alpha: 1),#colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 0.9921568627, alpha: 1)]
    var titleArray: [String] = [
        "Начало работы",
        "Запланируйте бюджет",
        "Запланируйте бюджет",
        "Настройте категории",
        "Внесите счета",
        "Записывайте расходы и доходы"
    ]
    var subTitleArray: [String] = [
        "Добавьте категории доходов и расходов, а затем заложите на них деньги. Сколько – решать вам.",
        "Укажите в наличности все деньги, которыми вы сейчас располагаете, а также добавьте кредитные карты, активы и обязательства.",
        "Планируйте бюджеты и ставьте цели минимум на 3 месяца вперед. Свайп влево – будущий период, вправо – прошлый.",
        "Фиксируйте в приложении любые движения средств, будь то покупка товара или получение зарплаты. Исполнять бюджет можно одним кликом.",
        "Ничего страшного, если жизнь внесла в бюджет свои коррективы. Вы легко можете отредактировать категории, остатки по счетам и транзакции.",
        "Нажмите на иконку категории и внесите средства. Также вы можете воспользоваться кнопкой транзакции в правом верхнем углу экрана."
    ]
    
    var gradiant: CAGradientLayer = {
        //Gradiant for the background view
        let blue = UIColor(red: 69/255, green: 127/255, blue: 202/255, alpha: 1.0).cgColor
        let purple = UIColor(red: 166/255, green: 172/255, blue: 236/255, alpha: 1.0).cgColor
        let gradiant = CAGradientLayer()
        gradiant.colors = [purple, blue]
        gradiant.startPoint = CGPoint(x: 0.5, y: 0.18)
        return gradiant
    }()
    
    static func storyboardInstance() -> OnboardingVC? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? OnboardingVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        swiftyOnboard = SwiftyOnboard(frame: view.frame)
        view.addSubview(swiftyOnboard)
        swiftyOnboard.dataSource = self
        swiftyOnboard.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func gradient() {
        //Add the gradiant to the view:
        self.gradiant.frame = view.bounds
        view.layer.addSublayer(gradiant)
    }
    
    @objc func handleSkip() {
        startKapital()
        //swiftyOnboard?.goToPage(index: 2, animated: true)
    }
    
    @objc func handleContinue(sender: UIButton) {
        let index = sender.tag
        if index == titleArray.count - 1 {
            startKapital()
        } else {
            swiftyOnboard.goToPage(index: index + 1, animated: true)
        }
    }
    
    func startKapital() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController(), let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController {
            UIView.transition(from: rootViewController.view, to: vc.view, duration: 0.8, options: [.transitionCurlUp, .curveEaseInOut], completion: {
                _ in
                appDelegate.window?.rootViewController = vc
            })
        }
    }
    

}

extension OnboardingVC: SwiftyOnboardDataSource {
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return titleArray.count
    }
    
    func swiftyOnboardBackgroundColorFor(_ swiftyOnboard: SwiftyOnboard, atIndex index: Int) -> UIColor? {
        //Return the background color for the page at index:
        return colors[index]
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let view = SwiftyOnboardPage()
        
        //Set the image on the page:
        view.imageView.image = UIImage(named: "onboard\(index)")
        
        //Set the font and color for the labels:
        view.title.font = UIFont(name: "Lato-Heavy", size: 22)
        view.subTitle.font = UIFont(name: "Lato-Regular", size: 16)
        
        //Set the text in the page:
        view.title.text = titleArray[index]
        view.subTitle.text = subTitleArray[index]
        
        //Return the page for the given index:
        return view
    }
}

extension OnboardingVC: SwiftyOnboardDelegate {
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = SwiftyOnboardOverlay()
        
        //Setup targets for the buttons on the overlay view:
        overlay.skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        overlay.continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        
        //Setup for the overlay buttons:
        overlay.continueButton.titleLabel?.font = UIFont(name: "Lato-Bold", size: 16)
        overlay.continueButton.setTitleColor(UIColor.white, for: .normal)
        overlay.skipButton.setTitleColor(UIColor.white, for: .normal)
        overlay.skipButton.titleLabel?.font = UIFont(name: "Lato-Heavy", size: 16)
        overlay.continueButton.setTitle(NSLocalizedString("Дальше", comment: ""), for: .normal)
        overlay.skipButton.setTitle("Пропустить", for: .normal)
        
        //Return the overlay view:
        return overlay
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let currentPage = round(position)
        overlay.pageControl.currentPage = Int(currentPage)
        overlay.continueButton.tag = Int(position)
        
        if currentPage == 0.0 || currentPage == 1.0 {
            overlay.continueButton.setTitle("Дальше", for: .normal)
            overlay.skipButton.setTitle("Пропустить", for: .normal)
            overlay.skipButton.isHidden = false
        } else {
            overlay.continueButton.setTitle("Приступить", for: .normal)
            overlay.skipButton.isHidden = true
        }
    }
}
