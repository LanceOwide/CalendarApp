//
//  NL_HomePage.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/26/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import Instructions
import PhoneNumberKit

//global variables to hold the confirmed and pending events
var pendingEventList = [[eventSearch?]]()
var confirmedEventList = [[eventSearch?]]()
//variable to hold the date the user has selected
var selectedDate: Int?
//get the pending state of the calendar
var pendingState = true
//array used to house the events array to be displayed
var displayedEvents = [[eventSearch?]]()
//array to hold the events for the date the user is looking at
var listOfEvents = [eventSearch?]()
//variable to indicate whether the load calendar function is currently running, this relates to the function loadCalendars2Auto
var loadCalendars2AutoIsRunning = false

//variable to let the coachmarks know which to run
var coachmarkHelperText = String()


class NL_HomePage: UIViewController, NL_MonthViewDelegate, UIPopoverPresentationControllerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    
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
    var tableViewBlock = UITableView()
    var cellId = "cellId"
    var cellId2 = "cellId2"
    var collectionViewDates: UICollectionView!
    var collectionViewEvents: UICollectionView!
    
//    variables used for the dates of the week
    var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    var currentMonthIndex: Int = 0
    var currentYear: Int = 0
    var presentMonthIndex = 0
    var presentYear = 0
    var todaysDate = 0
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-7)
    var DOTWView = UIView()
    var separatorLine = UIView()
    var topView = UIView()
    let coachMarksController = CoachMarksController()
    var instructionsTriggered = false
    
    //setting the delegate to be used for the invitee collectionView
    var innerDelegate = InnerCollectionViewDelegate()
    
//    add an observer to hold the observer so we can remove it at a later date
    var observer: NSObjectProtocol?
    var observer2: NSObjectProtocol?
    var newDataObserver: NSObjectProtocol?
    let notificationCenter = NotificationCenter.default
    
//    switch for the pending status
    var menuBtn2 = UISwitch()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("running viewDidLoad ")
        
//        opening setup func
//        if the user is new, we do not want to go through this setup until they have seen the notifications
        if UserDefaults.standard.bool(forKey: "oldUser") == true{
        openingSetup()
            
//            we don't let the homepage update unless the user is an old one, otherwise the app will crash
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHomePage), name: .newDataLoaded, object: nil)
        }
        
        
        setUpTheDateView()
        
//        show the tutorial for the front page and the new user intro
        showTutorial()
        
//        setup coachmarks
        //        ***For coachMarks
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.isUserInteractionEnabled = true
        
        
        
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
        
        
//        add an observer to detect when the tutorial is closed and show the relevant coachmarks
        NotificationCenter.default.addObserver(self, selector: #selector(tutorialClosed), name: .tutorialClosed, object: nil)
    
            
        
//        AutoRespondHelper.registerForPushNotificationsAuto()
        
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
        tabView.imageView1.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
        tabView.imageView1.layer.borderWidth = 0
        tabView.imageView1.backgroundColor = MyVariables.colourSelected
        tabView.imageView1.layer.cornerRadius = 5
        tabView.label1.textColor = MyVariables.colourPlanrGreen
        tabView.imageView1.layer.borderWidth = 1
        tabView.imageView1.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
        
//        show the event notifications and print them
        let notifications = UserDefaults.standard.dictionary(forKey: "eventNotifications")
        print("notifications list \(notifications?.values)")
        
//        add the navigation bar
        setupTheNavigationbar()
        
        
        if pendingState == true{
            
            monthView.lblConfirmed.isHidden = false
            monthView.lblAnd.isHidden = false
            monthView.lblPending.isHidden = false
            monthView.lblConfirmedCenter.isHidden = true
        }
        else{
            monthView.lblConfirmed.isHidden = true
            monthView.lblAnd.isHidden = true
            monthView.lblPending.isHidden = true
            monthView.lblConfirmedCenter.isHidden = false
        }
        
//        we set the notification listener on
        if notificationListenerEnagaged == false{FirebaseCode().checkNotificationStatusListener()}
        
        
    }
//    function to refresh the page when the user changes the event
    @objc func reloadHomePage(){
        print("running func reloadHomePage")
        DispatchQueue.main.async {
            self.getEventsForMonth{
//        refresh the collectionview when the user moves to the next month
            self.collectionViewDates.reloadData()
            self.collectionViewEvents.reloadData()
        }
        }
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
    
    @objc func reminderSelected(notification: [AnyHashable : Any]){
        //            the userselected must be a user, we check if the user selected hasnt responded and ask the user if they want to remind them
        
        let userID = notification["userID"] as? String
        let userName = notification["userName"] as? String
        let eventID = notification["eventID"] as? String
                    
        reminderPopUp(eventID: eventID!, userID: userID!, userName: userName!)
   
    }
    
        
//    function for inviting a new user
    @objc func inviteSelected(notification: [AnyHashable : Any]){
        if let eventID = notification["eventID"] as? String {
        getNonUsers(eventID: eventID){
    (usersName, usersNumbers) in
            self.inviteFriendsPopUp(notExistingUserArray: usersNumbers, nonExistingNameArray: usersName)
            }
        }
    }
    
    @objc func tutorialClosed(){
        print("tutorialClosed - instructionsTriggered \(instructionsTriggered)")
        
        
//        there appears to be a bug where this is being triggered twice, to stop this we set a variable to say the instructions are showing
        if instructionsTriggered == false{
            instructionsTriggered = true
//        check if the new user had an event invite already, if show show them the events page
        if CDEevents.count != 0{
        coachmarkHelperText = "firstTimeUserHasBeenInvited"
        coachMarksController.start(in: .window(over: self))
        }
        else if CDEevents.count == 0{
            instructionsTriggered = true
        coachmarkHelperText = "firstTimeUserNoEvent"
        coachMarksController.start(in: .window(over: self))
        }
        }
        
    }
    
//    we need to remove the observers everytime we change views, so that we dont recreata them
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .notificationsReloaded, object: nil)
        coachMarksController.stop(immediately: true)
    }
    
    
// setup the app when the user opens the homepage, used for separation from the ViewDidload
    func openingSetup(){
        print("opening setup running")
        
//        set the badge number to 0
                UIApplication.shared.applicationIconBadgeNumber = 0
        
//        setup the the title
        title = "Planr"

        //        set user default to log that the user isnt new
                UserDefaults.standard.set(true, forKey: "oldUser")
                
        //      check that the user is in our user database, or log them out
                checkUserInUserDatabase()
        
//        register for notificaitons, we add this here just in case it doesn't work from the app delegate
        AutoRespondHelper.registerForPushNotificationsAuto()
        
        //        Prepare coreData for the app
                if user == nil{
        //            delay for 15 seconds if the user isnt yet logged in
                    let seconds15 = 15.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds15) {
                        if user == nil{
        //                    delay for a further 15 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds15) {
                                self.prepareApp()
//                    check if there are any events the user hasnt responded to
                                AutoRespondHelper.nonRespondedEventsAuto()
                            }
                        }
                        else{
                            self.prepareApp()
//                    check if there are any events the user hasnt responded to
                            AutoRespondHelper.nonRespondedEventsAuto()
                        }
                    }
                }
                else{
                prepareApp()
//                    check if there are any events the user hasnt responded to
                    AutoRespondHelper.nonRespondedEventsAuto()
                }
        
        
