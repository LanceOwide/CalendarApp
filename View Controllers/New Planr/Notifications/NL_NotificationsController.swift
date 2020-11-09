//
//  NL_NotificationsController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/26/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

var currentNotifications = [[String: String]]()

class NL_NotificationsController: UIViewController {

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
  
//    add the tabBar
    var tabView: NL_tabHelper = NL_tabHelper(frame: CGRect(x:0, y:0, width: screenWidth, height: 80))
    var topView = UIView()
    var collectionViewEvents: UICollectionView!
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        we add an observer to reload the notifications once the user taps it
        NotificationCenter.default.addObserver(self, selector: #selector(notificationObserverTriggered), name: .notificationTapped, object: nil)
        
        
//        setup the navigation bar
        setupTheNavigationbar()
        
        getNotifications(rerun: false){
            
        }

//        add the tabBar
                view.addSubview(tabView)
                view.addSubview(inputTopView)
                
// Set its constraint to display it on screen
                 inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                 inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: topDistance).isActive = true
                 inputTopView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                 inputTopView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
                inputTopView.translatesAutoresizingMaskIntoConstraints = false
                
// Set the tab bar to be shown
                tabView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                tabView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                tabView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                tabView.heightAnchor.constraint(equalToConstant: 80).isActive = true
                tabView.translatesAutoresizingMaskIntoConstraints = false
        tabView.imageView1.addTarget(self, action: #selector(openTabClicked1), for: .touchUpInside)
        tabView.imageView2.addTarget(self, action: #selector(openTabClicked2), for: .touchUpInside)
        tabView.imageView3.addTarget(self, action: #selector(openTabClicked3), for: .touchUpInside)
        tabView.imageView5.addTarget(self, action: #selector(openTabClicked5), for: .touchUpInside)
        tabView.imageView4.addTarget(self, action: #selector(openTabClicked4), for: .touchUpInside)
        
        
//        set the border for the page we are on
                tabView.imageView4.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
                tabView.imageView4.layer.borderWidth = 0
                tabView.imageView4.backgroundColor = MyVariables.colourSelected
                tabView.imageView4.layer.cornerRadius = 5
                tabView.label4.textColor = MyVariables.colourPlanrGreen
        tabView.imageView4.layer.borderWidth = 1
        tabView.imageView4.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
    }
    
    
    func setupTheNavigationbar(){
        
        title = "Planr"
        let textAttributes = [NSAttributedString.Key.foregroundColor:MyVariables.colourPlanrGreen, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 30)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes

//        setup the navigator bar items, in order to do this with a custom size we use the method of creating a frame
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        menuBtn.setImage(UIImage(named:"settingsCogCodeLight"), for: .normal)
        menuBtn.addTarget(self, action: #selector(settingsPage), for: UIControl.Event.touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = MyVariables.colourPlanrGreen
        navigationItem.backBarButtonItem = backItem
  
    }
    
    //function to show the settings page
        @objc func settingsPage(){
    //        push the settings page
            if let viewController = UIStoryboard(name: "NL_Settings", bundle: nil).instantiateViewController(withIdentifier: "settingsHome") as? NL_SettingsPage {
               self.navigationController?.pushViewController(viewController, animated: true)
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.navigationController?.navigationItem.setHidesBackButton(false, animated: false)
            }
        }

    
    
    //    create the progress bar and title
        lazy var inputTopView: UIView = {
            print("setting up the inputTopView")
    //        set the variables for the setup
            let sideInset = CGFloat(16)
            let monthViewHeight = CGFloat(35)
            let DOTWHeight = CGFloat(35)
            let spacerHeight = CGFloat(10)
            let separatorHeight = CGFloat(1)

         
            //   setup the view for holding the progress bar and title
            let containerView = UIView()
            containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight)
            containerView.backgroundColor = UIColor.white
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
    //        trying to add a top view
            topView.backgroundColor = UIColor.white
            topView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(topView)
            topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            topView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            
            
//            create three headers for the classifications of events
            let btnHeight = CGFloat(50)
            let btnWidth = CGFloat(screenWidth/3)
            
            
            //            add the collection view for the events
                        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                        layout.scrollDirection = .vertical
                        //        layout3.sectionHeadersPinToVisibleBounds = true
                        collectionViewEvents = UICollectionView(frame: .zero, collectionViewLayout: layout)
                        collectionViewEvents?.translatesAutoresizingMaskIntoConstraints = false
                        collectionViewEvents?.delegate = self
                        collectionViewEvents?.dataSource = self
                        collectionViewEvents?.backgroundColor = .white
                        collectionViewEvents?.register(NL_chatLogCell.self, forCellWithReuseIdentifier: cellId)
                        
                        collectionViewEvents?.isScrollEnabled = true
                        collectionViewEvents?.isUserInteractionEnabled = true
                        collectionViewEvents?.allowsSelection = true
                        collectionViewEvents?.allowsMultipleSelection = false
                        topView.addSubview(collectionViewEvents!)
                        collectionViewEvents?.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
                        collectionViewEvents?.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth - sideInset - sideInset)).isActive = true
                        collectionViewEvents?.topAnchor.constraint(equalTo: topView.topAnchor, constant: 5).isActive = true
                        collectionViewEvents?.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
            
            return containerView
    }()
    
    
//    function to run when the user selects a notificaiton, this ensures the table is realoded and the tapped notification removed
    
    @objc  func notificationObserverTriggered() {
        print("notificationObserverTriggered")
//            re-run the notifications creation
                getNotifications(rerun: true){
                    self.collectionViewEvents.reloadData()
                        print("didSelect - get notifications complete")
        }
        
    }
    
//    we need to remove the observers everytime we change views, so that we dont recreata them
        override func viewWillDisappear(_ animated: Bool) {
            NotificationCenter.default.removeObserver(self, name: .notificationsReloaded, object: nil)
        }
    

    
    func getNotifications(rerun: Bool, completion: @escaping () -> Void){
        print("running func getNotifications rerun: \(rerun)")
        
        // Access Shared Defaults Object
        let userDefaults = UserDefaults.standard
        
//        get anything currently stored in user defaults
        let currentAPNUI = userDefaults.object(forKey: "apnNotificationUserInfo") as? [[AnyHashable : Any]]
        print("getNotifications - currentAPNUI \(currentAPNUI)")
        
//        since currentAPNUI is optional it will never return nil, however we keep this as a safety check
        if currentAPNUI == nil || currentAPNUI!.count == 0{
          print("there were no notifications")
            completion()
        }
        else{
//        we decode the notifications and add them to an array for use in the collectionView, loop through all notifications and decode them we also add each notification to aan array that we can save back down in user defaults
        var newAPUNI = [[AnyHashable : Any]]()
        for notification in currentAPNUI!{
//            we need to check if there is a notification related to the authentication of the app, this should be deleted and then we continue
            
            if let authMessage = notification["com.google.firebase.auth"] as? NSDictionary{
                print("authMessage \(authMessage)")
            }
            else{
            print("notification \(notification)")
            let eventID = notification["gcm.notification.eventID"] as? String
            let eventType = notification["gcm.notification.eventType"] as? String
            let aps = notification["aps"] as? NSDictionary
            
//                if there is no body to the alert the alert isnt useful, so we ignore it
            if let alert = aps!["alert"] as? NSDictionary, let body = alert[AnyHashable("body")] as? String, let category = aps!["category"] as? String{

            let title = alert["title"] as? String
//            set the notificaiton items equal to an array then append the array to the current notifications
            var currentNotification = [String: String]()
            currentNotification["eventID"] = eventID
            currentNotification["eventType"] = eventType
            currentNotification["category"] = category
            currentNotification["body"] = body
            currentNotification["title"] = title
            
//            we need to check if the notification list already contains this notification, if it does we do not add it
            if currentNotifications.contains(currentNotification){
//                we do nothing
            }else{
//            we add the notification
                currentNotifications.append(currentNotification)
//                we append the notificaton into the new set
                    newAPUNI.append(notification)
            }
        }
        else{
//             ignore an alert that doesnt have a body to it
            }
        print("currentNotifications \(currentNotifications)")
        }
//         we save down the new set of notifications as the user default. If this is the second time we are loading the notifications, we do not want to re do this, since the newAPUNI will be empty
            if rerun == false{
            print("newAPUNI \(newAPUNI)")
            userDefaults.setValue(newAPUNI, forKey: "apnNotificationUserInfo")
            print("getNotifications completion - rerun = false")
            completion()
            }
            print("getNotifications completion - rerun = true")
            completion()
        }
    }
    }
}

extension NL_NotificationsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = Int()
        
        numberOfItems = currentNotifications.count
        
//        if there are no notifications we set a message
        if numberOfItems == 0{
            collectionView.setEmptyMessage(message: "You have no new notifications", messageAlignment: .center)
        }
        else{
//            we restore if there are notificaitons to show
            collectionView.restore()
        }
        
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NL_chatLogCell
        
//        types of notificatons - we should update this to include all notifications
//        1.You have been invited to an event
//        2.An event was amended
        
        let notification = currentNotifications[indexPath.row]
        let title = notification["title"]
        let body = notification["body"]
        
        var titleText = String()
        
//        we recast the titles into string we want to present
        
        if title == "You have been invited to an event!."{
            titleText = "New Event Invite"
        }
        else if title == "An event was amended!."{
            titleText = "Event Amended"
        }
        
//        set the cell title
        cell.lbleventTitle.text = titleText
        cell.lbleventTitle.font =  UIFont.boldSystemFont(ofSize: 13)
        
        
        var bodyText = String()
        
//        set the cell body - we want to extarct the message that was sent to the user, in order to do this we search for the full stop and use all the text before the full stop
        if let index = body!.index(of: ".") {
            bodyText = String(body![..<index])   //
            print(bodyText)
        }
        
        cell.lbleventTitle.text = bodyText
        cell.lbleventTitle.numberOfLines = 2
        cell.lbleventTitle.lineBreakMode = .byWordWrapping
        
        cell.lbleventLocation.text = ""
        
//        cell.lbleventLocation.font =  UIFont.systemFont(ofSize: 13)
////        we want the text to wrap incase the body is too long
//        cell.lbleventLocation.lineBreakMode = .byWordWrapping
//        cell.lbleventLocation.numberOfLines = 2

        
//        set the picture of of the notifications
        cell.eventImage.image = UIImage(named: "tabNotificationCode")
        
        
      return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        when the user selects an event we want to take them to it
        
//        1. get the eventID they have a notification for
        let selectedEvent = currentNotifications[indexPath.row]
        let eventID = selectedEvent["eventID"]
        
//        load the event itself
        let predicate = NSPredicate(format: "eventID = %@", eventID!)
        let predicateReturned = self.serialiseEvents(predicate: predicate, usePredicate: true)
        if predicateReturned.count == 0{
            print("something went wrong")
            
//           DEV: we should check the DB for this
            let utils = Utils()
            let button1 = AlertButton(title: "Ok", action: {
                    print("OK clicked")
                currentNotifications.remove(at: indexPath.row)
                //            2.0 pull the data from defaults
                            let userDefaults = UserDefaults.standard
                            var currentAPNUI = userDefaults.object(forKey: "apnNotificationUserInfo") as? [[AnyHashable : Any]]
                //            2.1 delete at index
                            currentAPNUI?.remove(at: indexPath.row)
                //            2.2 push the new list back to the defaults
                            userDefaults.setValue(currentAPNUI, forKey: "apnNotificationUserInfo")
                collectionView.reloadData()
                }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
            
            let alertPayload = AlertPayload(title: "Something went wrong!", titleColor: UIColor.red, message: "The organiser may have deleted the event", messageColor: MyVariables.colourPlanrGreen, buttons: [button1], backgroundColor: UIColor.clear, inputTextHidden: true)
            
            utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true)
            
        }
        else{
        currentUserSelectedEvent = predicateReturned[0]
                    
        //            set the availability for the event
        currentUserSelectedAvailability = serialiseAvailability(eventID: eventID!)
        prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
            
//            delete the notification from the list and save down the notifications to the userdefaults
//            the index of the collectionView and the list of notifications are equal so we can simply delete them directly
            
//            1. delete from the currentNotification
            currentNotifications.remove(at: indexPath.row)
            
//            2.0 pull the data from defaults
            let userDefaults = UserDefaults.standard
            var currentAPNUI = userDefaults.object(forKey: "apnNotificationUserInfo") as? [[AnyHashable : Any]]
//            2.1 delete at index
            currentAPNUI?.remove(at: indexPath.row)
//            2.2 push the new list back to the defaults
            userDefaults.setValue(currentAPNUI, forKey: "apnNotificationUserInfo")
            
//                            post a notification that tells the collectionView to reload
            NotificationCenter.default.post(name: .notificationTapped, object: nil)
            
            
//                push the event card to the view
                        if let popController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventController") as? NL_eventController{
                            
//                    var nav = UINavigationController(rootViewController: popController)
//              set the presentation style
                            popController.modalPresentationStyle = UIModalPresentationStyle.popover

//              present the popover
                            self.present(popController, animated: true, completion: nil)
                        }
        }
    }
    }
    
    
  
    // sets the size of the cell based on the collectionView
    func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize()
        
         size = CGSize(width: screenWidth - 32, height: 85)
        
           return size
       }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
    

        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

