//
//  NL_createEventSummary.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/21/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD


var newEventCreated = Bool()

class NL_createEventSummary: UIViewController{
    
    
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
    
    public var barHeight : CGFloat{
         get{
             if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                 return 0
             }else{
                let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
                let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                print("statusBarHeight \(statusBarHeight) barHeight \(barHeight)")
                return barHeight
             }
         }
    }
//    variable to describe the time, in seconds, from GMT of the user
    var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
    
//    my variables
    var collectionviewDaysOfTheWeek: UICollectionView!
     let cellId2 = "cellId3"
    var collectionViewDates: UICollectionView!
    let cellId = "cellId"
    var tableViewContacts: UITableView!
    var fireStoreRef: DocumentReference? = nil
    
    
    var userIDArray = Array<String>()
    
        override func viewDidLoad() {
            
//        this stops the viewcontroller from being dismissed when the user swipes down
                    if #available(iOS 13.0, *) {
                        self.isModalInPresentation = true
                    } else {
                        // Fallback on earlier versions
                    }
            
        super.viewDidLoad()
            setupThePage()
            createNextButton()
    //        MUST ADD subview
            view.addSubview(inputTopView)
            view.addSubview(inputBottomView)
            

            // Set its constraint to display it on screen
                    inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                    inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: barHeight).isActive = true
                    inputTopView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
                    inputTopView.heightAnchor.constraint(equalToConstant: 80).isActive = true
                    
            //        setup view for collectionView
                    inputBottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                    inputBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                    inputBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
                    inputBottomView.topAnchor.constraint(equalTo: view.topAnchor, constant: barHeight + 100).isActive = true
        }
        
       
        
        func setupThePage(){
            
    //        set the title for the page
        let title = "Create Event"
        self.title = title
            
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = MyVariables.colourPlanrGreen
        navigationItem.backBarButtonItem = backItem
        }
    
    
    //    create the progress bar and title
        lazy var inputTopView: UIView = {
            print("setting up the inputTopView")
    //        set the variables for the setup
            let progressAmt = 0.98
            let headerLabelText = "Event Summary"
            let numberLabelText = "04"
            let instructionLabelText = "Confirm your event details"
         
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
            
            
            //        setup the progress bar
            let progressBar = UIProgressView(progressViewStyle: .default)
            progressBar.progress = Float(progressAmt)
            progressBar.center = view.center
            progressBar.progressTintColor = MyVariables.colourPlanrGreen
            progressBar.backgroundColor = MyVariables.colourBackground
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            progressBar.layer.sublayers![1].cornerRadius = 4
            progressBar.subviews[1].clipsToBounds = true
            topView.addSubview(progressBar)
            progressBar.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive = true
            progressBar.topAnchor.constraint(equalTo: topView.topAnchor, constant: 0).isActive
             = true
            progressBar.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
            progressBar.heightAnchor.constraint(equalToConstant: 8).isActive = true
            
            //        setup the item label
            let numberLabel = UILabel()
            numberLabel.text = numberLabelText
            numberLabel.font = UIFont.systemFont(ofSize: 14)
            numberLabel.textColor = MyVariables.colourLight
            numberLabel.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(numberLabel)
            numberLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 16).isActive = true
            numberLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
            numberLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
            numberLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            //        setup the item label
            let headerLabel = UILabel()
            headerLabel.text = headerLabelText
            headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(headerLabel)
            headerLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 16 + 30).isActive = true
            headerLabel.widthAnchor.constraint(equalToConstant: screenWidth - 30 - 16).isActive = true
            headerLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
            headerLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
    //        set the instruction
            let instructionLabel = UILabel()
            instructionLabel.text = instructionLabelText
            instructionLabel.font = UIFont.systemFont(ofSize: 14)
            instructionLabel.textColor = MyVariables.colourLight
            instructionLabel.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(instructionLabel)
            instructionLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 16 + 30).isActive = true
            instructionLabel.widthAnchor.constraint(equalToConstant: screenWidth - 30 - 16).isActive = true
            instructionLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40).isActive = true
            instructionLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            return containerView
        }()
        
    //    setup the view of the collectionview
        
        
        lazy var inputBottomView: UIView = {
            print("screenHeight - topDistance - 100 \(screenHeight - topDistance - 100)")
          
            let leftSideInset = 46
            let rightSideInset = CGFloat(16)
            let labelHeight = 30
            let imgSize = 75
            let imgLocationSize = 18
            let imgCalendarSize = 25
            let collectionViewDatesHeight = 80
            
            //   setup the view for holding the progress bar and title
            let containerView2 = UIView()
            containerView2.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: screenHeight - topDistance - 50)
            containerView2.backgroundColor = UIColor.white
            containerView2.translatesAutoresizingMaskIntoConstraints = false
            
            //        trying to add a top view
            let topView = UIView()
            topView.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: screenHeight - topDistance - 50)
            topView.backgroundColor = UIColor.white
            topView.translatesAutoresizingMaskIntoConstraints = false
            containerView2.addSubview(topView)
            topView.leftAnchor.constraint(equalTo: containerView2.leftAnchor).isActive = true
            topView.topAnchor.constraint(equalTo: containerView2.topAnchor).isActive = true
            topView.widthAnchor.constraint(equalTo: containerView2.widthAnchor).isActive = true
            topView.heightAnchor.constraint(equalToConstant: screenHeight - topDistance - 50).isActive = true
            
            