//        do not show the back button when the users logs in
         navigationItem.hidesBackButton = true
        
    }
    
    
    func setUpTheDateView(){
        
        currentMonthIndex = Calendar.current.component(.month, from: Date())
        currentYear = Calendar.current.component(.year, from: Date())
        todaysDate = Calendar.current.component(.day, from: Date())
        firstWeekDayOfMonth=getFirstWeekDay()
        
        print("todaysDate \(todaysDate) firstWeekDayOfMonth \(firstWeekDayOfMonth)")
        
        selectedDate =  todaysDate
        
        presentMonthIndex=currentMonthIndex
        presentYear=currentYear
        
//        get events for the current month - we must do this after the dates are set otherwise it doesnt work
        getEventsForMonth{
//            we only update the app on
//            self.collectionViewDates.reloadData()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setUpTheDateView()
    }
    
    //    function to check for new events and activate the listeners when the user logs in
        func prepareApp(){
            print("running func prepareApp")
//        check we have data in core data and download all data if not in CD. We check to see if the cdAppHasLoaded flag is set, we do this becuase we do not want CDAppHasLoaded running at the same time as the eventListener
            if cdAppHasLoaded == true{
                print("prepareApp cdAppHasLoaded = true, we end only check the current dates")
            }
            else{
//                set cdAppHad loaded to true, since we dont want it to start more than once
                cdAppHasLoaded = true
                print("cdAppHasLoaded = false")
    //            before continuning we ensure the listeners are not engaged, we re-engage them once done.
                if availabilityListenerRegistration != nil{availabilityListenerRegistration.remove()
                 print("userNotificationCenter - disabling availabilityListenerRegistration")
                    availabilityListenerEngaged = false
                }
                if eventListenerRegistration != nil{eventListenerRegistration.remove()
                    print("userNotificationCenter - disabling eventListenerRegistration")
                    eventListenerEngaged = false
                }
            CDAppHasLoaded{
                //                            load the chat data
                            self.CDAppHasLoadedChats()
                
            //            completed getting event data, now check for availability
                        self.CDAppHasLoadedAvailability{
            //            engage the listeners to detect event and availability notifications only if the app hasn't just loaded

                            print("prepareApp: eventNotificationAppBackground \(eventNotificationAppBackground)")
                            if eventNotificationAppBackground == true{
                            }
                            else{
                                CoreDataCode().eventChangeListener()
                                CoreDataCode().availabilityChangeListener()
                            }
                            
                            self.dataConsistencyCheck()

                        }
                }}}
    
   
    
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
        
//        add the toggle button to the navigation bar
        
        let menuBarItem2 = UIBarButtonItem(customView: menuBtn2)
        menuBtn2.onTintColor = MyVariables.colourPendingText
        /*For off state*/
        menuBtn2.tintColor = MyVariables.colourPlanrGreen
        menuBtn2.layer.cornerRadius = menuBtn2.frame.height / 2.0
        menuBtn2.backgroundColor = MyVariables.colourPlanrGreen
        menuBtn2.clipsToBounds = true

//        set the current status of the toggle
        menuBtn2.setOn(pendingState, animated: false)
//        add the target to reset once changes
        menuBtn2.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        self.navigationItem.rightBarButtonItem = menuBarItem2
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = MyVariables.colourPlanrGreen
        navigationItem.backBarButtonItem = backItem
    }
    
    
    func showTutorial(){
        
    let firstTimeUser = UserDefaults.standard.string(forKey: "firstTimeOpeningvPROD") ?? ""
    var createEventCoachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
        
//        MARK: remove this when pushing to prod
//        createEventCoachMarksPermenant = true
        
    if firstTimeUser == "" || createEventCoachMarksPermenant == true{
    print("was the first time the user opened the app")
        
    let storyBoard = UIStoryboard(name: "TutorialStoryboard", bundle: nil)
    
    let popOverVC = storyBoard.instantiateViewController(withIdentifier: "pageViewTutorial") as! PageViewController
        
        DispatchQueue.main.async{
            
        self.navigationController?.isNavigationBarHidden = true

    self.addChild(popOverVC)
       popOverVC.view.frame = self.view.frame
       self.view.addSubview(popOverVC.view)
       popOverVC.didMove(toParent: self)
        
        }}
        else{
            print("wasn't the first time the user opened the app")
        }
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
    
//    on change of the toggle we re set the calendar
    @objc func toggleChanged(){
        
//        set pending state
        pendingState = menuBtn2.isOn
        print("menuBtn2.isOn \(menuBtn2.isOn)")
//        log the change event
        Analytics.logEvent(firebaseEvents.homePageTogglePressed, parameters: ["toggleSetTo" : menuBtn2.isOn])
        
        DispatchQueue.main.async {
            self.collectionViewDates.reloadData()
            self.collectionViewEvents.reloadData()
        }
        
//        set the visible headers
        
        if pendingState == true{
            
            monthView.lblConfirmed.isHidden = false
            monthView.lblAnd.isHidden = false
            monthView.lblPending.isHidden = false
            monthView.lblConfirmedCenter.isHidden = true
        }
        else{
            monthView.lblConfirmed.isHidden = true
            monthView.lblAnd.isHidden = true
            monthView.lblPending.isHidden = true
            monthView.lblConfirmedCenter.isHidden = false
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
            topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
            topView.backgroundColor = UIColor.white
            topView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(topView)
            topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            topView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            
//               add the month picker inot the view
            topView.addSubview(monthView)
            monthView.topAnchor.constraint(equalTo: topView.topAnchor).isActive=true
            monthView.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive=true
            monthView.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive=true
            monthView.heightAnchor.constraint(equalToConstant: monthViewHeight).isActive=true
            monthView.translatesAutoresizingMaskIntoConstraints = false
            monthView.delegate=self
            
//            create a set of labels representing the days of the week
//            1. create a new to place the labels in
            topView.addSubview(DOTWView)
            DOTWView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: monthViewHeight + spacerHeight).isActive = true
            DOTWView.heightAnchor.constraint(equalToConstant: DOTWHeight).isActive = true
            DOTWView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
            DOTWView.translatesAutoresizingMaskIntoConstraints = false
            
            
//            2. create the lables to go within the view
//            2.1 calcaulte the size of each label
//            sideInset*8 = the number of spaces on the page, spaces between the dotw and at the edges of the page
            let labelSize = CGFloat((screenWidth - sideInset*8)/7)
            let daysOfTheWeek = ["Mon","Tues","Wed","Thu","Fri","Sat","Sun"]
            let leftSapcing = [sideInset,labelSize+sideInset*2,labelSize*2+sideInset*3,labelSize*3+sideInset*4,labelSize*4+sideInset*5,labelSize*5+sideInset*6,labelSize*6+sideInset*7]
//            2.2 loop through each day of the week to create the label
            for n in 0...daysOfTheWeek.count-1{
                let lbl = UILabel()
                lbl.text = daysOfTheWeek[n]
                lbl.font = UIFont.systemFont(ofSize: 13)
                lbl.textAlignment = .center
                lbl.textColor = MyVariables.colourLight
                DOTWView.addSubview(lbl)
                lbl.topAnchor.constraint(equalTo: DOTWView.topAnchor).isActive = true
                lbl.bottomAnchor.constraint(equalTo: DOTWView.bottomAnchor).isActive = true
                lbl.widthAnchor.constraint(equalToConstant: labelSize*1).isActive = true
                lbl.leftAnchor.constraint(equalTo: DOTWView.leftAnchor, constant: leftSapcing[n]).isActive = true
                lbl.translatesAutoresizingMaskIntoConstraints = false
            }
            
//        collectionViewDates
//        add the collection view to display the selected dates
            let layout3: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout3.scrollDirection = .vertical
            //        layout3.sectionHeadersPinToVisibleBounds = true
            collectionViewDates = UICollectionView(frame: .zero, collectionViewLayout: layout3)
            collectionViewDates.translatesAutoresizingMaskIntoConstraints = false
            collectionViewDates.delegate = self
            collectionViewDates.dataSource = self
            collectionViewDates.backgroundColor = .white
            collectionViewDates.register(NL_collectionCollectionViewDateCell.self, forCellWithReuseIdentifier: cellId)
            collectionViewDates.isScrollEnabled = true
            collectionViewDates.isUserInteractionEnabled = true
            collectionViewDates.allowsSelection = true
            collectionViewDates.allowsMultipleSelection = false
            topView.addSubview(collectionViewDates)
            collectionViewDates.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
            collectionViewDates.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth - sideInset - sideInset)).isActive = true
            collectionViewDates.topAnchor.constraint(equalTo: topView.topAnchor, constant: monthViewHeight + DOTWHeight + spacerHeight).isActive = true

