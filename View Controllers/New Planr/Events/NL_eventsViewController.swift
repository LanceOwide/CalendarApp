//
//  NL_eventsViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 9/2/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit


var eventPageEvents = [eventSearch]()

class NL_eventsViewController: UIViewController {

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
        
    //    add the tabBar
        var tabView: NL_tabHelper = NL_tabHelper(frame: CGRect(x:0, y:0, width: screenWidth, height: 80))
    
//    variables
    var topView = UIView()
    var btnHosted = UIButton()
    var btnUpcoming = UIButton()
    var btnPast = UIButton()
    var btnHostedView = UIView()
    var btnUpcomingView = UIView()
    var btnPastview = UIView()
    var collectionViewEvents: UICollectionView!
    var currentView = "Hosted"
    
    let cellId = "cellId"
    let cellId2 = "cellId2"
    
    
//    set the delegate for the invitee collectionView
    var innerDelegate = InnerCollectionViewDelegate2()
    
//    add an observer to hold the observer so we can remove it at a later date
    var observer: NSObjectProtocol?
    var observer2: NSObjectProtocol?
    let notificationCenter = NotificationCenter.default
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTheNavigationbar()
        
//        we load the events we need
        reloadTheEvents()
        
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
        tabView.imageView3.addTarget(self, action: #selector(openTabClicked3), for: .touchUpInside)
        tabView.imageView1.addTarget(self, action: #selector(openTabClicked1), for: .touchUpInside)
        tabView.imageView2.addTarget(self, action: #selector(openTabClicked2), for: .touchUpInside)
        tabView.imageView4.addTarget(self, action: #selector(openTabClicked4), for: .touchUpInside)
        tabView.imageView5.addTarget(self, action: #selector(openTabClicked5), for: .touchUpInside)

//        set the border for the page we are on
        tabView.imageView5.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
        tabView.imageView5.layer.borderWidth = 0
        tabView.imageView5.backgroundColor = MyVariables.colourSelected
        tabView.imageView5.layer.cornerRadius = 5
        tabView.label5.textColor = MyVariables.colourPlanrGreen
        tabView.imageView5.layer.borderWidth = 1
        tabView.imageView5.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
        
//        add observer to update the events once we have new data loaded
        NotificationCenter.default.addObserver(self, selector: #selector(updateTables), name: .availabilityUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTables), name: .newDataLoaded, object: nil)
        
        observer = notificationCenter.addObserver(forName: .inviteSelected,
                                                  object: nil,
                                                  queue: nil) { [weak self] notification in
                    guard let self = self else { return }
            
           let userInfo = notification.userInfo
            self.inviteSelected(notification: userInfo!)
                }
        
        observer2 = notificationCenter.addObserver(forName: .reminderSelected,
                                                  object: nil,
                                                  queue: nil) { [weak self] notification in
                    guard let self = self else { return }
            
           let userInfo = notification.userInfo
            self.reminderSelected(notification: userInfo!)
                }
   
    }
    
    @objc func updateTables(){
        
        DispatchQueue.main.async {
            self.reloadTheEvents()
        }
    }
    
    @objc func inviteSelected(notification: [AnyHashable : Any]){
        
        if let eventID = notification["eventID"] as? String {
        
        getNonUsers(eventID: eventID){
    (usersName, usersNumbers) in
            self.inviteFriendsPopUp(notExistingUserArray: usersNumbers, nonExistingNameArray: usersName)
            }
        }
    }
    
    @objc func reminderSelected(notification: [AnyHashable : Any]){
        //            the userselected must be a user, we check if the user selected hasnt responded and ask the user if they want to remind them
        
        let userID = notification["userID"] as? String
        let userName = notification["userName"] as? String
        let eventID = notification["eventID"] as? String
                    
        reminderPopUp(eventID: eventID!, userID: userID!, userName: userName!)
   
    }
    
//    function to remove the observer for the invite non user to the app
        func removeInviteeObserver(){
            print("running func removeInviteeObserver")
                if (observer != nil) {
                    notificationCenter.removeObserver(observer!)
                    print("removeInviteeObserver observer removed")
                }
            if (observer2 != nil) {
                notificationCenter.removeObserver(observer2!)
                print("removeInviteeObserver observer removed")
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
            
            topView.addSubview(btnHosted)
            topView.addSubview(btnUpcoming)
            topView.addSubview(btnPast)
        
            
            btnHosted.translatesAutoresizingMaskIntoConstraints = false
            btnUpcoming.translatesAutoresizingMaskIntoConstraints = false
            btnPast.translatesAutoresizingMaskIntoConstraints = false
            
            btnHosted.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
            btnUpcoming.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
            btnPast.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
            
            btnHosted.heightAnchor.constraint(equalToConstant: btnHeight).isActive = true
            btnUpcoming.heightAnchor.constraint(equalToConstant: btnHeight).isActive = true
            btnPast.heightAnchor.constraint(equalToConstant: btnHeight).isActive = true
            
            btnHosted.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
            btnUpcoming.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
            btnPast.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
            
            btnHosted.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
            btnUpcoming.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: btnWidth).isActive = true
            btnPast.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: btnWidth*2).isActive = true
            
            btnHosted.setTitle("Hosting", for: .normal)
            btnUpcoming.setTitle("Upcoming", for: .normal)
            btnPast.setTitle("Past", for: .normal)
            
            
            btnHosted.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btnUpcoming.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btnPast.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            
            btnHosted.setTitleColor(MyVariables.colourPlanrGreen, for: .normal)
            btnUpcoming.setTitleColor(MyVariables.colourLight, for: .normal)
            btnPast.setTitleColor(MyVariables.colourLight, for: .normal)

            btnHosted.titleLabel?.textAlignment = .center
            btnUpcoming.titleLabel?.textAlignment = .center
            btnPast.titleLabel?.textAlignment = .center
            
            btnHosted.addTarget(self, action: #selector(hostedTapped), for: .touchUpInside)
            btnUpcoming.addTarget(self, action: #selector(upcomingTapped), for: .touchUpInside)
            btnPast.addTarget(self, action: #selector(pastTapped), for: .touchUpInside)
            
//            add the separators
            
            topView.addSubview(btnHostedView)
            topView.addSubview(btnUpcomingView)
            topView.addSubview(btnPastview)
            
            btnHostedView.translatesAutoresizingMaskIntoConstraints = false
            btnUpcomingView.translatesAutoresizingMaskIntoConstraints = false
            btnPastview.translatesAutoresizingMaskIntoConstraints = false
            
            btnHostedView.backgroundColor = MyVariables.colourPlanrGreen
            btnUpcomingView.backgroundColor = MyVariables.colourLight
            btnPastview.backgroundColor = MyVariables.colourLight
            
            btnHostedView.topAnchor.constraint(equalTo: topView.topAnchor, constant: btnHeight).isActive = true
            btnUpcomingView.topAnchor.constraint(equalTo: topView.topAnchor, constant: btnHeight).isActive = true
            btnPastview.topAnchor.constraint(equalTo: topView.topAnchor, constant: btnHeight).isActive = true
            
            btnHostedView.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
            btnUpcomingView.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
            btnPastview.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
            
            btnHostedView.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
            btnUpcomingView.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
            btnPastview.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
            
            btnHostedView.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
            btnUpcomingView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: btnWidth).isActive = true
            btnPastview.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: btnWidth*2).isActive = true
            
//            add the collection view for the events
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            //        layout3.sectionHeadersPinToVisibleBounds = true
            collectionViewEvents = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionViewEvents?.translatesAutoresizingMaskIntoConstraints = false
            collectionViewEvents?.delegate = self
            collectionViewEvents?.dataSource = self
            collectionViewEvents?.backgroundColor = .white
            collectionViewEvents?.register(NL_eventCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
            
            collectionViewEvents?.isScrollEnabled = true
            collectionViewEvents?.isUserInteractionEnabled = true
            collectionViewEvents?.allowsSelection = true
            collectionViewEvents?.allowsMultipleSelection = false
            topView.addSubview(collectionViewEvents!)
            collectionViewEvents?.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
            collectionViewEvents?.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth - sideInset - sideInset)).isActive = true
            collectionViewEvents?.topAnchor.constraint(equalTo: topView.topAnchor, constant: btnHeight + 5).isActive = true
            collectionViewEvents?.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
            

            return containerView
    }()
    
    
    func reloadTheEvents(){
        //        we get the hosted events since this is the first page the user sees
        if currentView == "Hosted"{
            getTheEventsFunc(hosted: true, upcoming: false, past: false){
                (events) in
               eventPageEvents = events
                if self.collectionViewEvents == nil{
                }
                else{
                    DispatchQueue.main.async {
                self.collectionViewEvents.reloadData()}
                }
            }
        }
        else if currentView == "Upcoming"{
            getTheEventsFunc(hosted: false, upcoming: true, past: false){
                (events) in
                eventPageEvents = events
                if self.collectionViewEvents == nil{
                }
                else{
                    DispatchQueue.main.async {
                    self.collectionViewEvents.reloadData()}
                }
            }
        }
        else if currentView == "Past"{
            getTheEventsFunc(hosted: false, upcoming: false, past: true){
                (events) in
                eventPageEvents = events
                if self.collectionViewEvents == nil{
                }
                else{
                    DispatchQueue.main.async {
                    self.collectionViewEvents.reloadData()}
                }
            }
        }
    }
    
    @objc func hostedTapped(){
        print("hostedTapped")
        
//        change the separator color
        btnHostedView.backgroundColor = MyVariables.colourPlanrGreen
        btnUpcomingView.backgroundColor = MyVariables.colourLight
        btnPastview.backgroundColor = MyVariables.colourLight
//        change the font of the button
        btnHosted.setTitleColor(MyVariables.colourPlanrGreen, for: .normal)
        btnUpcoming.setTitleColor(MyVariables.colourLight, for: .normal)
        btnPast.setTitleColor(MyVariables.colourLight, for: .normal)
        
        currentView = "Hosted"
        reloadTheEvents()
    }
    
    @objc func upcomingTapped(){
       print("upcomingTapped")
        
//        change the separator color
                btnHostedView.backgroundColor = MyVariables.colourLight
                btnUpcomingView.backgroundColor = MyVariables.colourPlanrGreen
                btnPastview.backgroundColor = MyVariables.colourLight
//        change the font of the button
                btnHosted.setTitleColor(MyVariables.colourLight, for: .normal)
                btnUpcoming.setTitleColor(MyVariables.colourPlanrGreen, for: .normal)
                btnPast.setTitleColor(MyVariables.colourLight, for: .normal)
        
        currentView = "Upcoming"
        reloadTheEvents()
    }
    
    @objc func pastTapped(){
        print("pastTapped")
        
        //        change the separator color
                btnHostedView.backgroundColor = MyVariables.colourLight
                btnUpcomingView.backgroundColor = MyVariables.colourLight
                btnPastview.backgroundColor = MyVariables.colourPlanrGreen
        //        change the font of the button
                btnHosted.setTitleColor(MyVariables.colourLight, for: .normal)
                btnUpcoming.setTitleColor(MyVariables.colourLight, for: .normal)
                btnPast.setTitleColor(MyVariables.colourPlanrGreen, for: .normal)
        
        currentView = "Past"
        reloadTheEvents()
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

}

//extension to be added to all tabbed viewControllers
extension NL_eventsViewController{
    
    @objc func openTabClicked1(){
     print("option 1 clicked")
        
        //            remove the invitee observer to not interfere with other pages
                            removeInviteeObserver()
            
        if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_HomePage") as? NL_HomePage {
           self.navigationController?.pushViewController(viewController, animated: false)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        }
     
    }
    
    @objc func openTabClicked2(){
     print("chat pressed")
        
        //            remove the invitee observer to not interfere with other pages
                            removeInviteeObserver()
        
        if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_chatLogController") as? NL_chatLogController {
           self.navigationController?.pushViewController(viewController, animated: false)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        }
    }
    
    @objc func openTabClicked3(){
        print("create event pressed 3")
        
        //            remove the invitee observer to not interfere with other pages
                            removeInviteeObserver()
        
//        we push the viewController to the front
        let secondStoryBoard = UIStoryboard(name: "NL-CreateEvent", bundle: nil)
        if let viewController = secondStoryBoard.instantiateViewController(withIdentifier: "createEvent1") as? NL_CreateEvent {
        let navController = UINavigationController(rootViewController: viewController)
            self.navigationController?.present(navController, animated: true, completion: nil)
        }
    }
    
    
    @objc func openTabClicked4(){
     print("notification  pressed")
        
        //            remove the invitee observer to not interfere with other pages
                            removeInviteeObserver()
     
        if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_NotificationsController") as? NL_NotificationsController {
           self.navigationController?.pushViewController(viewController, animated: false)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        }
    }
    
    @objc func openTabClicked5(){
     print("This page pressed")
    }
    
}

//extention to manage the collectionView of dates
extension NL_eventsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = Int()
        
        numberOfItems = eventPageEvents.count
        
        if numberOfItems == 0{
            collectionView.setEmptyMessage(message: "Tap on + to add a new event", messageAlignment: .center)
        }else{
            collectionView.restore()
        }
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = UICollectionViewCell()
        
//            MARK: event collection view
         if collectionView == collectionViewEvents{
            let cell = collectionViewEvents?.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NL_eventCollectionViewCell
            
//            setup the cell as rounded and with a border
            cell.layer.cornerRadius = 10
//            set the delegate for the invitee collectionViewController
            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: innerDelegate, forRow: indexPath.row)
            
//            populate the data for the event cells
//            a variable to hold the set of events we are going to use
             listOfEvents = eventPageEvents
            
//            set the cells information based on the row we are using
            let event = listOfEvents[indexPath.row]
                cell.lbleventTitle.text = event!.eventDescription
                cell.lbleventLocation.text = event!.eventLocation
            
//            set the event image, check that we have an eventType currently listed in our event and present in the array of images
            if let index = eventTypeImages.userEventChoices.index(of: event!.eventType){
                    let imageName = eventTypeImages.userEventChoicesImagesColored[index]
                    cell.eventImage.image = UIImage(named: imageName)
            }
            else{
                cell.eventImage.image = UIImage(named: "customColoredCode")
                }
            
            cell.lbleventTime.text = ("\(convertToLocalTime(inputTime: event!.eventStartTime)) - \(convertToLocalTime(inputTime:(event!.eventEndTime)))")
                
            
//          if the user has chosen the date we want to display that date in the time slot
            if event?.chosenDate != ""{
              cell.lblstatus.text = "Date Confirmed"
                cell.lblstatus.textColor = MyVariables.colourPlanrGreen
                cell.lblstatus.backgroundColor = MyVariables.colourSelected
//                convert the date into a display date DD MMM
                let displayDate = dateTZToShortDisplayDate(date: event!.chosenDate)
                let day = dateTZToDay(date: event!.chosenDate)
                let dayNum = dateTZToDayNum(date: event!.chosenDate)
                let month = dateTZToMonth(date: event!.chosenDate)
                print("day\(day)dayNum\(dayNum)month\(month)")
                
//                create attributed string for the date
                let font = UIFont.systemFont(ofSize: 13)
                let attributes = [NSAttributedString.Key.font: font]
                let attributedQuote = NSMutableAttributedString(string: "\(String(day))\n", attributes: attributes)
                            
                let font2 = UIFont.systemFont(ofSize: 15)
                let attributes2 = [NSAttributedString.Key.font: font2]
                let attributedQuote2 = NSMutableAttributedString(string: "\(String(dayNum))\n", attributes: attributes2)
                            
                let font3 = UIFont.systemFont(ofSize: 13)
                let attributes3 = [NSAttributedString.Key.font: font3]
                let attributedQuote3 = NSMutableAttributedString(string: String(month), attributes: attributes3)
                            
                attributedQuote.append(attributedQuote2)
                attributedQuote.append(attributedQuote3)
                            
                cell.lbleventDate.attributedText = attributedQuote
                
                cell.lbleventDate.isHidden = false
                
            }
            else{
    //            we need to check if every user has responded, this can be done, 1. there should be no non user names, 2.we need to loop through each user in the event and check if no every one has responded
                
    //            tracking bool for a user not having responded
                var notResponded = false
                var declined = false
                
                if event?.nonUserNames.count != 0{
                    notResponded = true
                }
                
                for uid in event!.users{
                    print("looping through availability")
    //                get the availability
                    let availability = CoreDataCode().serialiseAvailabilitywUser(eventID: event!.eventID, userID: uid)
    //                the user isnt a user, we could not fund them so we set to 0
                    if availability.count == 0{
                        notResponded = true
                    }
                    else{
                        
//                       check if the user is the current user and if they declined the event
                let userAvailabilityArray = availability[0].userAvailability
                        if uid == user{
                            if availability[0].responded == "no"{
                                declined = true
                            }
                    }
    //                    we check what was retruned
        //                       2.1 the user has not responded and they have a picture, we set their image and blur it
                        if userAvailabilityArray[0] == 11 ||  userAvailabilityArray[0] == 99{
                            notResponded = true
                        }
                    }
                }

    //            if the not responded is now set to true we are awaiting responses
                if declined == true{
                    cell.lblstatus.text = "Declined"
                    cell.lblstatus.textColor = MyVariables.darkRed
                    cell.lblstatus.backgroundColor = MyVariables.lightRed
                    cell.lbleventDate.isHidden = true
                }
                else if notResponded == true{
                    cell.lblstatus.text = "Awaiting Responses"
                    cell.lblstatus.textColor = MyVariables.colourPendingText
                    cell.lblstatus.backgroundColor = MyVariables.colourPendingBackground
                    cell.lbleventDate.isHidden = true
                }
                else{
                    cell.lblstatus.text = "Host to Pick Date"
                    cell.lblstatus.textColor = MyVariables.colourPendingText
                    cell.lblstatus.backgroundColor = MyVariables.colourPendingBackground
                    cell.lbleventDate.isHidden = true
                }
            }
                
            return cell
        }
        return cell
    }
    