//        add the event type image
            let imgEventType = UIImageView()
            imgEventType.image = UIImage(named: eventTypeImages.userEventChoicesimages[eventTypeInt])
            imgEventType.translatesAutoresizingMaskIntoConstraints = false
            imgEventType.layer.masksToBounds = true
            imgEventType.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
            imgEventType.layer.borderWidth = 3
            imgEventType.layer.cornerRadius = 8
            topView.addSubview(imgEventType)
            imgEventType.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(leftSideInset)).isActive = true
            imgEventType.widthAnchor.constraint(equalToConstant: CGFloat(imgSize)).isActive = true
            imgEventType.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
            imgEventType.heightAnchor.constraint(equalToConstant: CGFloat(imgSize)).isActive = true
            
//            event title
            let lblTitle = UILabel()
//            lblTitle.text = newEventDescription
            lblTitle.text = newEventDescription
            lblTitle.font = UIFont.boldSystemFont(ofSize: 18)
            lblTitle.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(lblTitle)
            lblTitle.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(imgSize)).isActive = true
            lblTitle.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(leftSideInset)).isActive = true
            lblTitle.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth) - CGFloat(leftSideInset) - rightSideInset).isActive = true
            lblTitle.heightAnchor.constraint(equalToConstant: CGFloat(labelHeight)).isActive = true
            
//            event location
            let lblLocation = UILabel()
//            lblLocation.text = newEventLocation
            lblLocation.text = newEventLocation
            lblLocation.textColor = MyVariables.colourLight
            lblLocation.font = UIFont.systemFont(ofSize: 15)
            lblLocation.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(lblLocation)
            lblLocation.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(imgSize) + CGFloat(labelHeight)).isActive = true
            lblLocation.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(leftSideInset) + CGFloat(imgLocationSize) + 10).isActive = true
            lblLocation.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth) - CGFloat(leftSideInset) - CGFloat(imgLocationSize) - rightSideInset).isActive = true
            lblLocation.heightAnchor.constraint(equalToConstant: CGFloat(labelHeight)).isActive = true
            
            //            event location image
            let imgLocation = UIImageView()
            imgLocation.translatesAutoresizingMaskIntoConstraints = false
            imgLocation.image = UIImage(named: "LocationSelectedCode")
            topView.addSubview(imgLocation)
            imgLocation.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(Double(imgSize)) + CGFloat(labelHeight) + 0.35*CGFloat(imgLocationSize)).isActive = true
            imgLocation.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(leftSideInset)).isActive = true
            imgLocation.widthAnchor.constraint(equalToConstant: CGFloat(imgLocationSize-4)).isActive = true
            imgLocation.heightAnchor.constraint(equalToConstant: CGFloat(imgLocationSize)).isActive = true
            
            
            //            event search period image