//            to calculate the sie of the collectionView will be based on the number of cells. We convert the itegers into doubles to allow us to calculate with decimal places
            let numberOfCells = Double(numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1)
            var numberOfRows = Double(numberOfCells/7)
            var numberOfRowsRounded = CGFloat()
            
//            the number of rows is a double, if the number of rows is not an integer we want to round upwards e.g 5.1 rows = 6 rows
            if numberOfRows > 5.0{
              numberOfRowsRounded = 6
            }
            else if numberOfRows > 4.0{
                numberOfRowsRounded = 5
            }
            else{
                numberOfRowsRounded = CGFloat(numberOfRows)
            }
//            add 1 for the spacing inbetween each row
            let wandH = CGFloat((screenWidth - 16*8)/7) + 1
            let collectionViewHeight = numberOfRowsRounded*wandH
            print("numberOfCells: \(numberOfCells) numberOfRows: \(numberOfRows) collectionViewHeight: \(collectionViewHeight) numberOfRowsRounded: \(numberOfRowsRounded)")
            
            collectionViewDates.heightAnchor.constraint(equalToConstant: CGFloat(collectionViewHeight)).isActive = true
            
//        create a separator line
            separatorLine.backgroundColor = MyVariables.colourPlanrGreen
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(separatorLine)
            separatorLine.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
            separatorLine.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth)).isActive = true
            separatorLine.topAnchor.constraint(equalTo: topView.topAnchor, constant: monthViewHeight + DOTWHeight + spacerHeight + collectionViewHeight).isActive = true
            separatorLine.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
            
            
//            collectionViewEvents
//        collectionViewDates
//        add the collection view to display the selected dates
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            //        layout3.sectionHeadersPinToVisibleBounds = true
            collectionViewEvents = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionViewEvents.translatesAutoresizingMaskIntoConstraints = false
            collectionViewEvents.delegate = self
            collectionViewEvents.dataSource = self
            collectionViewEvents.backgroundColor = .white
            collectionViewEvents.register(NL_eventCollectionViewCell.self, forCellWithReuseIdentifier: cellId2)
            
            collectionViewEvents.isScrollEnabled = true
            collectionViewEvents.isUserInteractionEnabled = true
            collectionViewEvents.allowsSelection = true
            collectionViewEvents.allowsMultipleSelection = false
            topView.addSubview(collectionViewEvents)
            collectionViewEvents.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
            collectionViewEvents.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth - sideInset - sideInset)).isActive = true
            collectionViewEvents.topAnchor.constraint(equalTo: topView.topAnchor, constant: monthViewHeight + DOTWHeight + spacerHeight + collectionViewHeight + separatorHeight*3).isActive = true
            collectionViewEvents.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
            
            return containerView
    }()
    
    
//setup the month view
    let monthView: NL_MonthView = {
        let v=NL_MonthView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
//    what to do when the user changes the month
    func didChangeMonth(monthIndex: Int, year: Int, state: Bool) {
        print("running func didChangeMonth - monthIndex: \(monthIndex), year: \(year), state: \(state)")
                    currentMonthIndex=monthIndex+1
                    currentYear = year

                    //for leap year, make february month of 29 days
                    if monthIndex == 1 {
                        if currentYear % 4 == 0 {
                            numOfDaysInMonth[monthIndex] = 29
                        } else {
                            numOfDaysInMonth[monthIndex] = 28
                        }
                    }
                    //end
                    
            firstWeekDayOfMonth=getFirstWeekDay()
//        set the pending status based on the toggle
//        pendingState = state
        
//        run the date change process to get the events for the new month
        getEventsForMonth{
//        refresh the collectionview when the user moves to the next month
            DispatchQueue.main.async {
            self.collectionViewDates.reloadData()
            self.collectionViewEvents.reloadData()
            }
        }
    }
    
    func getFirstWeekDay() -> Int {
        var day = Int()
        day  = ("\(currentYear)-\(currentMonthIndex)-01".date?.firstDayOfTheMonth.weekday)!
        
//        we have to adjust the date by one day
        if day == 1{
         day = 7
        }
        else{
            day = day - 1
        }
        print("getFirstWeekDay - day \(day)")
        return day
    }
    
    
//    MARK: coachmarkt controllers
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?){
                 
                 let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
                
                var hintLabels = [String]()
                var nextlabels = [String]()
                
                
//        we set the global variable coachmarkHelperText just before we launch the coachMarks, this tell it what we are running
                if coachmarkHelperText == "firstTimeUserHasBeenInvited"{
                    
                     hintLabels = ["You've already been invited to an event!","Head to the events page to view it"]
                    
                     nextlabels = ["OK","OK"]
                    
                    coachViews.bodyView.hintLabel.text = hintLabels[index]
//                    coachViews.bodyView.nextLabel.text = nextlabels[index]
                    
                }
                else if coachmarkHelperText == "firstTimeUserNoEvent"{
                    
                    hintLabels = ["Click the + to create your first event"]
                   
                    nextlabels = ["OK"]
                    coachViews.bodyView.hintLabel.text = hintLabels[index]
                    
                }
                 
                 return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
                 
             }
             
             
             func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
                 //    Defines where the coachmark will appear
                var pointOfInterest = UIView()
                
                if coachmarkHelperText == "firstTimeUserHasBeenInvited"{
                   
//                    we set where the coachmarks will appear
                    let hintPositions = [CGRect(x: screenWidth - 75, y: screenHeight - 75, width: 50, height: 50),CGRect(x: screenWidth - 75, y: screenHeight - 75, width: 50, height: 50)]
                    
                    pointOfInterest.frame = hintPositions[index]
                }
                else if coachmarkHelperText == "firstTimeUserNoEvent"{
                    
                    let hintPositions = [CGRect(x: screenWidth/2 - 25, y: screenHeight - 75, width: 50, height: 50)]
                    pointOfInterest.frame = hintPositions[index]
                    
                }
                 return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
             }
             
             
             
         //    The number of coach marks we wish to display
             func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
                
                var numberOfCoachMarks = Int()
                
                if coachmarkHelperText == "firstTimeUserHasBeenInvited"{
                    
                   numberOfCoachMarks = 2
                }
                else if coachmarkHelperText == "firstTimeUserNoEvent"{
                    numberOfCoachMarks = 1
                }
                
                 return numberOfCoachMarks
             }
         
     //    When a coach mark appears
         func coachMarksController(_ coachMarksController: CoachMarksController, willShow coachMark: CoachMark, at index: Int){
             
             print("Coach Index appeared \(index)")
    
         }
         
     //    when a coach mark dissapears
         func coachMarksController(_ coachMarksController: CoachMarksController, willHide coachMark: CoachMark, at index: Int){
            print("Coach Index disappeared \(index)")
         }  
}


