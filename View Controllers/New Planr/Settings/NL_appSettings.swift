//
//  NL_appSettings.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/27/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class NL_appSettings: UIViewController {
    
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
    
    
    let bannerSwitch = UISwitch()
    let badgedSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        MUST ADD subview
        view.addSubview(inputTopView)
        view.addSubview(inputBottomView)

                        
        // Set its constraint to display it on screen
        inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: topDistance).isActive = true
        inputTopView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputTopView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        //        setup view for collectionView
        inputBottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputBottomView.heightAnchor.constraint(equalToConstant: screenHeight - topDistance - 80).isActive = true
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = MyVariables.colourPlanrGreen
        navigationItem.backBarButtonItem = backItem
        
        
        //        add save button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem?.tintColor = MyVariables.colourPlanrGreen
  
    }
    
    //    create the progress bar and title
        lazy var inputTopView: UIView = {
            print("setting up the inputTopView")
    //        set the variables for the setup
            let headerLabelText = "Application Settings"
            let instructionLabelText = "Settings for your Planr App"
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
    
    lazy var inputBottomView: UIView = {
        
        let textBoxHeight = 50
        let sideInset = CGFloat(16)
        let sideInsetIcon = 24
        let separatorHeight = 1
        let iconSize = textBoxHeight/3
        let spacer = CGFloat(10)
        let lblHeight = CGFloat(20)
        let switchHeight = CGFloat(51)
        
        
        //   setup the view for holding the assets
        let containerView2 = UIView()
        containerView2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight - topDistance - 100)
        containerView2.backgroundColor = UIColor.white
        containerView2.translatesAutoresizingMaskIntoConstraints = false
        
        
        //        trying to add a top view that represents the remainder of the screen
         let topView = UIView()
         topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight - topDistance - 100)
         topView.backgroundColor = UIColor.white
         topView.translatesAutoresizingMaskIntoConstraints = false
         containerView2.addSubview(topView)
         topView.leftAnchor.constraint(equalTo: containerView2.leftAnchor).isActive = true
         topView.topAnchor.constraint(equalTo: containerView2.topAnchor).isActive = true
         topView.widthAnchor.constraint(equalTo: containerView2.widthAnchor).isActive = true
         topView.heightAnchor.constraint(equalToConstant: screenHeight - topDistance - 100).isActive = true
        
        //        create a separator line
        let separatorLine = UIView()
        separatorLine.backgroundColor = MyVariables.colourPlanrGreen
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLine)
        separatorLine.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
        separatorLine.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        
        
        //        setup the item label
        let lblAPN = UILabel()
        lblAPN.text = "Enable Push Notifications"
        lblAPN.font = UIFont.boldSystemFont(ofSize: 15)
        lblAPN.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(lblAPN)
        lblAPN.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
        lblAPN.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
        lblAPN.topAnchor.constraint(equalTo: topView.topAnchor, constant: spacer).isActive = true
        lblAPN.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
        
        
        topView.addSubview(bannerSwitch)
        bannerSwitch.onTintColor = MyVariables.colourPlanrGreen
        /*For off state*/
        bannerSwitch.tintColor = MyVariables.colourLight
        bannerSwitch.layer.cornerRadius = bannerSwitch.frame.height / 2.0
        bannerSwitch.backgroundColor = MyVariables.colourLight
        bannerSwitch.clipsToBounds = true
//        set the current status of the toggle
        bannerSwitch.setOn(pendingState, animated: false)
//        add the target to reset once changes
        bannerSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        bannerSwitch.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
        bannerSwitch.topAnchor.constraint(equalTo: topView.topAnchor, constant: spacer*2 + lblHeight).isActive = true
        bannerSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        
        //        setup the item label
        let lblBanners = UILabel()
        lblBanners.text = "Banner notifications"
        lblBanners.font = UIFont.systemFont(ofSize: 15)
        lblBanners.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(lblBanners)
        lblBanners.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset + switchHeight + spacer).isActive = true
        lblBanners.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -sideInset).isActive = true
        lblBanners.topAnchor.constraint(equalTo: topView.topAnchor, constant: spacer*2 + lblHeight).isActive = true
        lblBanners.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
        
        topView.addSubview(badgedSwitch)
        badgedSwitch.onTintColor = MyVariables.colourPlanrGreen
        /*For off state*/
        badgedSwitch.tintColor = MyVariables.colourLight
        badgedSwitch.layer.cornerRadius = bannerSwitch.frame.height / 2.0
        badgedSwitch.backgroundColor = MyVariables.colourLight
        badgedSwitch.clipsToBounds = true
//        set the current status of the toggle
        badgedSwitch.setOn(pendingState, animated: false)
//        add the target to reset once changes
        badgedSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        badgedSwitch.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
        badgedSwitch.topAnchor.constraint(equalTo: topView.topAnchor, constant: spacer*3 + lblHeight + switchHeight).isActive = true
        badgedSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        //        setup the item label
        let lblBadge = UILabel()
        lblBadge.text = "Badge notifications"
        lblBadge.font = UIFont.systemFont(ofSize: 15)
        lblBadge.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(lblBadge)
        lblBadge.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset + switchHeight + spacer).isActive = true
        lblBadge.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -sideInset).isActive = true
        lblBadge.topAnchor.constraint(equalTo: topView.topAnchor, constant: spacer*3 + lblHeight + switchHeight).isActive = true
        lblBadge.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
        
        return containerView2
    }()
    
    
// save the new settings
    @objc func saveTapped(){
        
        //        one the user pushes close we register for push notifications
        AutoRespondHelper.registerForPushNotificationsAuto()
        
    }


    
    
    //    check to see if the user changed thier notification choice
        @objc func stateChanged() {
            if bannerSwitch.isOn{
                UserDefaults.standard.set(true, forKey: "notificationBanners")
                print("notificationBanners - true")
            }
            else{
                UserDefaults.standard.set(false, forKey: "notificationBanners")
                print("notificationBanners - false")
            }
            if badgedSwitch.isOn{
              UserDefaults.standard.set(true, forKey: "notificationBadge")
                print("notificationBadge - true")
            }
            else{
                UserDefaults.standard.set(false, forKey: "notificationBadge")
                print("notificationBadge - false")
            }
        }


}
