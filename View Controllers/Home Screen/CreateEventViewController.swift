//
//  CreateEventViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 24/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import DLRadioButton
import MBProgressHUD
import Firebase
import EventKit
import AMPopTip
import Alamofire
import Fabric
import Crashlytics
import Instructions
import CoreData




//Gloabl variables available to any viewController
var settings = dbStore.settings
var dbStore = Firestore.firestore()
var userEventList = [eventSearch]()
var userEventListSorted = [eventSearch]()
var userInvitedEventList = [eventSearch]()
var userInvitedEventListSorted = [eventSearch]()
var anyArray = [[Any]]()
var eventResultsArrayDetails = [[Any]]()
var notExistingUserArray = [String]()
var selectEventToggle = 1
var daysOfTheWeek = [Int]()
var daysOfTheWeekNewEvent = [Int]()
var user = Auth.auth().currentUser?.uid
var calendars: [EKCalendar]?
var eventStore = EKEventStore()
var calendarArray = [EKEvent]()
var calendarEventArray : [Event] = [Event]()
var numberOfItems = 1
var selectedContactNames = [String]()
var datesToChooseFrom = Array<Any>()
var countedResultArrayFraction = [Float]()
var currentUserAvailabilityDocID = String()



// Screen width.
public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}



class CreateEventViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    
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

//    variables for setting menu items and segues
    var menuLabels = [["Create An Event","Pending Events"],["Confirmed Events","Your Planr"]]
    var chatNotification = [["","chatNotificationPending"],["chatNotificationDateChosen",""]]
    var pictureNames = [["PlusCircleCloud","Person"],["Meeting","icons8-planner-500"],["Camera",""]]
    var segueIdentifiers = [["createEventSegue","viewYourCreatedEventsSegue"],["userInvitedEventsSegue","planrSegue"],["",""]]
    
    
//    date format variables
    var dateFormatterForResultsCreateEvent = DateFormatter()
    var dateFormatterTime = DateFormatter()
    var dateFormatterSimple = DateFormatter()
    var dateFormatterTZ = DateFormatter()
    
//    other variables
    var newEventID = String()
    var startDate = Date()
    var endDate = Date()
    var startDateEnd = Date()
    var startEndDate = Date()
    var datesBetweenChosenDatesStart = Array<Date>()
    var datesBetweenChosenDatesEnd = Array<Date>()
    var datesOfTheEvents = Array<Date>()
    var startDatesOfTheEvents = Array<Date>()
    var endDatesOfTheEvents = Array<Date>()
    var finalAvailabilityArray = Array<Int>()
    var userEventStoreID = String()
    var fireStoreRef: DatabaseReference!
    var daysEvents = [PlanrEventStruct]()
    let coachMarksController = CoachMarksController()
    var todaysEventsSearch = [eventSearch]()
   
    @IBOutlet var collectionViewMenu: UICollectionView!
    
    @IBOutlet weak var testTheCodeButton: UIButton!
    
    
    @IBOutlet weak var introText: UILabel!
    
    @IBOutlet weak var lblTodaysEvents: UILabel!

    
    @IBOutlet weak var tblViewEventList: UITableView!
    
    
    
    @IBAction func testTheCode(_ sender: UIButton) {

        
        
    }
    
    
    //    variable for refreshing the UITableViews on pull down
    var refreshControlCreated = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//      check that the user is in our user database, or log them out
        checkUserInUserDatabase()
        checkCalendarStatus2()
        navigationItem.titleView = setAppHeader(colour: UIColor.black)
        
//        check we have data in core data and update if required
        CDAppHasLoaded{
//            completed getting event data, now check for availability
            self.CDAppHasLoadedAvailability()
//            engage the listeners to detect event and availability notifications
            self.eventChangeListener()
            self.availabilityChangeListener()
            //        get todays events
//            self.getDaysEventsIDCD{
//                self.tblViewEventList.reloadData()
//            }
        }