//extention to manage the collectionView of dates
extension NL_HomePage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = Int()
        
        if collectionView == collectionViewDates{
//            if there is nothing in the confirmed events list we need to set the items to 0
            if confirmedEventList.count == 0{
             numberOfItems = 0
            }
            else{
            
        numberOfItems = numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1
            }
        
        print("numberOfItemsInSection: \(numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1)")
        }
        else if collectionView == collectionViewEvents{
            
    if pendingState == false && selectedDate == nil{
//                2.1 pending status is equal to false, we check which date the use has chosen in the calendar
        numberOfItems = 0
            }
        else if pendingState == true && selectedDate == nil{
        numberOfItems = 0
            }
        else if pendingState == false{
//        we need to check if the only entry is a null
        if confirmedEventList[selectedDate! - 1] == [nil]{
           numberOfItems = 0
        }
        else{
            numberOfItems = confirmedEventList[selectedDate! - 1].count}
//                        remove the empty message
        collectionView.restore()
        }
//                pending state must be equal to true
        else {
//        we need to check if both array are nil, then we have no events
        if confirmedEventList[selectedDate! - 1] == [nil] && pendingEventList[selectedDate! - 1] == [nil] {
          numberOfItems = 0
        }
//            if the confirmed events = nil, then we dont want ot include those
        else if confirmedEventList[selectedDate! - 1] == [nil] && pendingEventList[selectedDate! - 1] != [nil]{
           numberOfItems = pendingEventList[selectedDate! - 1].count
        }
//            if the pending events are equal to nil but the confirmed are not
        else if confirmedEventList[selectedDate! - 1] != [nil] && pendingEventList[selectedDate! - 1] == [nil]{
         numberOfItems = confirmedEventList[selectedDate! - 1].count
        }
        else{
//            neither of the event lists is equal to nil
            numberOfItems = confirmedEventList[selectedDate! - 1].count + pendingEventList[selectedDate! - 1].count}
//                        remove the empty message
        collectionView.restore()
                }

//            9.0 if there are no events we want to show the user the add event text
            if numberOfItems == 0{
                collectionView.setEmptyMessage(message: "Tap on + to add a new event", messageAlignment: .center)
            }
            print("collectionViewEvents - numberOfItems - \(numberOfItems)")
        }
        print("numberOfItems - \(numberOfItems)")
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = UICollectionViewCell()
        
//        collectionView for the dates of the month
        if collectionView == collectionViewDates{
        let cell = collectionViewDates.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NL_collectionCollectionViewDateCell
        
//            check if the cell is one that is empty based on the days of the week for this month
        if indexPath.item <= firstWeekDayOfMonth - 2 {
              cell.isHidden=true
          } else {
//            print("collectionView pendingEventList \(pendingEventList.count) confirmedEventList \(confirmedEventList.count)")
            
//            if not we continue to populate the data for the date
            
//            1. get the date for the cell
            let calcDate = indexPath.row-firstWeekDayOfMonth+2

//            2. set the indicators for the date
//            2.1 check to see if the user has set the pending toggle
            if pendingState == true{
                print("collectionView pending state equal true")
//            2.1 we check if there are both pending and chosen events for this date, this dicates whetehr we have 2 or 1 view
            if pendingEventList[indexPath.item - firstWeekDayOfMonth + 1] != [nil] && confirmedEventList[indexPath.item - firstWeekDayOfMonth + 1] != [nil]{
                print("collectionView - event for this date pending and confirmed")
//                there are both confirmed and unconfirmed events for today, we set both
//            setup both indicators
                cell.indicatorView21.backgroundColor = MyVariables.colourPendingText
                cell.indicatorView22.backgroundColor = MyVariables.colourPlanrGreen
                cell.indicatorView1.isHidden = true
                cell.indicatorView21.isHidden = false
                cell.indicatorView22.isHidden = false
            }
//                2.12 check if there are pending events
            else if pendingEventList[indexPath.item - firstWeekDayOfMonth + 1] != [nil]{
                 print("collectionView - event for this date pending")
                cell.indicatorView1.backgroundColor = MyVariables.colourPendingText
                cell.indicatorView1.isHidden = false
                cell.indicatorView21.isHidden = true
                cell.indicatorView22.isHidden = true
                }
//                2.13 check if there is a confirmed event
            else if confirmedEventList[indexPath.item - firstWeekDayOfMonth + 1] != [nil]{
                 print("collectionView - event for this date confirmed")
                cell.indicatorView1.backgroundColor = MyVariables.colourPlanrGreen
                cell.indicatorView1.isHidden = false
                cell.indicatorView21.isHidden = true
                cell.indicatorView22.isHidden = true
                }
            else{
//                hide all indicators
                print("collectionView - all indicators hidden")
                cell.indicatorView1.isHidden = true
                cell.indicatorView21.isHidden = true
                cell.indicatorView22.isHidden = true
                }
            }
//               2.2 pending state is equal to false
            else{
                print("collectionView pending state equal false")
//               2.21 check if the user has a confirmed events
                print("collectionView confirmedEventList.count \(confirmedEventList.count) firstWeekDayOfMonth \(firstWeekDayOfMonth)")
                if confirmedEventList[indexPath.item - firstWeekDayOfMonth + 1] != [nil]{
                    print("collectionView - event for this date")
                    cell.indicatorView1.backgroundColor = MyVariables.colourPlanrGreen
                    cell.indicatorView1.isHidden = false
                    cell.indicatorView21.isHidden = true
                    cell.indicatorView22.isHidden = true
                }
                else{
                    print("collectionView - no event for this date")
//                    hide all indicators
                    cell.indicatorView1.isHidden = true
                    cell.indicatorView21.isHidden = true
                    cell.indicatorView22.isHidden = true
                }
            }
            
//            3.change the colour of the cell based on whether the user choses that date
            if calcDate == selectedDate{
             cell.label.textColor = UIColor.white
             cell.backgroundColor = .white
             cell.label.backgroundColor = MyVariables.colourPlanrGreen
//             cell.backgroundColor = MyVariables.colourPlanrGreen
             cell.isHidden=false
             cell.isUserInteractionEnabled=true
             cell.label.text="\(calcDate)"
            }
            else{
//            else we set the cell to normal settings
            cell.isHidden=false
            cell.label.text="\(calcDate)"
            cell.label.backgroundColor = .white
            cell.backgroundColor = .white
            cell.isUserInteractionEnabled=true
            cell.label.textColor = UIColor.black
            }
            
        }
            return cell
            
        }
            