//            let imgCalendar = UIImageView()
//            imgCalendar.translatesAutoresizingMaskIntoConstraints = false
//            imgCalendar.image = UIImage(named: "CalendarSelectedCode")
//            topView.addSubview(imgCalendar)
//            imgCalendar.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(imgSize) + CGFloat(labelHeight*2)).isActive = true
//            imgCalendar.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(leftSideInset)).isActive = true
//            imgCalendar.widthAnchor.constraint(equalToConstant: CGFloat(imgCalendarSize)).isActive = true
//            imgCalendar.heightAnchor.constraint(equalToConstant: CGFloat(imgCalendarSize)).isActive = true
            
            
//            add search period collectionView
                    let layout3: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                    layout3.scrollDirection = .horizontal
            //        layout3.sectionHeadersPinToVisibleBounds = true
                    collectionViewDates = UICollectionView(frame: .zero, collectionViewLayout: layout3)
                    collectionViewDates.translatesAutoresizingMaskIntoConstraints = false
                    collectionViewDates.delegate = self
                    collectionViewDates.dataSource = self
                    collectionViewDates.backgroundColor = .white
                    collectionViewDates.register(createEventDatesCell.self, forCellWithReuseIdentifier: cellId)
                    collectionViewDates.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
                    collectionViewDates.isScrollEnabled = true
                    collectionViewDates.isUserInteractionEnabled = true
                    collectionViewDates.allowsSelection = true
                    collectionViewDates.allowsMultipleSelection = false
                    topView.addSubview(collectionViewDates)
                    collectionViewDates.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(leftSideInset)).isActive = true
                    collectionViewDates.widthAnchor.constraint(equalToConstant: CGFloat(CGFloat(Int(screenWidth)) - CGFloat(leftSideInset) - rightSideInset)).isActive = true
                    collectionViewDates.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(imgSize) + CGFloat(labelHeight*3)).isActive = true
                    collectionViewDates.heightAnchor.constraint(equalToConstant: CGFloat(collectionViewDatesHeight)).isActive = true
            
            
            //            event title
            let lblTime = UILabel()
            //            lblTitle.text = newEventDescription
            
           
            
            lblTime.text = ("\( convertToLocalTime(inputTime: newEventStartTime)) - \( convertToLocalTime(inputTime: newEventEndTime))")
            lblTime.font = UIFont.boldSystemFont(ofSize: 18)
            lblTime.textColor = .white
            lblTime.backgroundColor = MyVariables.colourPlanrGreen
            lblTime.textAlignment = .center
            lblTime.layer.cornerRadius = 3
            lblTime.layer.masksToBounds = true
            lblTime.translatesAutoresizingMaskIntoConstraints = false
                        topView.addSubview(lblTime)
            lblTime.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(imgSize) + CGFloat(labelHeight*2)).isActive = true
            lblTime.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(leftSideInset)).isActive = true
            lblTime.widthAnchor.constraint(equalToConstant: 120).isActive = true
            lblTitle.heightAnchor.constraint(equalToConstant: CGFloat(labelHeight)).isActive = true
            