//        print the directory the SQL database is saved to
        print("data save location: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        
//        setup the navigation controller Cirleit text
        let welcomeText = NSMutableAttributedString(string: "Menu",
                                                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.black])
        
        introText.attributedText = welcomeText
        
        
        introText.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 0.5)
        
        lblTodaysEvents.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 0.5)
        
    //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: true, tintColour: UIColor.black)
        
        navigationItem.hidesBackButton = true
        
//        hide code test button
        testTheCodeButton.isHidden = false

        

//        show the tutorial for the front page
        showTutorial()
        
//        view settings

        view.backgroundColor = UIColor.white
        collectionViewMenu.backgroundColor = UIColor.white
//        get users push notification token
//        registerForPushNotifications()
        
//        setup for the collectionview
        collectionViewMenu.delegate = self
        collectionViewMenu.dataSource = self
        
//        setup for tableview
        tblViewEventList.delegate = self
        tblViewEventList.dataSource = self
// Refresh control add in tableview.
        refreshControlCreated.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlCreated.addTarget(self, action: #selector(refreshCreated), for: .valueChanged)
        tblViewEventList.addSubview(refreshControlCreated)
        
//        date formats
        dateFormatterForResultsCreateEvent.dateFormat = "E d MMM HH:mm"
        dateFormatterForResultsCreateEvent.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterSimple.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        
        
        
        //        ***For coachMarks
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.allowTap = true
        
//        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        
        //        Mark: Firebase listeners
        //        listener to detect when any events are added with the users username in them
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global()
        

        checkNotificationStatus(){
            
            self.collectionViewMenu.reloadData()
        }

        var newEventListener = dbStore.collection("userEventStore").whereField("uid", isEqualTo: user ?? "").whereField("userResponded", isEqualTo: false).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            queue.async {
            
        
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("New event: \(diff.document.data())")
                    
                    let source = diff.document.metadata.hasPendingWrites ? "Local" : "Server"
                    
//                    To check whether availability has already been supplied
                    let userAvailabilityCheck = diff.document.get("userAvailability") as? [Int] ?? [99]
                    print("userAvailabilityCheck: \(userAvailabilityCheck)")
                    
                    
//                    if availability exist then stop the process
                    if source == "local" || userAvailabilityCheck[0] != 99 {
                        
                        //                        for local updates we do nothing
                        
                    }
                    else{
      
                        self.checkCalendarStatus2()
                        self.newEventID = diff.document.get("eventID") as! String
                        self.userEventStoreID = diff.document.documentID

                        self.getEventInformation3(eventID: self.newEventID, userEventStoreID: self.userEventStoreID) { (userEventStoreID, eventSecondsFromGMT, startDates, endDates) in
                            
                            print("Succes getting the event data")
                            
                            print("startDates: \(startDates), endDates: \(endDates)")
                            
                            
                            let numberOfDates = endDates.count - 1
                            
                            let startDateDate = self.dateFormatterTZ.date(from: startDates[0])
                            let endDateDate = self.dateFormatterTZ.date(from: endDates[numberOfDates])

                            let endDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).endDatesOfTheEvents
                            let startDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).startDatesOfTheEvents
    
                            let finalAvailabilityArray2 = self.compareTheEventTimmings3(datesBetweenChosenDatesStart: startDates, datesBetweenChosenDatesEnd: endDates, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents)
                            
                            
                            //                        add the finalAvailabilityArray to the userEventStore
                            
                            
                            self.commitUserAvailbilityData(userEventStoreID: userEventStoreID, finalAvailabilityArray2: finalAvailabilityArray2, eventID: self.newEventID)
                                semaphore.signal()
                            }
                       semaphore.wait()
                    }
                    
                    
                    
                }
                