//            MARK: event collection view
        else if collectionView == collectionViewEvents{
            let cell = collectionViewEvents.dequeueReusableCell(withReuseIdentifier: cellId2, for: indexPath) as! NL_eventCollectionViewCell
            
//            setup the cell as rounded and with a border
            cell.layer.cornerRadius = 10
//            set the delegate for the invitee collectionViewController
            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: innerDelegate, forRow: indexPath.row)
            
//            populate the data for the event cells
//            a variable to hold the set of events we are going to use
             listOfEvents = [eventSearch?]()
            
//            1.set the events that will be displayed in the event viewer
            if pendingState == false && selectedDate == nil{
//                2.1 pending status is equal to false, we check which date the use has chosen in the calendar
            }
            else if pendingState == true && selectedDate == nil{
            }
            else if pendingState == false{
                listOfEvents = confirmedEventList[selectedDate! - 1]
            }
//                pending state must be equal to true
            else {
                if confirmedEventList[selectedDate! - 1] == [nil] && pendingEventList[selectedDate! - 1] == [nil] {
//                    no events to show
            }
//            if the confirmed events = nil, then we dont want ot include those
            else if confirmedEventList[selectedDate! - 1] == [nil] && pendingEventList[selectedDate! - 1] != [nil]{
                    listOfEvents = pendingEventList[selectedDate! - 1]
                }
//            if the pending events are equal to nil but the confirmed are not
            else if confirmedEventList[selectedDate! - 1] != [nil] && pendingEventList[selectedDate! - 1] == [nil]{
                         listOfEvents = confirmedEventList[selectedDate! - 1]
                        }
                else{
//                    both are not equal to nil, we combine the arrays
                listOfEvents = confirmedEventList[selectedDate! - 1] + pendingEventList[selectedDate! - 1]
                }
            }
//            set the cells information based on the row we are using
            let event = listOfEvents[indexPath.row]
                cell.lbleventTitle.text = event!.eventDescription
                cell.lbleventLocation.text = event!.eventLocation
                cell.lbleventTime.text = ("\(convertToLocalTime(inputTime: event!.eventStartTime)) - \(convertToLocalTime(inputTime:(event!.eventEndTime)))")
            
//            set the event image, check that we have an eventType currently listed in our event and present in the array of images
            //        pull down the image from core data
                let imageList = CoreDataCode().fetchEventImage(eventID: event!.eventID)
                    
            //        check if we got an image back
                    var image = Data()
                    if imageList.count != 0{
                        print("setupEventImage - imageList.count - image was returned")
                        image = imageList[0].eventImage!
                    }
            //        if we got an image then set it as the event image
                    if imageList.count != 0{
                        print("setupEventImage - setting the event image")
                        cell.eventImage.image = UIImage(data: image)
                    }
                    else{
            //            there was no image, so we use the stock image
                        if let index = eventTypeImages.userEventChoices.index(of: event!.eventType){
                                let imageName = eventTypeImages.userEventChoicesImagesColored[index]
                            cell.eventImage.image = UIImage(named: imageName)
                        }
                        else{
                            cell.eventImage.image = UIImage(named: "customColoredCode")
                            }
                    }
            
//          if the user has chosen the date we want to display that date in the time slot
        if event?.chosenDate != ""{
            cell.lblstatus.text = "Date Confirmed"
            cell.lblstatus.textColor = MyVariables.colourPlanrGreen
            cell.lblstatus.backgroundColor = MyVariables.colourSelected
//                convert the date into a display date DD MMM
            
            let day = dateTZToDay(date: event!.chosenDate)
            let dayNum = dateTZToDayNum(date: event!.chosenDate)
            let month = dateTZToMonth(date: event!.chosenDate)
            
//                create attributed string for the date
            let font = UIFont.systemFont(ofSize: 11)
            let attributes = [NSAttributedString.Key.font: font]
            let attributedQuote = NSMutableAttributedString(string: "\(String(day))\n", attributes: attributes)
                        
            let font2 = UIFont.systemFont(ofSize: 13)
            let attributes2 = [NSAttributedString.Key.font: font2]
            let attributedQuote2 = NSMutableAttributedString(string: "\(String(dayNum))\n", attributes: attributes2)
                        
            let font3 = UIFont.systemFont(ofSize: 11)
            let attributes3 = [NSAttributedString.Key.font: font3]
            let attributedQuote3 = NSMutableAttributedString(string: String(month), attributes: attributes3)
            
            attributedQuote.append(attributedQuote2)
            attributedQuote.append(attributedQuote3)
            
            
            cell.lbleventDate.attributedText = attributedQuote
            cell.lbleventDate.isHidden = false
            cell.lbleventTime.text = ("\(convertToLocalTime(inputTime: event!.eventStartTime)) - \(convertToLocalTime(inputTime:(event!.eventEndTime)))")
                        }
        else{
//            we need to check if every user has responded, this can be done, 1. there should be no non user names, 2.we need to loop through each user in the event and check if no every one has responded
            
//            tracking bool for a user not having responded
            var notResponded = false
            var declined = false
            
//            if there are any non users we want to show not responded
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
//                    check if the user is the current user and if they declined the event
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
        
//        what to do when the user selects a specific date
        if collectionView == collectionViewDates{
//         need to set the date selected as part of the seleceted array and then refresh the table
        
//            set the selected date
            selectedDate = indexPath.row-firstWeekDayOfMonth+2
            
//            reload the tables
            
            collectionViewDates.reloadData()
            collectionViewEvents.reloadData()
        }
        
        if collectionView == collectionViewEvents{
//            we set the currentSelected event and then push the eventView onto the screen
            
            currentUserSelectedEvent = listOfEvents[indexPath.row]!
            
//            set the availability for the event
            
            currentUserSelectedAvailability = serialiseAvailability(eventID: currentUserSelectedEvent.eventID)
            prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                
//                push the event card to the view
                if let popController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventController") as? NL_eventController{
                    
//                    var nav = UINavigationController(rootViewController: popController)
                    // set the presentation style
                    popController.modalPresentationStyle = UIModalPresentationStyle.popover

                    popController.popoverPresentationController?.delegate = self

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
        if collectionView == collectionViewDates{
        let wandH = CGFloat((screenWidth - 16*8)/7)
//            print("wandH of the cell \(wandH)")
        size = CGSize(width: wandH, height: wandH)
        }
        
        if collectionView == collectionViewEvents{
         size = CGSize(width: screenWidth - 32, height: 160)
            
        }
        
           return size
       }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
    
        
        if collectionView == collectionViewDates{
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        else if collectionView == collectionViewEvents{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

//    we set the minimum spacing to align with the spacing of the week days, spacing between items on the same row
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        var spacing = CGFloat()
        
        if collectionView == collectionViewDates{
            spacing = 16
        }
        else if collectionView == collectionViewEvents{
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
//        set to 1, to give some distance between the items when selected
        if collectionView == collectionViewDates{
            spacing = 1
        }
        
        
        return spacing
    }
    
}



//extension to be added to all tabbed viewControllers
extension NL_HomePage{
    
    
    @objc func openTabClicked1(){
     print("openTabClicked1 pressed")
        
  
     
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
        print("openTabClicked3 pressed")
        
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
     print("notifications pressed")
        
//            remove the invitee observer to not interfere with other pages
                    removeInviteeObserver()
        
        if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_NotificationsController") as? NL_NotificationsController {
           self.navigationController?.pushViewController(viewController, animated: false)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        }
     }
    
    @objc func openTabClicked5(){
     print("openTabClicked5 pressed")
        
//            remove the invitee observer to not interfere with other pages
                    removeInviteeObserver()
     
    if let viewController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventsViewController") as? NL_eventsViewController {
                self.navigationController?.pushViewController(viewController, animated: false)
                 self.navigationController?.setNavigationBarHidden(false, animated: false)
                 self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
             }
        
    }
}