//            tableView to display the selected contacts
            tableViewContacts = UITableView(frame: .zero)
            tableViewContacts.translatesAutoresizingMaskIntoConstraints = false
            tableViewContacts.delegate = self
            tableViewContacts.dataSource = self
            tableViewContacts.register(NL_contactTableViewCell.self, forCellReuseIdentifier: cellId)
            tableViewContacts.backgroundColor = .white
            tableViewContacts.isScrollEnabled = true
            tableViewContacts.rowHeight = 70
            tableViewContacts.separatorStyle = .none
            tableViewContacts.separatorColor = MyVariables.colourPlanrGreen
            tableViewContacts.isUserInteractionEnabled = true
            tableViewContacts.allowsSelection = true
            tableViewContacts.allowsMultipleSelection = false
            topView.addSubview(tableViewContacts)
            tableViewContacts.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(leftSideInset)).isActive = true
            tableViewContacts.widthAnchor.constraint(equalToConstant: CGFloat(CGFloat(Int(screenWidth)) - CGFloat(leftSideInset) - rightSideInset)).isActive = true
            tableViewContacts.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(imgSize) + CGFloat(Double(labelHeight)*3.5) + CGFloat(collectionViewDatesHeight)).isActive = true
            tableViewContacts.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
            
            
            
            
            return containerView2
        }()
    
//    create the next button
    func createNextButton(){
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createTapped))
            navigationItem.rightBarButtonItem?.tintColor = MyVariables.colourPlanrGreen
        }