//                for modifications to the event we watch for changes to the chosen date
                if (diff.type == .modified) {
                    print("Modified event: \(diff.document.data())")
 
                    if diff.document.get("chosenDate") == nil {
                                            print("no date chosen")
                                        }
                                        else{
                                            
                                            //            the default for a firebase listener is to react to both the local write and the cloud stored event, hence we isolate the cloud event only to ensure we only add the event to the calendar once
                                            let source = diff.document.metadata.hasPendingWrites ? "Local" : "Server"
                                            //            print("\(source) data: \(diff.document.data() )")
                                            
                                            //            we set nothing to happen if the source is the local write
                                            if source == "local" {
                                                
                                            }
                                            else{
                                                
                                                //            print("date chosen: \(diff.document.get("chosenDate") ?? "date chosen did not unwrap")")
                                                let eventID = diff.document.get("eventID")
                                                print("date chosen listener eventID \(String(describing: eventID))")
                                                let chosenDateCreate = diff.document.get("chosenDate") as! String
                                                print("date chosen listener chosen date \(chosenDateCreate)")
                                                
                                                self.userEventStoreID = diff.document.documentID
                                                
                                                var calendarEventIDGotCheck = String()
                                                
                                                let calendarEventIDGot = diff.document.get("calendarEventID") ?? ""
                                                
                                                
                                                
                    //                            this flag indicates whether the user has been asked if they would like to add this event to thier calendar previosuly, if they have then we will stop here
                                                
                                                let eventSeenFlag = diff.document.get("chosenDateSeen") as! Bool
                                                print("eventSeenFlag \(eventSeenFlag)")
                                                
                                                if eventSeenFlag == true{
                                                    
                                                }
                                                else{
                                                dbStore.collection("eventRequests").document(eventID as! String).getDocument(completion: { (documentEventData, error) in
                                                    if error != nil {
                                                        print("Error getting documents for adding event")
                                                    }
                                                    else{
                                                        
                                                        var checkForData = documentEventData!.get("startTimeInput") as? String ?? ""
                                                        
                                                        if checkForData == "" {
                                                            
                                                            print("This event was deleted - we do not continue")
                                                            
                                                        }
                                                        else{
                                                            
                                                            print(documentEventData!)
                                                        
                                                        let startTimeString = documentEventData!.get("startTimeInput") as! String
                                                            
                                                        let allStartDates = documentEventData!.get("startDates") as! [String]
                                                            
                                                            
                                                            let allEndDates = documentEventData!.get("endDates") as! [String]
                                                            
                                                            let dateFormatterTZCreate = DateFormatter()
                                                            dateFormatterTZCreate.dateFormat = "yyyy-MM-dd HH:mm z"
                                                            dateFormatterTZCreate.locale = Locale(identifier: "en_US_POSIX")
                                                            
                                                            
                                                            
                                                        let chosenDatePosition = documentEventData!.get("chosenDatePosition") as! Int
                                                            
                                                            let chosenStartDate = allStartDates[chosenDatePosition]
                                                            print("chosenStartDate \(chosenStartDate)")
                                                            
                                                            let chosenEndDate = allEndDates[chosenDatePosition]
                                                            print("chosenEndDate: \(chosenEndDate)")
                                                            
                                                            let starDateDisplay = documentEventData!.get("chosenDate") as? String ?? ""
                    //
                    //                                        let chosenStartDateDate = dateFormatterTZCreate.date(from:chosenStartDate)
                    //                                        print("chosenStartDateDate: \(String(describing: chosenStartDateDate))")
                    //                                        let chosenEndDateDate = dateFormatterTZCreate.date(from:chosenEndDate)
                    //                                        print("chosenEndDateDate: \(String(describing: chosenEndDateDate))")
                                                        
                                                        let eventCreatorCreate = documentEventData!.get("eventOwnerName") as? String ?? ""
                                                            
                                                        let eventCreatorID = documentEventData!.get("eventOwner") as? String ?? ""
                                                        
                                                        let eventLocationCreate = documentEventData!.get("location") as? String ?? ""
                                                        //                    print(eventLocationCreate)
                                                        let eventDescriptionCreate = documentEventData!.get("eventDescription") as? String ?? ""
                                                        
                    //                                    get event geolocation
                                                        let locationLongitude = documentEventData!.get("locationLongitude") as? Double ?? 0.0
                                                        
                                                        let locationLatitude = documentEventData!.get("locationLatitude") as? Double ?? 0.0
                                               
                                                        
                                                        //                    Adds the event to the users calendar
                                                            self.addEventToCalendar(title: eventDescriptionCreate, description: eventDescriptionCreate, startDate:  chosenStartDate, endDate: chosenEndDate, location: eventLocationCreate, eventOwner: eventCreatorCreate, startDateDisplay: starDateDisplay, eventOwnerID: eventCreatorID, locationLongitude: locationLongitude, locationLatitude: locationLatitude, userEventStoreID: self.userEventStoreID, calendarEventIDInput: calendarEventIDGot as! String)
                                                        }
                                                        
                                                    }})
                                                    
                                                }
                                            }
                                        }
                    
                    
                }
                if (diff.type == .removed) {
                    print("Removed event: \(diff.document.data())")
                }
                
                }
                
            }
            
        }
        
