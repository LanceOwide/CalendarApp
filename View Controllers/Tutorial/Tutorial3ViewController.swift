//
//  Tutorial3ViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 27/01/2020.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class Tutorial3ViewController: UIViewController {

    
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
    

    var lblTitle = UILabel()
    var lblTitle1 = UILabel()
    var lblTitle2 = UILabel()
    var lblTitle3 = UILabel()
    var lblDesc1 = UILabel()
    var lblDesc2 = UILabel()
    var lblDesc3 = UILabel()
    
    var imgView1 = UIImageView()
    var imgView2 = UIImageView()
    var imgView3 = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        
        //        set view constraints
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .clear
        
        let horizontalConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
            let verticalConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0 + 15)
        
            let widthConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenWidth - screenWidth/4)
        
            let heightConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenHeight - topDistance - 100)
        
            view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        
//        constants used in the constraints
        let titleHeight = CGFloat(30)
        let descHeight = CGFloat(100)
        let imgHeight = CGFloat(60)
        let gapHeight = CGFloat(10)
        let titleGapHeight = CGFloat(10)
        let leftGap = CGFloat(5)
        
        
        
        uiView.addSubview(lblTitle)
        lblTitle.text = "How it works"
        lblTitle.textAlignment = .center
        lblTitle.textColor = .white
        lblTitle.font = UIFont.boldSystemFont(ofSize: 30)
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        lblTitle.topAnchor.constraint(equalTo: uiView.topAnchor).isActive = true
        lblTitle.centerXAnchor.constraint(equalTo: uiView.centerXAnchor).isActive = true
        lblTitle.widthAnchor.constraint(equalTo: uiView.widthAnchor).isActive = true
        lblTitle.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
        
        uiView.addSubview(lblTitle1)
        lblTitle1.text = "Step 1"
        lblTitle1.textAlignment = .center
        lblTitle1.textColor = .white
        lblTitle1.font = UIFont.boldSystemFont(ofSize: 22)
        lblTitle1.translatesAutoresizingMaskIntoConstraints = false
        lblTitle1.topAnchor.constraint(equalTo: uiView.topAnchor, constant: titleHeight + gapHeight + titleGapHeight).isActive = true
        lblTitle1.centerXAnchor.constraint(equalTo: uiView.centerXAnchor).isActive = true
        lblTitle1.widthAnchor.constraint(equalTo: uiView.widthAnchor).isActive = true
        lblTitle1.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
        
        uiView.addSubview(lblTitle2)
        lblTitle2.text = "Step 2"
        lblTitle2.textColor = .white
        lblTitle2.textAlignment = .center
        lblTitle2.font = UIFont.boldSystemFont(ofSize: 22)
        lblTitle2.translatesAutoresizingMaskIntoConstraints = false
        lblTitle2.topAnchor.constraint(equalTo: uiView.topAnchor, constant: titleHeight*2 + gapHeight*2 + descHeight + titleGapHeight).isActive = true
        lblTitle2.centerXAnchor.constraint(equalTo: uiView.centerXAnchor).isActive = true
        lblTitle2.widthAnchor.constraint(equalTo: uiView.widthAnchor).isActive = true
        lblTitle2.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
        
        uiView.addSubview(lblTitle3)
        lblTitle3.text = "Step 3"
        lblTitle3.textColor = .white
        lblTitle3.textAlignment = .center
        lblTitle3.font = UIFont.boldSystemFont(ofSize: 22)
        lblTitle3.translatesAutoresizingMaskIntoConstraints = false
        lblTitle3.topAnchor.constraint(equalTo: uiView.topAnchor, constant: titleHeight*3 + gapHeight*3 + descHeight*2 + titleGapHeight).isActive = true
        lblTitle3.centerXAnchor.constraint(equalTo: uiView.centerXAnchor).isActive = true
        lblTitle3.widthAnchor.constraint(equalTo: uiView.widthAnchor).isActive = true
        lblTitle3.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
        
        
        uiView.addSubview(imgView1)
        imgView1.image = UIImage(named: "tabCreateEventCode")
        imgView1.backgroundColor = .clear
        imgView1.translatesAutoresizingMaskIntoConstraints = false
        imgView1.topAnchor.constraint(equalTo: uiView.topAnchor, constant: titleHeight*2 + gapHeight + (descHeight - imgHeight)*0.5 + titleGapHeight).isActive = true
        imgView1.leftAnchor.constraint(equalTo: uiView.leftAnchor).isActive = true
        imgView1.widthAnchor.constraint(equalToConstant: imgHeight).isActive = true
        imgView1.heightAnchor.constraint(equalToConstant: imgHeight).isActive = true
        
        uiView.addSubview(lblDesc1)
        lblDesc1.text = "Create an event and invite your friends."
        lblDesc1.textColor = .white
        lblDesc1.textAlignment = .left
        lblDesc1.numberOfLines = 5
        lblDesc1.lineBreakMode = .byWordWrapping
        lblDesc1.font = UIFont.systemFont(ofSize: 15)
        lblDesc1.translatesAutoresizingMaskIntoConstraints = false
        lblDesc1.topAnchor.constraint(equalTo: uiView.topAnchor, constant: titleHeight*2 + gapHeight + titleGapHeight).isActive = true
        lblDesc1.leftAnchor.constraint(equalTo: uiView.leftAnchor, constant: imgHeight + leftGap).isActive = true
        lblDesc1.rightAnchor.constraint(equalTo: uiView.rightAnchor).isActive = true
        lblDesc1.heightAnchor.constraint(equalToConstant: descHeight).isActive = true
        
        
        uiView.addSubview(imgView2)
        imgView2.image = UIImage(named: "Apple Calendar Icon")
        imgView2.backgroundColor = .clear
        imgView2.translatesAutoresizingMaskIntoConstraints = false
        imgView2.topAnchor.constraint(equalTo: uiView.topAnchor, constant: titleHeight*3 + gapHeight*2 + descHeight + (descHeight - imgHeight)*0.5 + titleGapHeight).isActive = true
        imgView2.leftAnchor.constraint(equalTo: uiView.leftAnchor).isActive = true
        imgView2.widthAnchor.constraint(equalToConstant: imgHeight).isActive = true
        imgView2.heightAnchor.constraint(equalToConstant: imgHeight).isActive = true
        
        uiView.addSubview(lblDesc2)
        lblDesc2.text = "With clever calendar integrations, Planr gathers everyone’s availability automatically."
        lblDesc2.textColor = .white
        lblDesc2.textAlignment = .left
        lblDesc2.numberOfLines = 5
        lblDesc2.lineBreakMode = .byWordWrapping
        lblDesc2.font = UIFont.systemFont(ofSize: 15)
        lblDesc2.translatesAutoresizingMaskIntoConstraints = false
        lblDesc2.topAnchor.constraint(equalTo: uiView.topAnchor, constant: titleHeight*3 + gapHeight*2 + descHeight + titleGapHeight).isActive = true
        lblDesc2.leftAnchor.constraint(equalTo: uiView.leftAnchor, constant: imgHeight + leftGap).isActive = true
        lblDesc2.rightAnchor.constraint(equalTo: uiView.rightAnchor).isActive = true
        lblDesc2.heightAnchor.constraint(equalToConstant: descHeight).isActive = true
        
        
        uiView.addSubview(imgView3)
        imgView3.image = UIImage(named: "Host To Pick Date")
        imgView3.backgroundColor = .clear
        imgView3.translatesAutoresizingMaskIntoConstraints = false
        imgView3.topAnchor.constraint(equalTo: uiView.topAnchor, constant: titleHeight*4 + gapHeight*3 + descHeight*2 + (descHeight - imgHeight)*0.5 + titleGapHeight).isActive = true
        imgView3.leftAnchor.constraint(equalTo: uiView.leftAnchor).isActive = true
        imgView3.widthAnchor.constraint(equalToConstant: imgHeight).isActive = true
        imgView3.heightAnchor.constraint(equalToConstant: imgHeight).isActive = true
        
        uiView.addSubview(lblDesc3)
        lblDesc3.text = "You choose from the available dates. Simple!"
        lblDesc3.textColor = .white
        lblDesc3.textAlignment = .left
        lblDesc3.numberOfLines = 5
        lblDesc3.lineBreakMode = .byWordWrapping
        lblDesc3.font = UIFont.systemFont(ofSize: 15)
        lblDesc3.translatesAutoresizingMaskIntoConstraints = false
        lblDesc3.topAnchor.constraint(equalTo: uiView.topAnchor, constant: titleHeight*4 + gapHeight*3 + descHeight*2 + titleGapHeight).isActive = true
        lblDesc3.leftAnchor.constraint(equalTo: uiView.leftAnchor, constant: imgHeight + leftGap).isActive = true
        lblDesc3.rightAnchor.constraint(equalTo: uiView.rightAnchor).isActive = true
        lblDesc3.heightAnchor.constraint(equalToConstant: descHeight).isActive = true
        
        
    }
    
    
    
    



}
