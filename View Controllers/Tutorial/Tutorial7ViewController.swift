//
//  Tutorial7ViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 5/12/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class Tutorial7ViewController: UIViewController {
    
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        uiView.backgroundColor = .clear

        // Do any additional setup after loading the view.
        
        //        set view constraints
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
            let verticalConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0 + 15)
        
            let widthConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenWidth - screenWidth/4)
        
            let heightConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenHeight - topDistance - 100)
        
            view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    



}