//extenstion to handle the view will appear
extension NL_HomePage{
    override func viewDidAppear(_ animated: Bool) {
    //        MARK: here we run th code to check if the user opened the app from a notification and we determine which notification they opened it from and run the desired code for that page
            print("viewDidAppear is now running")
                
              let category = UserDefaults.standard.string(forKey: "notificationSent3") ?? ""
              print("category: \(category)")
              
              if category == "newMessage"{
                
                summaryView = false
                  
                  if eventIDChosen == ""{
                   print("eventIDChosen not set - aborting")
                      
                   UserDefaults.standard.set("", forKey: "notificationSent3")
                      
                  }
                  else{
                      print("segue to chat page")
        
                UserDefaults.standard.set("", forKey: "notificationSent3")
                    
//                we need to retrieve the event the user has just received a message for from CoreData
                    let predicate = NSPredicate(format: "eventID == %@", argumentArray: [eventIDChosen])
                    let filteredEvents = CoreDataCode().serialiseEvents(predicate: predicate, usePredicate: true)
                                    
                    if filteredEvents.count == 0{
                            print("something went wrong")
                        }
                    else{
                        currentUserSelectedEvent = filteredEvents[0]
//        push the chat page, we push this rather than pop to give the user a better experienc                                //        send the user to the edit chat page
            if let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatNavigation") as? UINavigationController{
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
            // present the popover
            self.present(popController, animated: true, completion: nil)
                        }
                    }
                  }
              }
              else if category == "newEvent"{
                summaryView = false
                
    //            we turn off the listeners, this ensures the code below functions correctly, we then turn the listeners back on at the event page
                if availabilityListenerRegistration != nil{ availabilityListenerRegistration.remove()
                     availabilityListenerEngaged = false
                    print("removing the event availability listener")
                }
                if eventListenerRegistration != nil{ eventListenerRegistration.remove()
                     eventListenerEngaged = false
                    print("removing the event event listener")
                }
                
                if eventIDChosen == ""{
                 print("eventIDChosen not set - aborting")
                 UserDefaults.standard.set("", forKey: "notificationSent3")
                }
                else{
    //            show the user a loading sign
//                    let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
//                    loadingNotification.label.text = "Loading event"
//                    loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
//                    loadingNotification.mode = MBProgressHUDMode.customView
                    
                    print("segue to event page")
                
                  UserDefaults.standard.set("", forKey: "notificationSent3")
                            
    //              retrieve the event data from CD
                            let predicate = NSPredicate(format: "eventID = %@", eventIDChosen)
                            let predicateReturned = self.serialiseEvents(predicate: predicate, usePredicate: true)
                            if predicateReturned.count == 0{
                                print("something went wrong we will check again")
                                
                                let seconds3 = 3.0
                                DispatchQueue.main.asyncAfter(deadline: .now() + seconds3) {
                                    
                                    let predicate = NSPredicate(format: "eventID = %@", eventIDChosen)
                                    let predicateReturned = self.serialiseEvents(predicate: predicate, usePredicate: true)
                                    if predicateReturned.count == 0{
                                        
//                                      loadingNotification.label.text = "We're having trouble loading the event, please try again later"
                                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds3){
//                                            loadingNotification.hide(animated: true)
                                        }
     
                                    }
                                    else{
                                    currentUserSelectedEvent = predicateReturned[0]
                                                                    
//                load the required availability
                                    currentUserSelectedAvailability = self.serialiseAvailability(eventID: eventIDChosen)
                                    self.prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
//                                set the userdefault back so that we don't interfere with other newer notifications
                                    UserDefaults.standard.set("", forKey: "notificationSent3")
                                    if let popController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventController") as? NL_eventController{
                                            
                        //                    var nav = UINavigationController(rootViewController: popController)
                                            // set the presentation style
                                            popController.modalPresentationStyle = UIModalPresentationStyle.popover

                        //                    popController.popoverPresentationController?.delegate = self

                                        // present the popover
                                            self.present(popController, animated: true, completion: nil)
                                        }}}}}
    //                            the first predicate returned the event
                            else{

                                currentUserSelectedEvent = predicateReturned[0]
                                
                                //                load the required availability
                                currentUserSelectedAvailability = self.serialiseAvailability(eventID: eventIDChosen)
                                self.prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                                //                 set the view controller as root
//                                    loadingNotification.hide(animated: true)
    //                                set the userdefault back so that we don't interfere with other newer notifications
                                    UserDefaults.standard.set("", forKey: "notificationSent3")
                                    if let popController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventController") as? NL_eventController{
                                            
                        //                    var nav = UINavigationController(rootViewController: popController)
                                            // set the presentation style
                                            popController.modalPresentationStyle = UIModalPresentationStyle.popover

                        //                    popController.popoverPresentationController?.delegate = self

                                        // present the popover
                                            self.present(popController, animated: true, completion: nil)
                                        }
                                                    
                                }}}}
                        
    //                }}}
    //            the app was not opened from a notification
              else{
                print("category not set for app opening")
                
                let createEventCoachMarksCount = UserDefaults.standard.integer(forKey: "createEventCoachMarksCount")
                let createEventCoachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
                
                print("coachmark test summaryView: \(summaryView) createEventCoachMarksCount: \(createEventCoachMarksCount) createEventCoachMarksPermenant: \(createEventCoachMarksPermenant)")

              }
    }
    
    
}