//    EVENT DATE CHOSEN: listener to detect when an event we have been invited to or created has had its chosen date set
        
       var dateChosenListener = dbStore.collection("userEventStore").whereField("uid", isEqualTo: user ?? "").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
        
        print("dateChosenListener has been triggered")
        
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .modified) {
                    
                    
                    
                }

            }
        

        }
        
                
         func viewWillDisappear(_ animated: Bool) {
                
                newEventListener.remove()
                dateChosenListener.remove()
                coachMarksController.stop(immediately: true)
            
            }
        
        
//        end of viewDidLoad - note: viewWillDisappear is contained within the viewDidLoad, this allows for the removal of the listeners
        
    }
    
    
    //    function to get any updated data once the table is pulled down
    @objc func refreshCreated(_ sender: Any) {
        
        //        get todays events
        getDaysEventsIDCD{
            self.tblViewEventList.reloadData()
        }
        refreshControlCreated.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        checkNotificationStatus(){
            
            self.collectionViewMenu.reloadData()
        }
    }

  
    override func viewDidAppear(_ animated: Bool) {
        
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
                
              // set the view controller as root
              performSegue(withIdentifier: "newMessageNotification", sender: self)
  
              }
          }
          else if category == "newEvent"{
            summaryView = false
            
            if eventIDChosen == ""{
             print("eventIDChosen not set - aborting")
                
             UserDefaults.standard.set("", forKey: "notificationSent3")
                
            }
            else{
                
                print("segue to event page")
            
              UserDefaults.standard.set("", forKey: "notificationSent3")
            
            prepareForEventDetailsPage(eventID: eventIDChosen, isEventOwnerID: "", segueName: "None", isSummaryView: false, performSegue: false){
                
//                 set the view controller as root
                self.performSegue(withIdentifier: "todaysEventsSegue", sender: self)
                    
            }
            }}
          else{
            print("category not set for app opening")
            
            let createEventCoachMarksCount = UserDefaults.standard.integer(forKey: "createEventCoachMarksCount")
            let createEventCoachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
            
            if summaryView == true && createEventCoachMarksCount < 3 || summaryView == true && createEventCoachMarksPermenant == true{
                
            
            coachMarksController.start(in: .window(over: self))
                
                UserDefaults.standard.set(createEventCoachMarksCount + 1, forKey: "createEventCoachMarksCount")
                
                summaryView = false
                
            }
            
  
            else{
                
            }

          }
            
        }
    
    func showTutorial(){
        
    let firstTimeUser = UserDefaults.standard.string(forKey: "firstTimeOpening") ?? ""
    let createEventCoachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
        
        
    if firstTimeUser == "" || createEventCoachMarksPermenant == true{
    
            
    print("was the first time the user opened the app")
        
    let storyBoard = UIStoryboard(name: "TutorialStoryboard", bundle: nil)
    
    let popOverVC = storyBoard.instantiateViewController(withIdentifier: "pageViewTutorial") as! PageViewController
        
        DispatchQueue.main.async{

    self.addChild(popOverVC)
       popOverVC.view.frame = self.view.frame
       self.view.addSubview(popOverVC.view)
       popOverVC.didMove(toParent: self)
            
            UserDefaults.standard.set("false", forKey: "firstTimeOpening")
        
        }}
        else{
            
            print("wasn't the first time the user opened the app")
            
        }
    }
    
    
    //    MARK: CollectionView Setup
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let noSections = 2
        
        return noSections
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let noRows = 2
        
        return noRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "firstMenuCell", for: indexPath) as? FirstMenuCollectionViewCell
            else{
                fatalError("Issue displaying the collectionview cell")
        }
        
        
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        cell.layer.shadowRadius = 4
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
    
        cell.backgroundColor = UIColor.white
        cell.menuImage.image =  UIImage(named: pictureNames[indexPath.section][indexPath.row])
        
        cell.menuLabel.text = menuLabels[indexPath.section][indexPath.row]
        
        cell.menuLabel.lineBreakMode = .byWordWrapping
        cell.menuLabel.numberOfLines = 2
        cell.menuLabel.font = UIFont.systemFont(ofSize: 15)
        
        cell.imgNewMessage.layer.cornerRadius = 20
        cell.imgNewMessage.layer.borderWidth = 1.0
        cell.imgNewMessage.layer.borderColor = UIColor.red.cgColor
        cell.imgNewMessage.layer.masksToBounds = true
        
        if chatNotification[indexPath.section][indexPath.row] == ""{
            
            cell.imgNewMessage.isHidden = true
        }
        else if chatNotification[indexPath.section][indexPath.row] == "chatNotificationPending"{
           
            if chatNotificationPending == true{
              cell.imgNewMessage.isHidden = false
                
            }
            else{
                cell.imgNewMessage.isHidden = true
                
            }
        }
        else if chatNotification[indexPath.section][indexPath.row] == "chatNotificationDateChosen"{
             
                if chatNotificationDateChosen == true{
                  cell.imgNewMessage.isHidden = false
                    
                }
                else{
                    cell.imgNewMessage.isHidden = true
                    
                }
                
            }
            
               
        return cell
 
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        do something when a cell is selected
        print("selected cell \(indexPath.section)\(indexPath.row)")
        