//    did select item at
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == collectionViewEvents{
//            we set the currentSelected event and then push the eventView onto the screen
            currentUserSelectedEvent = eventPageEvents[indexPath.row]
            
//            set the availability for the event
            
            currentUserSelectedAvailability = serialiseAvailability(eventID: currentUserSelectedEvent.eventID)
            print("currentUserSelectedAvailability \(currentUserSelectedAvailability)")
            prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                
//                push the event card to the view
                if let popController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventController") as? NL_eventController{
                    
//                    var nav = UINavigationController(rootViewController: popController)
                    // set the presentation style
                    popController.modalPresentationStyle = UIModalPresentationStyle.popover

//                    popController.popoverPresentationController?.delegate = self

                // present the popover
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
        
//
        
        if collectionView == collectionViewEvents{
         size = CGSize(width: screenWidth - 32, height: 160)
            
        }
        
           return size
       }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
    
        
            if collectionView == collectionViewEvents{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

//    we set the minimum spacing to align with the spacing of the week days, spacing between items on the same row
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        var spacing = CGFloat()
        
        if collectionView == collectionViewEvents{
            spacing = 0
            
        }
        
        return spacing
    }

//    spacing between rows
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        var spacing = CGFloat()
        
        if collectionView == collectionViewEvents{
            spacing = 10
        }

        return spacing
    }
    
}