//extension for all the date logic required to popuate the arrys of events
extension NL_HomePage{
    
    func getEventsForMonth( completion: @escaping () -> Void){
        print("getEventsForMonth: currentMonthIndex \(currentMonthIndex) - countOfDates \(numOfDaysInMonth[currentMonthIndex-1])")
        //    set the dateformatter for the rest of the function
        let dateFormatterTZ = DateFormatter()
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        
//        MARK: 0. to start we prepare for the function
        pendingEventList.removeAll()
        confirmedEventList.removeAll()
//        create two empty arrays that we will populate with the events for each date of the current month.
        var emptyArrayPending = [[eventSearch?]](repeating: [nil], count: numOfDaysInMonth[currentMonthIndex-1])
        var emptyArrayConfirmed = [[eventSearch?]](repeating: [nil], count: numOfDaysInMonth[currentMonthIndex-1])

//       MARK: 1. get all events
        let predicate = NSPredicate(format: "eventID == %@", argumentArray: [eventIDChosen])
        let filteredEvents = AutoRespondHelper.serialiseEventsAuto(predicate: predicate, usePredicate: false)
        
//        MARK: 1.1 if there are no events returned, we need to set the empty arrays equal to the confirmed and pending events
        if filteredEvents.count == 0{
          pendingEventList = emptyArrayPending
          confirmedEventList = emptyArrayConfirmed
            completion()
        }
        else{
//        MARK: 2. loop through each event
        for event in filteredEvents{
//            print("getEventsForMonth - looping event \(event)")
//          2.1 check if the event has it's date chosen
            if event.chosenDate != ""{
                print("getEventsForMonth - date chosen for this event")
//                2.2 loop through each event to find those we want to see for the current month
                let eventDate = event.chosenDate
//                convert string to date
                let eventDateDate = dateFormatterTZ.date(from: eventDate)
//                compare the month and year to the current month the user is viewing
                let month = Calendar.current.component(.month, from: eventDateDate!)
                let year = Calendar.current.component(.year, from: eventDateDate!)
                print("getEventsForMonth - month \(month) year \(year) currentMonthIndex \(currentMonthIndex) currentYear \(currentYear)")
//                current year and month are stored in the index, check if the current event matches these indices
                if month == currentMonthIndex && year == currentYear{
//                 check to see if there is already an event in the array for this date =[nil]
                    print("getEventsForMonth is in this current month")
                    if emptyArrayConfirmed[event.chosenDateDay - 1] == [nil]{
//                        if an event doesnt exist we add the event to the array
                        emptyArrayConfirmed[event.chosenDateDay - 1] = [event]
                    }
                    else{
//                        if an event does exist, we need to create an array of both events and add this back to the event
                        var newArray = emptyArrayConfirmed[event.chosenDateDay - 1] as! [eventSearch]
//                        append the current event to the new array
                        newArray.append(event)
//                        set the confirmed array equal to the newarray at this index
                        emptyArrayConfirmed[event.chosenDateDay - 1] = newArray
                    }
                }
            }
//            MARK: 3 check all pending events and add them to the pending events array
            else{
//                3.1 loop through all of the potential dates for the event - we did this to ensure we can capture all dates the sure may have chosen (for when we implement any date chosen)
                for date in event.startDateArray{
//                convert string to date
                    let eventDateDate = dateFormatterTZ.date(from: date)
//                compare the month and year to the current month the user is viewing, we use the start date day to add the correct date to the calendar
                    let day = Calendar.current.component(.day, from: eventDateDate!)
                    let month = Calendar.current.component(.month, from: eventDateDate!)
                    let year = Calendar.current.component(.year, from: eventDateDate!)
//                current year and month are stored in the index, check if the current event matches these indices
                    if month == currentMonthIndex && year == currentYear{
//                 check to see if there is already an event in the array for this date =[nil]
                    if emptyArrayPending[day - 1] == [nil]{
//                        if an event doesnt exist we add the event to the array
                    emptyArrayPending[day - 1] = [event]
                                            }
                    else{
//                        if an event does exist, we need to create an array of both events and add this back to the event
                    var newArray = emptyArrayPending[day - 1] as! [eventSearch]
//                        append the current event to the new array
                    newArray.append(event)
//                        set the confirmed array equal to the newarray at this index
                    emptyArrayPending[day - 1] = newArray
                        }
                    }
                }
            }
            }
            //        we set the global event arrays equal to the empty arrays we populated
            pendingEventList = emptyArrayPending
            confirmedEventList = emptyArrayConfirmed
//            print("pendingEventList \(pendingEventList) confirmedEventList \(confirmedEventList)")
            completion()
        }
    }
}

class getRequestedEvents{
    
    func getRequestedEventsFunc(){
        
        
    }
    
}

//delegate for handling the collectionView within a collectionView
class InnerCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collectionViewCell invitees reloading")
        var numberOfRows = Int()
        var events = [eventSearch?]()

//        1. check to see if the user has selected a date
        if selectedDate == nil{
            print("collectionViewCell invitees reloading selectedDate = nil")
            numberOfRows = 0
        }
        else if pendingState == false{
//            set the number of rows based on the number of users invited to the event. We pass this information between the two controllers using the tag
//            events= all the events for the user selected date
        let events = confirmedEventList[selectedDate! - 1]
            print("collectionViewCell invitees reloading events = \(events)")
//            event = the event on that day
            let eventUsers = events[collectionView.tag]!.currentUserNames.count + events[collectionView.tag]!.nonUserNames.count
            print("collectionViewCell invitees reloading eventUsers = \(eventUsers)")
        numberOfRows = eventUsers
        print("collectionViewCell invitees reloading numberOfRows = \(numberOfRows)")
        }
        else if pendingState == true{
            if confirmedEventList[selectedDate! - 1] == [nil] && pendingEventList[selectedDate! - 1] == [nil] {
            //                    no events to show
                numberOfRows = 0
        }
//            if the confirmed events = nil, then we dont want ot include those
    else if confirmedEventList[selectedDate! - 1] == [nil] && pendingEventList[selectedDate! - 1] != [nil]{
            events = pendingEventList[selectedDate! - 1]
        }
//            if the pending events are equal to nil but the confirmed are not
    else if confirmedEventList[selectedDate! - 1] != [nil] && pendingEventList[selectedDate! - 1] == [nil]{
            events = confirmedEventList[selectedDate! - 1]
        }
        else{
//                    both are not equal to nil, we combine the arrays
            events = confirmedEventList[selectedDate! - 1] + pendingEventList[selectedDate! - 1]
                            }
            //            set the number of rows based on the number of users invited to the event. We pass this information between the two controllers using the tag
            let eventUsers = events[collectionView.tag]!.currentUserNames.count + events[collectionView.tag]!.nonUserNames.count
            print("collectionViewCell invitees reloading eventUsers = \(eventUsers)")
            numberOfRows = eventUsers
            print("collectionViewCell invitees reloading numberOfRows = \(numberOfRows)")
                        }
        return numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("cellForItemAt - pendingState \(pendingState)")
        
        let cellId2 = "cellId2"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId2, for: indexPath) as! NL_inviteesCell
        
        var allNames = [String]()
        var events = [eventSearch?]()
        var event = eventSearch()
        