//        remove any selected contacts from the array
        contactsSelected.removeAll()
        
        if segueIdentifiers[indexPath.section][indexPath.row] == ""{
         
            print("Segue doesn't exist")
            
        }
        else{
            
            
        performSegue(withIdentifier: segueIdentifiers[indexPath.section][indexPath.row], sender: Any.self)
            
            newEventLongitude = 0.0
            newEventLatitude = 0.0
            chosenMapItemManual = ""
            
        }
        
    }
    //    MARK: - three mandatory methods for choach tips
             
             func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
                 
                 let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
                
                 
                 let hintLabels = ["Congratulations! You created your first event. Your newly created event can be viewed in Pending Events"]
                 
                 let nextlabels = ["OK"]
                 
                 coachViews.bodyView.hintLabel.text = hintLabels[index]
                 
                 coachViews.bodyView.nextLabel.text = nextlabels[index]
                    
     //            coachViews.bodyView.nextLabel.isEnabled = false
                    
                 
                 return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
                 
             }
             
             
             func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
                 
                 
                 //    Defines where the coachmark will appear
                 let pointOfInterest = UIView()
                 
                 
                 let hintPositions = [CGRect(x: screenWidth/2 + 20, y: topDistance + 75, width: screenWidth/2 - 50, height: screenWidth/2 - 53)]
                 
                 pointOfInterest.frame = hintPositions[index]
                 
                 
                 return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
             }
             
             
             
         //    The number of coach marks we wish to display
             func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
                 return 1
             }
         
     //    When a coach mark appears
         func coachMarksController(_ coachMarksController: CoachMarksController, willShow coachMark: CoachMark, at index: Int){
             
             print("Coach Index appeared \(index)")
    
         }
         
     //    when a coach mark dissapears
         func coachMarksController(_ coachMarksController: CoachMarksController, willHide coachMark: CoachMark, at index: Int){
             

            print("Coach Index disappeared \(index)")
             
             
             if index == 3 {
                 
     //            add non user invitees
                    if nonExistingUsers.count > 0{
                        
                        self.inviteFriendsPopUp(notExistingUserArray: nonExistingNumbers, nonExistingNameArray: nonExistingUsers)
                     
                     nonExistingUsers.removeAll()
                        
                    }
                    else{}}
             
             else{
                 print("coachmarks still to present")
             }
             
         }
    
}
    

