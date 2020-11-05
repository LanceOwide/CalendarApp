//
//  NL_tabHelper.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/26/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class NL_tabHelper: UIView {
    
    
//    setup the content view to hold the rest
    let contentView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 49))
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    //    setup the image for each event type
    let imageView1: UIButton = {
        let imageView = UIButton()
        imageView.setImage(UIImage(named: "tabHomeCode"), for: .normal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //    setup the image for each event type
    let imageView2: UIButton = {
        let imageView = UIButton()
        imageView.setImage(UIImage(named: "chatCodeSmall"), for: .normal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //    setup the image for each event type
    let imageView3: UIButton = {
        let imageView = UIButton()
        imageView.setImage(UIImage(named: "tabCreateEventCode"), for: .normal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //    setup the image for each event type
    let imageView4: UIButton = {
        let imageView = UIButton()
        imageView.setImage(UIImage(named: "tabNotificationCodeSmall"), for: .normal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //    setup the image for each event type
    let imageView5: UIButton = {
        let imageView = UIButton()
        imageView.setImage(UIImage(named: "tabEventsCodeSmall3"), for: .normal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let label1: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 8)
        lbl.text = "Home"
        lbl.textColor = MyVariables.colourLight
       return lbl
    }()
    
    let label2: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 8)
        lbl.text = "Chat"
        lbl.textColor = MyVariables.colourLight
       return lbl
    }()
    
    let label3: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 8)
        lbl.text = "Create"
        lbl.textColor = MyVariables.colourLight
       return lbl
    }()
    
    let label4: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 8)
        lbl.text = "Notifications"
        lbl.textColor = MyVariables.colourLight
       return lbl
    }()
    
    let label5: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 8)
        lbl.text = "Events"
        lbl.textColor = MyVariables.colourLight
       return lbl
    }()
    
    let lblchatNotification: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 8)
        lbl.backgroundColor = MyVariables.notificationOrange
        lbl.textColor = MyVariables.colourLight
       return lbl
    }()
    
    let lblNotification: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 8)
        lbl.backgroundColor = MyVariables.notificationOrange
        lbl.textColor = MyVariables.colourLight
       return lbl
    }()
    
    

    
    //    setup the views
    override init(frame: CGRect) {
      super.init(frame: frame)
        
        self.addSubview(contentView)
//        add the content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
//       add the subViews
        contentView.addSubview(imageView1)
        contentView.addSubview(imageView2)
        contentView.addSubview(imageView3)
        contentView.addSubview(imageView4)
        contentView.addSubview(imageView5)
        
        contentView.addSubview(label1)
        contentView.addSubview(label2)
//        contentView.addSubview(label3)
        contentView.addSubview(label4)
        contentView.addSubview(label5)
        
        contentView.addSubview(lblNotification)
        contentView.addSubview(lblchatNotification)
        
        

        let butonSize = CGFloat(35)
        let remainingScreen = (screenWidth - butonSize*5)
        let gap = remainingScreen / 4
        let lblHeight = CGFloat(15)
        let lblWidth = butonSize + 25
        let buttonGap = CGFloat(5)
        let separatorHeight = CGFloat(1)
        let buttonSeparator = CGFloat(3)
        let notificationSize = CGFloat(10)
        
        
        imageView1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -butonSize - gap*2).isActive = true
        imageView1.heightAnchor.constraint(equalToConstant: butonSize).isActive = true
        imageView1.widthAnchor.constraint(equalToConstant: butonSize).isActive = true
        imageView1.topAnchor.constraint(equalTo: contentView.topAnchor,constant: buttonSeparator).isActive = true
        imageView1.translatesAutoresizingMaskIntoConstraints = false
        
        label1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -butonSize - gap*2).isActive = true
        label1.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
        label1.widthAnchor.constraint(equalToConstant: lblWidth).isActive = true
        label1.topAnchor.constraint(equalTo: contentView.topAnchor, constant: butonSize + buttonGap).isActive = true
 
        
        imageView2.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -butonSize/2 - gap).isActive = true
        imageView2.heightAnchor.constraint(equalToConstant: butonSize).isActive = true
        imageView2.widthAnchor.constraint(equalToConstant: butonSize).isActive = true
        imageView2.topAnchor.constraint(equalTo: contentView.topAnchor,constant: buttonSeparator).isActive = true
        imageView2.translatesAutoresizingMaskIntoConstraints = false
        
        label2.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -butonSize/2 - gap).isActive = true
        label2.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
        label2.widthAnchor.constraint(equalToConstant: lblWidth).isActive = true
        label2.topAnchor.constraint(equalTo: contentView.topAnchor, constant: butonSize + buttonGap).isActive = true
        label2.translatesAutoresizingMaskIntoConstraints = false
        