//    function to create the event, once the user taps the button
    @objc func createTapped(){
        print("create event tapped")
        
        //        allows the user to choose the date for the event
                selectEventToggle = 1
                
        //        set summaryView = false, this is used as an override to the prepareForEventDetailsPageCD function, because the implementation of the auto update results page to new events caused the update of summaryView through through the `prepareForEventDetailsPageCD function ot crash
                
                summaryView = true
        
        
        //       start to show the event loading notification - ADD
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Creating event!"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
            loadingNotification.mode = MBProgressHUDMode.customView
        

        //        add the new event to the event store, add each users userEventStore and add the data to coreData
                addEventToEventStore(){ (eventID) in
                    
//                    log an event with Firebase
                    Analytics.logEvent(firebaseEvents.eventCreated, parameters: ["eventID" : eventID])
                    
        //            adds the current users availability to the userEventStore
                    AutoRespondHelper.uploadCurrentUsersAvailabilityAuto(eventID: eventID)
                    
        //            set the current selected event to the one just created and added to CoreData
                    currentUserSelectedEvent = self.serialiseEvents(predicate: NSPredicate(format: "eventID == %@", eventID), usePredicate: true)[0]
                    self.prepareForEventDetailsPageCD(segueName: "", isSummaryView: true, performSegue: false, userAvailability:  self.serialiseAvailability(eventID: currentUserSelectedEvent.eventID), triggerNotification: true) {
                        print("event has now been created, we dismiss the popup and take the user to the new event")
//                    we present the event popover from the viewcontroller currently being presented and not the one we just dismiss, first we get the viewcontroller bieng presented as pvc
                        weak var pvc = self.presentingViewController
                        self.presentingViewController?.dismiss(animated: true) {
                            print("the dismiss was run")
//                            we want to show the new event
                            
//            we need to get the event data and serialise it as the current event
                let predicate = NSPredicate(format: "eventID = %@", eventID)
                let predicateReturned = self.serialiseEvents(predicate: predicate, usePredicate: true)
                if predicateReturned.count == 0{
                print("something went wrong")
                    }
                else{
            currentUserSelectedEvent = predicateReturned[0]
                    print("we found the newly created event")
                    
//                    set the variable to true so the app shows the tutorial for a newly created event
                    newEventCreated = true
                                                    
            //            set the availability for the event
                    currentUserSelectedAvailability = self.serialiseAvailability(eventID: eventID)
                    self.prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                        
//                        we remove the arrays containing the dates, so they are clear next time we open the pages
                        calendarArray2.removeAll()
                        calendarTitleArray.removeAll()
                        
                        loadingNotification.hide(animated: true)
                        
                        print("we found the newly created event availability")
//                push the event card to the view
                if let popController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventController") as? NL_eventController{
                              print("the event controller was found")
//                    var nav = UINavigationController(rootViewController: popController)
                            // set the presentation style
                        popController.modalPresentationStyle = UIModalPresentationStyle.popover
//                    popController.popoverPresentationController?.delegate = self
                    

                    // present the popover
                    pvc?.present(popController, animated: true){
                        print("the event controller was presented")
                        }
                    }
                }
                    }}}}
    }
    
    
    func addEventToEventStore(completion: @escaping (_ eventID: String) -> Void){
        print("running func addEventToEventStore")
        Crashlytics.crashlytics().log("running func addEventToEventStore")
                notExistingUserArray.removeAll()
                var selectedPhoneNumbers = [String]()
                var selectedNames = [String]()
                let currentUserID = Auth.auth().currentUser?.uid
                let eventOwnerName = UserDefaults.standard.string(forKey: "name")
            

            guard let currentUseID = Auth.auth().currentUser?.uid else{
                print("addEventToEventStore user didnt have a user ID")
                Crashlytics.crashlytics().log("addEventToEventStore user didnt have a user ID")
                //       start message that we have an issue - ADDD
   
                
                return
            }

                eventQuery { (eventID,startDates,endDates) in
                    print("event commited to the database")
                    print("eventID: \(eventID)")
                    Crashlytics.crashlytics().log("event commited to the database eventID: \(eventID)")
                    
                    eventIDChosen = eventID
                    
                    self.getSelectedContactsPhoneNumbers2{ (selectedPhoneNumbers,selectedNames) in
                        print("getSelectedContactsPhoneNumbers2 complete selectedPhoneNumbers \(selectedPhoneNumbers), selectedNames \(selectedNames)")
                
                
                self.createUserIDArrays(phoneNumbers: selectedPhoneNumbers, names: selectedNames) { (nonExistentArray, existentArray, userNameArray, nonExistentNameArray) in
                    
                    print("nonExistentArray \(nonExistentArray)")
                    print("existentArray \(existentArray)")
                    
                    Crashlytics.crashlytics().log("existentArray \(existentArray) nonExistentArray \(nonExistentArray)")
                    
                    //           adds the non users to the database
                    self.addNonExistingUsers2(phoneNumbers: nonExistentArray, eventID: eventID, names: nonExistentNameArray)
                    
                    //            Adds the user event link to the userEventStore
                    
                    self.userEventLinkArray(userID: existentArray + [currentUserID!], userName: userNameArray + [eventOwnerName ?? ""], eventID: eventID){
                    
                    self.addUserIDsToEventRequests(userIDs: existentArray, currentUserID: [currentUserID!], existingUserIDs: [], eventID: eventID, addCurrentUser: true, currentUserNames: [eventOwnerName ?? ""] + userNameArray, nonUserNames: nonExistentNameArray)
                    
    //                Add a notification to the notificaiton table for each user invited to the event
                    self.eventCreatedNotification(userIDs: existentArray, eventID: eventID)
                    
    //                add event to this users CoreData, this allows us to show the results page immediately
                        self.commitSingleEventDB(chosenDate: "", chosenDateDay: 999, chosenDateMonth: 999, chosenDatePosition: 999, chosenDateYear: 999, daysOfTheWeek: daysOfTheWeekNewEvent, endDates: endDates, endTimeInput: newEventEndTime, endDateInput: newEventEndDate, eventDescription: newEventDescription, eventID: eventID, eventOwner: user!, eventOwnerName: eventOwnerName ?? "", isAllDay: "0", location: newEventLocation, locationLatitue: newEventLatitude, locationLongitude: newEventLongitude, startDates: startDates, startDateInput: newEventStartDate, startTimeInput: newEventStartTime, currentUserNames: [eventOwnerName ?? ""] + userNameArray, nonUserNames: nonExistentNameArray, users: [user!] + existentArray, eventType: eventType)
                    
    //                    we need to set the currentUserSelectedEvent
                        
                        //        1. retrieve the event data, eventSearch
                        let predicate = NSPredicate(format: "eventID = %@", eventID)
                        let predicateReturned = self.serialiseEvents(predicate: predicate, usePredicate: true)
                        if predicateReturned.count != 0{
                            print("predicateReturned wasn't nul")
                            currentUserSelectedEvent = predicateReturned[0]
                        }
                        
    //              we need to back to the main queue to show the progress HUD and alert
                    DispatchQueue.main.async {
                    
                    if nonExistentArray.isEmpty == false{
                    print("there are some invitees that arent users")
                        Crashlytics.crashlytics().log("there are some invitees that arent users")
                        nonExistingUsers = nonExistentNameArray
                        nonExistingNumbers = nonExistentArray
                        contactsSelected.removeAll()
                        inviteesNamesNew.removeAll()
                        contactsSorted.removeAll()
                        contactsFiltered.removeAll()
                        print("addEventToEventStore completion \(eventID)")
                        completion(eventID)
                    }
                    else{
                        print("there are no invitees that arent users")
                        Crashlytics.crashlytics().log("there are no invitees that arent users")
                            contactsSelected.removeAll()
                            inviteesNamesNew.removeAll()
                            contactsSorted.removeAll()
                            contactsFiltered.removeAll()
                        print("addEventToEventStore completion \(eventID)")
                        completion(eventID)
                    }}}}
                }
                }
            }
    
    
       //    Adds the new event into the evetRequests table
     func eventQuery( completion: @escaping (_ eventID: String, _ startDates: [String], _ endDates: [String]) -> Void){
             
             let timestamp = NSDate().timeIntervalSince1970
             let eventOwnerName = UserDefaults.standard.string(forKey: "name")
                 
        let eventSearchArray: [String:Any] = ["startDateInput": newEventStartDate,"endDateInput": newEventEndDate,"startTimeInput": newEventStartTime,"endTimeInput": newEventEndTime,"daysOfTheWeek": daysOfTheWeekNewEvent,"isAllDay": "0","users": self.userIDArray, "eventOwner": user, "location": newEventLocation, "eventDescription": newEventDescription, "timeStamp": timestamp, "eventOwnerName":  eventOwnerName ?? "", "secondsFromGMT": self.secondsFromGMT/3600, "startDates": startDatesNewEvent, "endDates": endDatesNewEvent, "locationLongitude": newEventLongitude, "locationLatitude": newEventLatitude, "eventType": eventType]
                 
                 print("days of the week eventQuery \(daysOfTheWeek)")
                 
                 self.fireStoreRef = dbStore.collection("eventRequests").addDocument(data: eventSearchArray as [String : Any]){
                     error in
                     if let error = error {
                         print("Error adding document: \(error)")
                     } else {
                         //                print("Document added with ID: \(ref!.documentID)")
                         
                         
                     }
                     
                     eventCreationID  = self.fireStoreRef!.documentID
                     
                     print("userIDArray: \(self.userIDArray)")
                     
                     let ref = Database.database().reference().child("events").child(eventCreationID)
                     ref.child("eventDescription").setValue(newEventDescription)
                     ref.child("eventOwnerName").setValue(eventOwnerName ?? "")
                     ref.child("eventOwnerID").setValue(user)
                     ref.child("invitedUsers").setValue(self.userIDArray)
                     
                     print("eventID from eventQuery \(eventCreationID)")
                     completion(eventCreationID,startDatesNewEvent,endDatesNewEvent)
                     
             }
    
         }
    
    
}