extension CreateEventViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = Int()
        
        if daysEvents.count == 0{
            numberOfRows = 1
            
        }
        else{
        
            numberOfRows = todaysEventsSearch.count
        }
        
        return numberOfRows
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tblViewEventList.dequeueReusableCell(withIdentifier: "daysEventsCell") as? TableViewCellHomePage
        else{
            fatalError("error creating cell TableViewCellHomePage")
        }
        
        if daysEvents.count == 0{
          
            cell.lblTableView.text = ""
            cell.lbl2TableView.text = "No events in your Planr"
            cell.lbl3TableView.text = ""
            
        }
        else{
            
            let text = ("\(daysEvents[indexPath.row].eventStartTime) - \(daysEvents[indexPath.row].eventEndTime)")
            
            cell.lblTableView.text = todaysEventsSearch[indexPath.row].eventDescription
            cell.lbl2TableView.text = text
            cell.lbl3TableView.text = todaysEventsSearch[indexPath.row].eventLocation
            cell.lblTableView.font = UIFont.systemFont(ofSize: 17)
            cell.lbl2TableView.font = UIFont.systemFont(ofSize: 15)
            cell.lbl3TableView.font = UIFont.systemFont(ofSize: 13)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if daysEvents.count == 0{
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else{
        
        currentUserSelectedEvent = todaysEventsSearch[indexPath.row]
        
        currentUserSelectedAvailability = serialiseAvailability(eventID: todaysEventsSearch[indexPath.row].eventID)
        self.prepareForEventDetailsPageCD(segueName: "todaysEventsSegue", isSummaryView: false, performSegue: true, userAvailability: currentUserSelectedAvailability){
            print("selected \(indexPath.row) performing segue to summary page")
            tableView.deselectRow(at: indexPath, animated: true)
        }
        }
        
    }
}