//    we set the minimum spacing to align with the spacing of the week days, spacing between items on the same row
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        var spacing = CGFloat()
        
            spacing = 0
            
        
        return spacing
    }

//    spacing between rows
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        var spacing = CGFloat()
        
            spacing = 0

        return spacing
    }
    
       
}

//extension to be added to all tabbed viewControllers
extension NL_NotificationsController{
    
    @objc func openTabClicked1(){
     print("option 1 clicked")
            
        if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_HomePage") as? NL_HomePage {
           self.navigationController?.pushViewController(viewController, animated: false)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        }
     
    }
    
    @objc func openTabClicked2(){
     print("chat pressed")
        if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_chatLogController") as? NL_chatLogController {
           self.navigationController?.pushViewController(viewController, animated: false)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        }
    }
    
    @objc func openTabClicked3(){
        print("create event pressed 3")
        
//        we push the viewController to the front
        let secondStoryBoard = UIStoryboard(name: "NL-CreateEvent", bundle: nil)
        if let viewController = secondStoryBoard.instantiateViewController(withIdentifier: "createEvent1") as? NL_CreateEvent {
        let navController = UINavigationController(rootViewController: viewController)
            self.navigationController?.present(navController, animated: true, completion: nil)
        }
    }
    
    
    @objc func openTabClicked4(){
     print("notification  pressed")
     
        if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_NotificationsController") as? NL_NotificationsController {
           self.navigationController?.pushViewController(viewController, animated: false)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        }
}
    
    @objc func openTabClicked5(){
     print("Events page pressed")
        if let viewController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventsViewController") as? NL_eventsViewController {
           self.navigationController?.pushViewController(viewController, animated: false)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        }
    }
}



