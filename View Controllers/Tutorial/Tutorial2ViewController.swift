//
//  Tutorial2ViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 27/01/2020.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class Tutorial2ViewController: UIViewController {

    /// Get distance from top, based on status bar and navigation
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
    
    @IBOutlet weak var uiView: UIView!
    
    
    @IBOutlet weak var lblHowItWorks: UILabel!
    
    @IBOutlet weak var lblStep1: UILabel!
    
    @IBOutlet weak var lblStep1Detail: UILabel!
    
    @IBOutlet weak var lblStep2: UILabel!
    
    @IBOutlet weak var lblStep2Detail: UILabel!
    
    @IBOutlet weak var lblStep3: UILabel!
    
    
    @IBOutlet weak var lblStep3Detail: UILabel!
    
    @IBOutlet weak var viewHowitWorks: UIView!
    
    
    @IBOutlet weak var view1: UIView!
    
    @IBOutlet weak var view1d: UIView!
    
    @IBOutlet weak var view2: UIView!
    
    @IBOutlet weak var view2d: UIView!
    
    
    @IBOutlet weak var view3: UIView!
    
    @IBOutlet weak var view3d: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        uiView.backgroundColor = .clear
        view1.backgroundColor = .clear
        view1d.backgroundColor = .clear
        view2.backgroundColor = .clear
        view2d.backgroundColor = .clear
        view3.backgroundColor = .clear
        view3d.backgroundColor = .clear
        viewHowitWorks.backgroundColor = .clear
        
        
        lblHowItWorks.adjustsFontSizeToFitWidth = true
        lblStep1.adjustsFontSizeToFitWidth = true
        lblStep2.adjustsFontSizeToFitWidth = true
        lblStep3.adjustsFontSizeToFitWidth = true
        lblStep1Detail.adjustsFontSizeToFitWidth = true
        lblStep2Detail.adjustsFontSizeToFitWidth = true
        lblStep3Detail.adjustsFontSizeToFitWidth = true
        
        
        //        set view constraints
        uiView.translatesAutoresizingMaskIntoConstraints = false
         viewHowitWorks.translatesAutoresizingMaskIntoConstraints = false
         view1.translatesAutoresizingMaskIntoConstraints = false
         view1d.translatesAutoresizingMaskIntoConstraints = false
         view2.translatesAutoresizingMaskIntoConstraints = false
         view2d.translatesAutoresizingMaskIntoConstraints = false
         view3.translatesAutoresizingMaskIntoConstraints = false
        view3d.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
            let verticalConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0 + 15)
        
            let widthConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenWidth - screenWidth/4)
        
            let heightConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenHeight - topDistance - 100)
        
            view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
            view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
////        set the constraints for the items within the view
        let totalViewHeight = CGFloat(screenHeight - topDistance - 100)
        let titleHeight = CGFloat(22.0)
        let descriptionHeight = CGFloat(100.0)
        let mainTitleHeight = CGFloat(34.0)
        let remainingDistance = totalViewHeight - titleHeight*3 - mainTitleHeight - 300
        let equalDistances = remainingDistance / 4
        print("totalViewHeight \(totalViewHeight) - remainingDistance \(remainingDistance) - equalDistances \(equalDistances)")
        
        
//        sets the constraints for the how it works title, distance = vertical position to the next view from its top
        setConstraints(uiview: viewHowitWorks, distance: equalDistances, toView: uiView, height: mainTitleHeight)
        
//        sets the constraints for the first title
        setConstraints(uiview: view1, distance: equalDistances*2 + mainTitleHeight, toView: uiView, height: titleHeight)
        
//        sets the constraints for the first desctiption
        setConstraints(uiview: view1d, distance: equalDistances*2 + mainTitleHeight + titleHeight, toView: uiView, height: descriptionHeight)

//        sets the constraints for the seconds title
        setConstraints(uiview: view2, distance: equalDistances*3 + mainTitleHeight + titleHeight + descriptionHeight, toView: uiView, height: titleHeight)

//        sets the constraints for the first desctiption
        setConstraints(uiview: view2d, distance: equalDistances*3 + mainTitleHeight + titleHeight*2 + descriptionHeight, toView: uiView, height: descriptionHeight)
        
//        sets the constraints for the first title
        setConstraints(uiview: view3, distance: equalDistances*4 + mainTitleHeight + titleHeight*2 + descriptionHeight*2, toView: uiView, height: titleHeight)
        
//        sets the constraints for the first desctiption
        setConstraints(uiview: view3d, distance: equalDistances*4 + mainTitleHeight + titleHeight*3 + descriptionHeight*2, toView: uiView, height: descriptionHeight)

    }
    
    func setConstraints(uiview: UIView, distance: CGFloat, toView: UIView, height: CGFloat){
        
//        puts the item in the center of the screen width ways
        let constraint = NSLayoutConstraint(item: uiview, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: toView, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 10)
        
//        sets the vertical position of the item within the screen
        let verticalConstraint = NSLayoutConstraint(item: uiview, attribute: .top, relatedBy: .equal, toItem: toView, attribute: .top, multiplier: 1, constant: distance)
        
//        sets the hight of the item
        let heightConstraint = NSLayoutConstraint(item: uiview, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: height)
        
//    sets the width of the item
        let widthConstraint = NSLayoutConstraint(item: uiview, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenWidth - screenWidth/4 - 20)
        
        uiView.addConstraints([constraint, verticalConstraint, heightConstraint, widthConstraint])
        
    }

}