//Firebase extension
extension CreateEventViewController{
//function to pull down todays events
func getDaysEventsIDCD(completion: @escaping () -> Void){
        
//    clear the array prior to running the code
        todaysEventsSearch.removeAll()
    
    //    since the database stores down the year/month/day the event was chosen for as at the event creators timezone, we must ensure we are adjusting for all potential events occurring today our timezone
        let today = Date()
        let todayPlus1 = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let todayMinus1 = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let monthAsNr = Calendar.current.component(.month, from: today)
        let dayAsNr = Calendar.current.component(.day, from: today)
        let yearAsNr = Calendar.current.component(.year, from: today)
        
        let monthAsNrPlus1 = Calendar.current.component(.month, from: todayPlus1)
        let dayAsNrPlus1 = Calendar.current.component(.day, from: todayPlus1)
        let yearAsNrPlus1 = Calendar.current.component(.year, from: todayPlus1)
        
        let monthAsNrMinus1 = Calendar.current.component(.month, from: todayMinus1)
        let dayAsNrMinus1 = Calendar.current.component(.day, from: todayMinus1)
        let yearAsNrMinus1 = Calendar.current.component(.year, from: todayMinus1)

        print("running func getTodaysEvents - currentMonth: \(monthAsNr) currentDay: \(dayAsNr) currentYear: \(yearAsNr)")
//        todays events
//        let predicate =
    
    
//    let predicate = NSPredicate(format: "chosenDateYear == %@ AND chosenDateMonth == %@ AND chosenDateDay == %@", yearAsNr, monthAsNr, dayAsNr)
    
////    tomorrows events
//    let predicatePlus1 = NSPredicate(format: "chosenDateYear == %@ AND chosenDateMonth == %@ AND chosenDateDay == %@", yearAsNrPlus1, monthAsNrPlus1, dayAsNrPlus1)
//    //    yesterdays events
//    let predicateMinus1 = NSPredicate(format: "chosenDateYear == %@ AND chosenDateMonth == %@ AND chosenDateDay == %@", yearAsNrMinus1, monthAsNrMinus1, dayAsNrMinus1)
    
//        call CD with the predicate
    todaysEventsSearch = serialiseEvents(predicate: NSPredicate(format: "chosenDateYear = %@ && chosenDateMonth = %@ && chosenDateDay = %@ || chosenDateYear = %@ && chosenDateMonth = %@ && chosenDateDay = %@ || chosenDateYear = %@ && chosenDateMonth = %@ && chosenDateDay = %@", argumentArray: [yearAsNr,monthAsNr,dayAsNr,yearAsNrPlus1,monthAsNrPlus1,dayAsNrPlus1,yearAsNrMinus1,monthAsNrMinus1,dayAsNrMinus1]), usePredicate: true)
    
//    we need to check if the events are occuring today once adjsuted for the timezone
    let dateFormatterTZ = DateFormatter()
    dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
    dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
    let todayDay = Calendar.current.component(.day, from: today.addingTimeInterval(TimeInterval(secondsFromGMT)))
     
    
    for i in todaysEventsSearch{

        let startDates = i.startDateArray
        let chosenDatePosition = i.chosenDatePosition
        let eventChosenDateString = startDates[chosenDatePosition]
        let eventChosenDateDate = dateFormatterTZ.date(from: eventChosenDateString)
        let eventDay = Calendar.current.component(.day, from: eventChosenDateDate!)

//        remove those events that dont occur today
        if todayDay != eventDay{
            todaysEventsSearch.removeAll{$0.eventID == i.eventID}
        }

    }
    completion()
       }

    
}



extension StringProtocol {
    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
    subscript(_ range: Range<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}

extension LosslessStringConvertible {
    var string: String { return .init(self) }
}

extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}
//examples
//let test = "Hello USA 🇺🇸!!! Hello Brazil 🇧🇷!!!"
//test[safe: 10]   // "🇺🇸"
//test[11]   // "!"
//test[10...]   // "🇺🇸!!! Hello Brazil 🇧🇷!!!"
//test[10..<12]   // "🇺🇸!"
//test[10...12]   // "🇺🇸!!"
//test[...10]   // "Hello USA 🇺🇸"
//test[..<10]   // "Hello USA "
//test.first   // "H"
//test.last    // "!"
//
//// Subscripting the Substring
//test[...][...3]  // "Hell"
//
//// Note that they all return a Substring of the original String.
//// To create a new String you need to add .string as follow
//test[10...].string  // "🇺🇸!!! Hello Brazil 🇧🇷!!!"

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension CreateEventViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth/2 - 50, height: screenWidth/2 - 50)
}
}


//extension allows for the creation of uilabels with single borders
extension CALayer {

    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }

        border.backgroundColor = color.cgColor;

        self.addSublayer(border)
    }

}

extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}