//delegate for handling the collectionView within a collectionView
class InnerCollectionViewDelegate2: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collectionViewCell invitees reloading")
        var numberOfRows = Int()
        
        numberOfRows = eventPageEvents[collectionView.tag].currentUserNames.count + eventPageEvents[collectionView.tag].nonUserNames.count

        return numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId2 = "cellId2"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId2, for: indexPath) as! NL_inviteesCell
        
        let combinedNameList = eventPageEvents[collectionView.tag].currentUserNames + eventPageEvents[collectionView.tag].nonUserNames
        var combinedNameListSorted = [""]
        var combinedNameListOthers = [""]
        
//        we loop through the combined list of users and add the host to the combined list first, this is precaution in case the host isnt the first name on the list (this should always be the case)
        for i in combinedNameList{
//            if the current user is the host add them to the combinedNameListSorted
            if i == eventPageEvents[collectionView.tag].eventOwnerName{
                combinedNameListSorted.append(i)
            }else{
//                otherwise we add them to the other list
                combinedNameListOthers.append(i)
            }
        }
//        combine the two lists
        combinedNameListSorted = combinedNameListSorted + combinedNameListOthers
//        add the name of the invitee to the names list
        cell.lblInviteeName.text = combinedNameList[indexPath.row]
//        hide all host icons for all user
        cell.lblHost.isHidden = true
        cell.layer.borderWidth = 0
        cell.layer.cornerRadius = 0
        
