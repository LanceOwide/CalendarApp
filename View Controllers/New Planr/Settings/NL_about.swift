//
//  NL_about.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/27/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class NL_about: UIViewController {
    
    
    //    get the top distance of the page
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
    
    let scrollView: UIScrollView = {
            let v = UIScrollView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = .white
            return v
        }()
    
    let uiView: UIView = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = .white
            return v
        }()
    
    let labelDescription: UITextView = {
            let label = UITextView()
        let text = "We built Planr to connect us to our favourite people. We were frustrated with the iMessage tag and 1,000s of WhatsApp chats it took to organize a simple dinner with our friends, so we set about to fix it.\n\n Why couldn’t we create an app that connected our calendars to those of our friends in the same way we were used to at work? No reason!\n\nSo we built an app that links directly into everyones calendar and added clever auto respond features so that in most cases(when the app is running the in background), our friends would respond to our request automatically within seconds.\n\nThe final app was far too good to keep to ourselves, so we decided to share it.\n\nWe hope you enjoy it. If you have any feedback, please send us an email at support@planr.me\n\nHappy Planning,\n\nThe Planr Team"
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .gray
        label.isScrollEnabled = false
        label.textContainer.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

  
        view.addSubview(inputTopView)
        
        title = "About"
                        
        // Set its constraint to display it on screen
        inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: topDistance).isActive = true
        inputTopView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputTopView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        view.addSubview(scrollView)
        //        setup view for collectionView
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: topDistance + 80).isActive = true
        
        
        view.addSubview(uiView)
        uiView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        uiView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        uiView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        uiView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        
        uiView.addSubview(labelDescription)
        labelDescription.leadingAnchor.constraint(equalTo: uiView.leadingAnchor,constant: 16).isActive = true
        labelDescription.trailingAnchor.constraint(equalTo: uiView.trailingAnchor, constant: -16).isActive = true
        labelDescription.bottomAnchor.constraint(equalTo: uiView.bottomAnchor).isActive = true
        labelDescription.topAnchor.constraint(equalTo: uiView.topAnchor).isActive = true

    }
    
    //    create the progress bar and title
        lazy var inputTopView: UIView = {
            print("setting up the inputTopView")
    //        set the variables for the setup
            let headerLabelText = "About Planr"
            let instructionLabelText = "For information, please email contact@planr.me"
            let sideInset = 16
         
            //   setup the view for holding the progress bar and title
            let containerView = UIView()
            containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
            containerView.backgroundColor = UIColor.white
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
    //        trying to add a top view
            let topView = UIView()
            topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
            topView.backgroundColor = UIColor.white
            topView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(topView)
            topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            topView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            
            //        setup the item label
            let calendarImage = UIImageView()
            calendarImage.image = UIImage(named: "SettingsCog")
            calendarImage.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(calendarImage)
            calendarImage.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 16).isActive = true
            calendarImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
            calendarImage.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
            calendarImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            //        setup the item label
            let headerLabel = UILabel()
            headerLabel.text = headerLabelText
            headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(headerLabel)
            headerLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset + 30)).isActive = true
            headerLabel.widthAnchor.constraint(equalToConstant: screenWidth - 30 - CGFloat(sideInset)).isActive = true
            headerLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
            headerLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
    //        set the instruction
            let instructionLabel = UILabel()
            instructionLabel.text = instructionLabelText
            instructionLabel.font = UIFont.systemFont(ofSize: 14)
            instructionLabel.textColor = MyVariables.colourLight
            instructionLabel.numberOfLines = 2
            instructionLabel.lineBreakMode = .byWordWrapping
            instructionLabel.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(instructionLabel)
            instructionLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset + 30)).isActive = true
            instructionLabel.widthAnchor.constraint(equalToConstant: screenWidth - 30 - CGFloat(sideInset)).isActive = true
            instructionLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40).isActive = true
            instructionLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            return containerView
        }()
    
    
    //    create the progress bar and title
//        lazy var inputBottomView: UIScrollView = {
//
//            let sideInset = CGFloat(16)
//            let font = UIFont.systemFont(ofSize: 11)
//            let attributes = [NSAttributedString.Key.font: font]
//            let attributedQuote = NSMutableAttributedString(string: "We built Planr to connect us to our favourite people.We were frustrated with the iMessage tag and 1,000s of WhatsApp chats it took to organize a simple dinner with our friends, so we set about to fix it. Why couldn’t we create an app that connected our calendars to those of our friends in the same way we were used to at work? No reason!\n\nSo we built an app that links directly into everyones calendar and added clever auto respond features so that in most cases(when the app is running the in background), our friends would respond to our request automatically within seconds.\n\nThe final app was far too good to keep to ourselves, so we decided to share it. We hope you enjoy it.\n\nThe Planr Team", attributes: attributes)
//
//
//            //   setup the view for holding the assets
//            let containerView2 = UIScrollView()
////            containerView2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1000)
//
////            let topView = UIView()
////            topView.backgroundColor = UIColor.white
////            topView.translatesAutoresizingMaskIntoConstraints = false
////            containerView2.addSubview(topView)
////            topView.leftAnchor.constraint(equalTo: containerView2.leftAnchor).isActive = true
////            topView.topAnchor.constraint(equalTo: containerView2.topAnchor).isActive = true
////            topView.widthAnchor.constraint(equalTo: containerView2.widthAnchor).isActive = true
////            topView.bottomAnchor.constraint(equalTo: containerView2.bottomAnchor).isActive = true
//
//
//            let headerLabel = UILabel()
//            headerLabel.attributedText = attributedQuote
//            headerLabel.numberOfLines = 20
//            headerLabel.textAlignment = .left
//            headerLabel.font = UIFont.systemFont(ofSize: 15)
//            headerLabel.translatesAutoresizingMaskIntoConstraints = false
//            containerView2.addSubview(headerLabel)
//            headerLabel.leftAnchor.constraint(equalTo: containerView2.leftAnchor, constant: CGFloat(sideInset)).isActive = true
//            headerLabel.rightAnchor.constraint(equalTo: containerView2.rightAnchor,constant: -sideInset).isActive = true
//            headerLabel.topAnchor.constraint(equalTo: containerView2.topAnchor, constant: 20).isActive = true
//            headerLabel.heightAnchor.constraint(equalToConstant: 1000).isActive = true
//
//
//         return containerView2
//        }()
    
}