//        1. check to see if the user has selected a date
                if selectedDate == nil{
                }
                else if pendingState == false{
//        1. get the list of all the events
                events = confirmedEventList[selectedDate! - 1]
//        1.1 get the current event
                event = events[collectionView.tag]!
//        1.2 we combine the current user and non user names
                allNames = event.currentUserNames + event.nonUserNames
                    print("event \(event) allNames \(allNames)")
                }
                else if pendingState == true{
                    if confirmedEventList[selectedDate! - 1] == [nil] && pendingEventList[selectedDate! - 1] == [nil] {
//                    no events to show
                    }
//            if the confirmed events = nil, then we dont want ot include those
                    else if confirmedEventList[selectedDate! - 1] == [nil] && pendingEventList[selectedDate! - 1] != [nil]{
                    events = pendingEventList[selectedDate! - 1]
                            }
//            if the pending events are equal to nil but the confirmed are not
                    else if confirmedEventList[selectedDate! - 1] != [nil] && pendingEventList[selectedDate! - 1] == [nil]{
                                events = confirmedEventList[selectedDate! - 1]
                            }
                    else{
//                    both are not equal to nil, we combine the arrays
                    events = confirmedEventList[selectedDate! - 1] + pendingEventList[selectedDate! - 1]
                        }
//        1.1 get the current event
                event = events[collectionView.tag]!
//        1.2 we combine the current user and non user names
                allNames = event.currentUserNames + event.nonUserNames
                }

//        1.3 set invitee names label
        let combinedNameList = allNames
        var combinedNameListSorted = [""]
        var combinedNameListOthers = [""]
        
//        we loop through the combined list of users and add the host to the combined list first
        for i in combinedNameList{
//            if the current user is the host add them to the combinedNameListSorted
            if i == event.eventOwnerName{
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
        
//        the person is a user
        print("cellFotItem event.currentUserNames.count \(event.currentUserNames.count)")
        if indexPath.row <= event.currentUserNames.count - 1{
//        we want to set the images for the event invitees
            let currentUserId = event.users[indexPath.row]
            
//                    we want to check if the user has responded and if not display the hourglass
            let availability = AutoRespondHelper.serialiseAvailabilitywUserAuto(eventID: event.eventID, userID: currentUserId)
            
// get the users image
            let imageList = CoreDataCode().fetchImage(uid: currentUserId)
            
            var image = Data()
            if imageList.count != 0{
                image = imageList[0].userImage!
            }
//                    loop through each possible user itteration and set the image and status accordingly
            
            print("cellForItem availability.count \(availability.count) indexPath.row \(indexPath.row)")
                        
//                    1. the user doesnt have an availability, we show them as not responded
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
            else if availability.count != 0{
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
//                2.4 the user has not responded and they do not have a picture
                else if userAvailabilityArray[0] == 11 ||  userAvailabilityArray[0] == 99 && imageList.count == 0{
                    cell.inviteeStatus.isHidden = false
                    cell.inviteeStatus.image = UIImage(named: "hourGlassCodeCircle")
                    cell.inviteePicture.image = .none
                    cell.inviteePicture.isHidden = false
                    cell.eventImageView.isHidden = true
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
            print("cellForItem - no availability - invite the user")
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

        cell.lblInviteeName.text = allNames[indexPath.row]
        
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
        
        var allNames = [String]()
        var events = [eventSearch?]()
        var event = eventSearch()
        
//        we need to determine which user was selected
        //        1. check to see if the user has selected a date
                        if selectedDate == nil{
                        }
                        else if pendingState == false{
        //        1. get the list of all the events
                        let events = confirmedEventList[selectedDate! - 1]
        //        1.1 get the current event
                    guard let event = events[collectionView.tag] else{
                        CoreDataCode().somethingWentWrong(eventID: "", eventInfo: false, availabilityInfo: false, loginfo: "The user tried to select an event that didnt exist", viewController: NL_HomePage.init())
                        
                        return
                            }
        //        1.2 we combine the current user and non user names
                        allNames = event.currentUserNames + event.nonUserNames
                        }
                        else if pendingState == true{
                            if confirmedEventList[selectedDate! - 1] == [nil] && pendingEventList[selectedDate! - 1] == [nil] {
        //                    no events to show
                            }
        //            if the confirmed events = nil, then we dont want ot include those
                            else if confirmedEventList[selectedDate! - 1] == [nil] && pendingEventList[selectedDate! - 1] != [nil]{
                            events = pendingEventList[selectedDate! - 1]
                                    }
        //            if the pending events are equal to nil but the confirmed are not
                            else if confirmedEventList[selectedDate! - 1] != [nil] && pendingEventList[selectedDate! - 1] == [nil]{
                                        events = confirmedEventList[selectedDate! - 1]
                                    }
                            else{
        //                    both are not equal to nil, we combine the arrays
                            events = confirmedEventList[selectedDate! - 1] + pendingEventList[selectedDate! - 1]
                                }
        //        1.1 get the current event
                        event = events[collectionView.tag]!
        //        1.2 we combine the current user and non user names
                        allNames = event.currentUserNames + event.nonUserNames
                        }
        
//        we only want to alow the user to perform an action if it is thier event
        if event.eventOwnerID == user{
//            if they tap on themselves we dont do anything
            if indexPath.row == 0{
                
            }
            else{
//        check if the selected user wasnt a user
        if indexPath.row >= event.currentUserNames.count{
//            we can't present the notification from the inner delegate, hence we post a notification that is being monitored by the page and will post a notification. we pass the eventId through the userInfo tag.
            
            let inviteeDict:[String: String] = ["eventID": event.eventID]
            NotificationCenter.default.post(name: .inviteSelected, object: nil, userInfo: inviteeDict)
        }
        else{
            let userID = event.users[indexPath.row]
            let userName = event.currentUserNames[indexPath.row]
            let eventID = event.eventID
            let reminderDict:[String: String] = ["userID": userID, "userName": userName, "eventID": eventID]
            NotificationCenter.default.post(name: .reminderSelected, object: nil, userInfo: reminderDict)
            
        }
    }
    }
    }
}


//set notification names for the tutorial closing
extension Notification.Name {
     static let tutorialClosed = Notification.Name("tutorialClosed")
}