//        to avoid errors we check we arent at a invitee who isnt a user
        
        if indexPath.row <= eventPageEvents[collectionView.tag].users.count - 1{
            print("this invitee is a user")
//        we want to set the images for the event invitees
            let currentUserId = eventPageEvents[collectionView.tag].users[indexPath.row]
            let currentEventID = eventPageEvents[collectionView.tag].eventID
            
//                    we want to check if the user has responded and if not display the hourglass
            let availability = CoreDataCode().serialiseAvailabilitywUser(eventID: currentEventID, userID: currentUserId)
            
// get the users image
                let imageList = CoreDataCode().fetchImage(uid: currentUserId)
            
            var image = Data()
            if imageList.count != 0{
                image = imageList[0].userImage!
            }
//                    loop through each possible user itteration and set the image and status accordingly
            
            if availability.count == 0 && imageList.count != 0{
                cell.inviteeStatus.isHidden = false
                cell.inviteeStatus.image = UIImage(named: "hourGlassCodeCircle")
                cell.inviteePicture.image = UIImage(data: image)?.alpha(0.5)
                cell.inviteePicture.isHidden = false
                cell.respondedTickView.isHidden = true
                cell.eventImageView.isHidden = true
            }
            else if availability.count == 0 && imageList.count == 0{
                cell.inviteeStatus.isHidden = false
                cell.inviteeStatus.image = UIImage(named: "hourGlassCodeCircle")
                cell.inviteePicture.image = .none
                cell.inviteePicture.isHidden = false
                cell.respondedTickView.isHidden = true
                cell.eventImageView.isHidden = true
            }
            
//                    2. They are a user
            if availability.count != 0{
//                        check if the user has responded
                let userAvailabilityArray = availability[0].userAvailability
//                       2.1 the user has not responded and they have a picture, we set their image and blur it
                if userAvailabilityArray[0] == 11 ||  userAvailabilityArray[0] == 99 && imageList.count != 0{
                    cell.inviteeStatus.isHidden = false
                    cell.inviteeStatus.image = UIImage(named: "hourGlassCodeCircle")
                    cell.inviteePicture.image = UIImage(data: image)?.alpha(0.5)
                    cell.inviteePicture.isHidden = false
                    cell.eventImageView.isHidden = true
                }
//                        2.2 the user has responded and they do not have a picture
                else if userAvailabilityArray[0] != 11 &&  userAvailabilityArray[0] != 99 && imageList.count == 0{
                    cell.inviteeStatus.isHidden = true
                    cell.inviteePicture.image = .none
                    cell.inviteePicture.isHidden = false
                    cell.eventImageView.isHidden = false
                }
//                      2.3 the user has responded and they have a picture
                else if userAvailabilityArray[0] != 11 &&  userAvailabilityArray[0] != 99 && imageList.count != 0{
                    cell.inviteeStatus.isHidden = true
                    cell.inviteePicture.image = UIImage(data: image)
                    cell.inviteePicture.isHidden = false
                    cell.eventImageView.isHidden = false
                }
//                        2.4 the user has not responded and they do not have a picture
                else if userAvailabilityArray[0] == 11 ||  userAvailabilityArray[0] == 99 && imageList.count == 0{
                    cell.inviteeStatus.isHidden = false
                    cell.inviteeStatus.image = UIImage(named: "hourGlassCodeCircle")
                    cell.inviteePicture.image = .none
                    cell.inviteePicture.isHidden = false
                    cell.eventImageView.isHidden = true
                }
                
//            we check if the user has responded and show the double tick if they have responded
//            holding whether the user has responded
                let respondedType = availability[0].responded
                    if respondedType == "yes"{
                        cell.respondedTickView.isHidden = false
                        }
                        else if respondedType == "no" && imageList.count != 0{
                        cell.respondedTickView.isHidden = true
                        cell.inviteeStatus.isHidden = false
                        cell.inviteePicture.image = UIImage(data: image)?.alpha(0.5)
                        cell.inviteeStatus.image = UIImage(named: "declineCode")
                        cell.eventImageView.isHidden = true
                        }
                        else if respondedType == "no" && imageList.count == 0{
                            cell.inviteePicture.image = .none
                            cell.inviteeStatus.image = UIImage(named: "declineCode")
                            cell.eventImageView.isHidden = true
                            cell.respondedTickView.isHidden = true
                            cell.inviteeStatus.isHidden = false
                        }
                        else{
                            cell.respondedTickView.isHidden = true
                        }
            }
        }