// setup the collectionView
extension NL_createEventSummary: UICollectionViewDelegate, UICollectionViewDataSource {
    
//    we only have one section in each collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var numberOfItems = Int()
        
        if collectionView == collectionViewDates{
            if startDatesChosen.count == 0{
                collectionView.setEmptyMessage(message: "Select search period:", messageAlignment: .left)
                numberOfItems = startDatesChosen.count
            }
            else{
//                reset the background image
                collectionView.restore()
                numberOfItems = startDatesChosen.count
            }
            return numberOfItems
        }
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = UICollectionViewCell()
//    date fromatter used for the end time > start time checks
        var dateFormatterTZ = DateFormatter()
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
    
//        setup the cell for the dates view
        if collectionView == collectionViewDates{
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! createEventDatesCell
           
//            setup the cell look
            cell.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            
//           we need to convert the start dates into a format we can display
            let dateIndex = startDatesChosen[indexPath.row]
            let dateIndexDate = dateFormatterTZ.date(from: dateIndex)
            let month = dateIndexDate!.get(.month)
            let day = dateIndexDate!.get(.weekday)
            let dayInt = dateIndexDate!.get(.day)
            
//            arrays to convert the dates into strings
            let monthArray = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
            let weekDays = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
            
            cell.monthText.text = ("\(monthArray[month])")
            cell.monthText.textColor = MyVariables.colourLight
            cell.monthText.font = UIFont.systemFont(ofSize: 13)
            
            cell.dayText.text = ("\(dayInt)")
            cell.dayText.font = UIFont.systemFont(ofSize: 20)
            
            cell.dowText.text = ("\(weekDays[day-1])")
            cell.dowText.textColor = MyVariables.colourLight
            cell.dowText.font = UIFont.systemFont(ofSize: 13)
            
            return cell
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewDates{
            print("user selected a date - we do nothing")
        }
    }
}