//        add the chat notifications
        lblchatNotification.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -gap).isActive = true
        lblchatNotification.heightAnchor.constraint(equalToConstant: notificationSize).isActive = true
        lblchatNotification.widthAnchor.constraint(equalToConstant: notificationSize).isActive = true
        lblchatNotification.topAnchor.constraint(equalTo: contentView.topAnchor,constant: buttonSeparator*2).isActive = true
        lblchatNotification.translatesAutoresizingMaskIntoConstraints = false
        lblchatNotification.layer.borderWidth = 1.0
        lblchatNotification.layer.masksToBounds = true
        lblchatNotification.layer.cornerRadius = CGFloat(notificationSize) / 2
        lblchatNotification.layer.borderColor = UIColor.white.cgColor
        lblchatNotification.isHidden = true
    
        
        imageView3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView3.heightAnchor.constraint(equalToConstant: butonSize + 5).isActive = true
        imageView3.widthAnchor.constraint(equalToConstant: butonSize + 5).isActive = true
        imageView3.topAnchor.constraint(equalTo: contentView.topAnchor,constant: buttonSeparator).isActive = true
        imageView3.translatesAutoresizingMaskIntoConstraints = false
    

        
        imageView4.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: butonSize/2 + gap).isActive = true
        imageView4.heightAnchor.constraint(equalToConstant: butonSize).isActive = true
        imageView4.widthAnchor.constraint(equalToConstant: butonSize).isActive = true
        imageView4.topAnchor.constraint(equalTo: contentView.topAnchor,constant: buttonSeparator).isActive = true
        imageView4.translatesAutoresizingMaskIntoConstraints = false
        
        label4.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: butonSize/2 + gap).isActive = true
        label4.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
        label4.widthAnchor.constraint(equalToConstant: lblWidth).isActive = true
        label4.topAnchor.constraint(equalTo: contentView.topAnchor, constant: butonSize + buttonGap).isActive = true
        label4.translatesAutoresizingMaskIntoConstraints = false
        
        