//                    this invitee isnt a user yet
        else{
//            the invitee isnt a user yet
            cell.inviteePicture.image = .none
            cell.inviteeStatus.isHidden = false
//                    set the status image to say invite to Planr
            let inviteImage = CoreDataCode().imageWith(name: "Invite", width: 100, height: 100, fontSize: 20, textColor: MyVariables.colourPlanrGreen)
            cell.inviteeStatus.image = inviteImage
            cell.respondedTickView.isHidden = true
            cell.eventImageView.isHidden = true
                            }


//        show the host label for the first invitee
        if indexPath.row == 0{
            cell.lblHost.isHidden = false
            cell.lblHost.textColor = MyVariables.colourPlanrGreen
            cell.lblHost.font = UIFont.boldSystemFont(ofSize: 10)
            cell.respondedTickView.isHidden = false
        }

        
//        return the cell of the invitee
        return cell
    }
    
// sets the size of the cell
        func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
            var size = CGSize()
            size = CGSize(width: 70, height: 70)
               return size
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if the user selected an invitee that isnt a user we want to offer the user to invite them
        print("user selected an invitee")
        
        if eventPageEvents[collectionView.tag].eventOwnerID == user{
            
            //            if they tap on themselves we dont do anything
                        if indexPath.row == 0{
                            
                        }
                        else{
        
//        check if the selected user wasnt a user
        if indexPath.row > eventPageEvents[collectionView.tag].currentUserNames.count - 1{
            print("indexPath.row >= eventPageEvents[collectionView.tag].currentUserNames.count = true")
            
//            we can't present the notification from the inner delegate, hence we post a notification that is being monitored by the page and will post a notification. we pass the eventId through the userInfo tag.
            let inviteeDict:[String: String] = ["eventID": eventPageEvents[collectionView.tag].eventID]
            NotificationCenter.default.post(name: .inviteSelected, object: nil, userInfo: inviteeDict)
        }
        else{
            let userID = eventPageEvents[collectionView.tag].users[indexPath.row]
            let userName = eventPageEvents[collectionView.tag].currentUserNames[indexPath.row]
            let eventID = eventPageEvents[collectionView.tag].eventID
            let reminderDict:[String: String] = ["userID": userID, "userName": userName, "eventID": eventID]
            NotificationCenter.default.post(name: .reminderSelected, object: nil, userInfo: reminderDict)
            
        }
    }
    }
    }
  
}




