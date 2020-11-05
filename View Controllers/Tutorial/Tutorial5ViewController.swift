//
//  Tutorial5ViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 5/11/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class Tutorial5ViewController: UIViewController {
    
// Get distance from top, based on status bar and navigation
    public var topDistance : CGFloat{
         get{
             if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                 return 0
             }else{
                let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
                let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                return barHeight + statusBarHeight
             }
         }
    }
    
    
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var swtchBadges: UISwitch!
    
    @IBOutlet weak var swtchBanners: UISwitch!
    
    @IBOutlet weak var uiView: UIView!
    
    @IBOutlet weak var viewIcon: UIView!
    
    @IBOutlet weak var viewDescription: UIView!
    
    @IBOutlet weak var viewTitle: UIView!
    
    @IBOutlet weak var viewBadgesSwitch: UIView!
    
    @IBOutlet weak var viewBannersSwitch: UIView!
    
    @IBOutlet weak var viewBadges: UIView!
    
    @IBOutlet weak var viewBanners: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        default the switches to on
        UserDefaults.standard.set(true, forKey: "notificationBanners")
        UserDefaults.standard.set(true, forKey: "notificationBadge")
        
        uiView.backgroundColor = .clear
        viewIcon.backgroundColor = .clear
        viewTitle.backgroundColor = .clear
        viewBadges.backgroundColor = .clear
        viewBanners.backgroundColor = .clear
        viewDescription.backgroundColor = .clear
        viewBadgesSwitch.backgroundColor = .clear
        viewBannersSwitch.backgroundColor = .clear
        

//        targets to monitor the change of the switches
        swtchBadges.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        swtchBanners.addTarget(self, action: #selector(stateChanged), for: .valueChanged)

        
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        
        lblDescription.adjustsFontSizeToFitWidth = true
        
        //        set view constraints
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
            let verticalConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0 + 15)
        
            let widthConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenWidth - screenWidth/4)
        
            let heightConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenHeight - topDistance - 100)
        
            view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        
        ////        set the constraints for the items within the view
        let totalViewHeight = CGFloat(screenHeight - topDistance - 100)
        let titleHeight = CGFloat(31)
        let iconHeight = CGFloat(200)
        let descriptionHeight = CGFloat(100.0)
        let mainTitleHeight = CGFloat(34.0)
        let remainingDistance = totalViewHeight - titleHeight*3 - mainTitleHeight - descriptionHeight*3
        let equalDistances = CGFloat(30)
        print("totalViewHeight \(totalViewHeight) - remainingDistance \(remainingDistance) - equalDistances \(equalDistances)")
        
        
//        sets the constraints for the how it works title, distance = vertical position to the next view from its top
        setConstraints(uiview: viewIcon, distance: equalDistances, toView: uiView, height: iconHeight, width: screenWidth - screenWidth/4, xConxtraint: NSLayoutConstraint.Attribute.top, xConstraintAmt: 0)
        setConstraints(uiview: viewTitle, distance: equalDistances*1 + iconHeight , toView: uiView, height: mainTitleHeight, width: screenWidth - screenWidth/4 - 20, xConxtraint: NSLayoutConstraint.Attribute.left, xConstraintAmt: 10)
        setConstraints(uiview: viewDescription, distance: equalDistances*2 + iconHeight + mainTitleHeight, toView: uiView, height: descriptionHeight, width: screenWidth - screenWidth/4 - 20, xConxtraint: NSLayoutConstraint.Attribute.left, xConstraintAmt: 10)
        setConstraints(uiview: viewBadges, distance: equalDistances*3 + iconHeight + mainTitleHeight + descriptionHeight, toView: uiView, height: titleHeight, width: 100, xConxtraint: NSLayoutConstraint.Attribute.left, xConstraintAmt: 65)
        setConstraints(uiview: viewBadgesSwitch, distance: equalDistances*3 + iconHeight + mainTitleHeight + descriptionHeight, toView: uiView, height: titleHeight, width: 47, xConxtraint: NSLayoutConstraint.Attribute.left, xConstraintAmt: 10)
        setConstraints(uiview: viewBanners, distance: equalDistances*3 + iconHeight + mainTitleHeight + descriptionHeight + titleHeight + 4, toView: uiView, height: titleHeight, width: 100, xConxtraint: NSLayoutConstraint.Attribute.left, xConstraintAmt: 65)
        setConstraints(uiview: viewBannersSwitch, distance: equalDistances*3 + iconHeight + mainTitleHeight + descriptionHeight + titleHeight + 4, toView: uiView, height: titleHeight, width: 47, xConxtraint: NSLayoutConstraint.Attribute.left, xConstraintAmt: 10)
    }
    
    
    func setConstraints(uiview: UIView, distance: CGFloat, toView: UIView, height: CGFloat, width: CGFloat, xConxtraint: NSLayoutConstraint.Attribute, xConstraintAmt: CGFloat){
            
    //        puts the item in the center of the screen width ways
            let constraint = NSLayoutConstraint(item: uiview, attribute: xConxtraint, relatedBy: .equal, toItem: toView, attribute: xConxtraint, multiplier: 1, constant: xConstraintAmt)
            
    //        sets the vertical position of the item within the screen
            let verticalConstraint = NSLayoutConstraint(item: uiview, attribute: .top, relatedBy: .equal, toItem: toView, attribute: .top, multiplier: 1, constant: distance)
            
    //        sets the hight of the item
            let heightConstraint = NSLayoutConstraint(item: uiview, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: height)
            
    //    sets the width of the item
            let widthConstraint = NSLayoutConstraint(item: uiview, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: width)
            
            uiView.addConstraints([constraint, verticalConstraint, heightConstraint, widthConstraint])
        }
    
    
//    check to see if the user changed thier notification choice
    @objc func stateChanged() {
        if swtchBanners.isOn{
            UserDefaults.standard.set(true, forKey: "notificationBanners")
            print("notificationBanners - true")
        }
        else{
            UserDefaults.standard.set(false, forKey: "notificationBanners")
            print("notificationBanners - false")
        }
        if swtchBadges.isOn{
          UserDefaults.standard.set(true, forKey: "notificationBadge")
            print("notificationBadge - true")
        }
        else{
            UserDefaults.standard.set(false, forKey: "notificationBadge")
            print("notificationBadge - false")
        }
    }



}