//        add the chat notifications
        lblNotification.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: gap + butonSize).isActive = true
        lblNotification.heightAnchor.constraint(equalToConstant: notificationSize).isActive = true
        lblNotification.widthAnchor.constraint(equalToConstant: notificationSize).isActive = true
        lblNotification.topAnchor.constraint(equalTo: contentView.topAnchor,constant: buttonSeparator*2).isActive = true
        lblNotification.translatesAutoresizingMaskIntoConstraints = false
        lblNotification.layer.borderWidth = 1.0
        lblNotification.layer.masksToBounds = true
        lblNotification.layer.cornerRadius = CGFloat(notificationSize) / 2
        lblNotification.layer.borderColor = UIColor.white.cgColor
      
        
        imageView5.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: butonSize + gap*2).isActive = true
        imageView5.heightAnchor.constraint(equalToConstant: butonSize).isActive = true
        imageView5.widthAnchor.constraint(equalToConstant: butonSize).isActive = true
        imageView5.topAnchor.constraint(equalTo: contentView.topAnchor,constant: buttonSeparator).isActive = true
        imageView5.translatesAutoresizingMaskIntoConstraints = false
        
        label5.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: butonSize + gap*2).isActive = true
        label5.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
        label5.widthAnchor.constraint(equalToConstant: lblWidth).isActive = true
        label5.topAnchor.constraint(equalTo: contentView.topAnchor, constant: butonSize + buttonGap).isActive = true
        label5.translatesAutoresizingMaskIntoConstraints = false
        
        
        //        create a separator line
        let separatorLine5 = UIView()
        separatorLine5.backgroundColor = MyVariables.colourPlanrGreen
        separatorLine5.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorLine5)
        separatorLine5.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        separatorLine5.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        separatorLine5.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        
        
        // we determine whether there are notifications based on the ID list

        if chatNotificationiDs == nil{
            lblchatNotification.isHidden = true
        }
        else{
//            loop through the list of eventIDs and check if there are any that arent ""
        for chat in chatNotificationiDs{
            if chat != ""{
//                    if there is an ID we set the notification to visible
            lblchatNotification.isHidden = false
                }
            }
        }
        // we determine whether there are event notifications based on the ID list
        if eventNotificationiDs == nil{
            lblchatNotification.isHidden = true
        }
        else{
//            loop through the list of eventIDs and check if there are any that arent ""
        for chat in chatNotificationiDs{
            if chat != ""{
//                    if there is an ID we set the notification to visible
            lblchatNotification.isHidden = false
                }
            }
        }
        
        // Access Shared Defaults Object
        let userDefaults = UserDefaults.standard
        
//        get anything currently stored in user defaults
        let currentAPNUI = userDefaults.object(forKey: "apnNotificationUserInfo") as? [[AnyHashable : Any]]
        if currentAPNUI == nil{
          print("there were no notifications")
            lblNotification.isHidden = true
        }
        else{
            if currentAPNUI?.count == 0{
                lblNotification.isHidden = true
            }
            else if currentAPNUI?.count == 1{
//                if the only notificaiton is the auth we dont want to show the notification
                let thisNotification = currentAPNUI![0]
                if let authMessage = thisNotification["com.google.firebase.auth"] as? NSDictionary{
                    lblNotification.isHidden = true
                }
                else{
                    lblNotification.isHidden = false
                }
            }
            else{
                lblNotification.isHidden = false

            }
        }
        
//        we add a notification to trigger when there are new notificaitons we should take note of
    NotificationCenter.default.addObserver(self, selector: #selector(chatNotificationUpate), name: .notificationsReloaded, object: nil)
        

//    we add a notification to trigger an update of the orange notification symbols when the user selects the notification
    NotificationCenter.default.addObserver(self, selector: #selector(notificationObserverTriggered), name: .notificationTapped, object: nil)
    }
    
    @objc func chatNotificationUpate(){
// we determine whether there arr notifications based on the ID list
        
        print("tab helper chatNotificationUpate triggered chatNotificationiDs \(chatNotificationiDs)")
        
        if chatNotificationiDs == nil{
            print("tab helper chatNotificationUpate chatNotificationIDsDefaults = nil")
            lblchatNotification.isHidden = true
        }
        else{
//            loop through the list of eventIDs and check if there are any that arent ""
            for chat in chatNotificationiDs{
                if chat != ""{
                    print("tab helper chatNotificationUpate chatNotificationIDsDefaults != nil and chat != empty ")
//                    if there is an ID we set the notification to visible
                    lblchatNotification.isHidden = false
                }
            }
        }
    }
    
    @objc func notificationObserverTriggered(_ notification : Notification){
    
        // Access Shared Defaults Object
        let userDefaults = UserDefaults.standard
        
        //        get anything currently stored in user defaults
        let currentAPNUI = userDefaults.object(forKey: "apnNotificationUserInfo") as? [[AnyHashable : Any]]
                
        if currentAPNUI == nil{
            print("there were no notifications")
            lblNotification.isHidden = true
            }
            else{
            if currentAPNUI?.count == 0{
            lblNotification.isHidden = true
            }
        else{
            lblNotification.isHidden = false}
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