// setup the collectionView layout

extension NL_createEventSummary: UICollectionViewDelegateFlowLayout {
    
    
    // sets the size of the cell based on the collectionView
    func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize()
        
         if collectionView == collectionViewDates{
            size = CGSize(width: 80, height: 80)
        }
           return size
       }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == collectionViewDates{
            if kind == UICollectionView.elementKindSectionHeader {
         let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeader
                
//                if the user hasnt made a selection, we dont want to show anything
                if startDatesChosen.count == 0{
                   sectionHeader.label.text = ""
                }
                else{
                    sectionHeader.label.text = ("\(startDatesChosen.count) Options")}
                
         return sectionHeader
    } else { print("this wasnt a collectionView header kind - \(kind)")
         return UICollectionReusableView()
            }}
         return UICollectionReusableView()
    }
    
//    defines the size of the header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView == collectionViewDates{
        
        return CGSize(width: 80, height: 30)
        }
        else{
            return CGSize(width: 0, height: 0)
        }
    }
    
}

//extension for the collectionview containing the event choices
extension NL_createEventSummary: UITableViewDataSource, UITableViewDelegate {
    
//    set the number of sections in the tableView, we have two, one for the users selected the other for the other users in the users contacts
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return contactsSelected.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! NL_contactTableViewCell
         let contact: contactList
        
//        we dont want the cell to be highlighted when the user selects it
        cell.selectionStyle = .none
        contact = contactsSelected[indexPath.row]
        cell.cellText.text = contact.name
        cell.addImageView.image = UIImage(named: "deleteCode")
    
        return cell
    }
    
//    build a view for the display of the tableView header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let lbl = UILabel()
        let lblCount = UILabel()
        view.backgroundColor = .white
        view.addSubview(lbl)
        view.addSubview(lblCount)
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        lbl.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        lbl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60).isActive = true
        lbl.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lblCount.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        lblCount.widthAnchor.constraint(equalToConstant: 60).isActive = true
        lblCount.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        lblCount.translatesAutoresizingMaskIntoConstraints = false
        lblCount.textColor = MyVariables.colourLight
        lblCount.textAlignment = .center
        
        //        create a separator line
        let separatorLine = UIView()
        separatorLine.backgroundColor = MyVariables.colourPlanrGreen
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorLine)
        separatorLine.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth))).isActive = true
        separatorLine.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: CGFloat(1)).isActive = true
        
//        set the header text based on the section
        lbl.text =  "Selected Contacts"
        lblCount.text = ("(\(contactsSelected.count))")

        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        the user has selected from their selected users
//            add the contact back to the other two lists
            contactsFiltered.append(contactsSelected[indexPath.row])
            contactsSorted.append(contactsSelected[indexPath.row])
//            remove the user from the selected list
            contactsSelected.remove(at: indexPath.row)

//        deselect the row and refresh the table
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}
