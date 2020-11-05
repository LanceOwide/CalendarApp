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
var cdAppHasLoaded = Bool()

//global variables for listeners - allows us to remove them from anyhwere
var eventListenerRegistration: ListenerRegistration!
var availabilityListenerRegistration: ListenerRegistration!

//global variable for monitoring when the user has loaded the app from a new event notification, whilst the app is in the background
var eventNotificationAppBackground: Bool = false

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
    var eventNotification = [["","eventNotificationPending"],["",""]]
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
        
//        set the badge number to 0
        UIApplication.shared.applicationIconBadgeNumber = 0

        
//        set user default to log that the user isnt new
        UserDefaults.standard.set(true, forKey: "newUser")
        
//      check that the user is in our user database, or log them out
        checkUserInUserDatabase()
        
//        checks if we have access to the users calendar
//        checkCalendarStatus2()
        navigationItem.titleView = setAppHeader(colour: UIColor.black)
        
        
//        Prepare coreData for the app
        if user == nil{
//            delay for 15 seconds if the user isnt yet logged in
            let seconds15 = 15.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds15) {
                if user == nil{
//                    delay for a further 15 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds15) {
//                        self.prepareApp()
                    }
                
                }
                else{
//                    self.prepareApp()
                    
                }
            }
        }
        else{
//        prepareApp()
        }
        
//        trigger for the new user explanation
        NotificationCenter.default.addObserver(self, selector: #selector(userJustRegisteredIntro), name: .tutorialClosed, object: nil)
        
        
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
        testTheCodeButton.isHidden = true

    
//        show the tutorial for the front page and the new user intro
        showTutorial()
        
        
//        view settings

        view.backgroundColor = UIColor.white
        collectionViewMenu.backgroundColor = UIColor.white

        
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
        coachMarksController.overlay.isUserInteractionEnabled = true
        
//        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: .notificationsReloaded, object: nil)
        
        
//        end of viewDidLoad
        
    }

    
    @objc func updateTable(){
        collectionViewMenu.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {

           coachMarksController.stop(immediately: true)
       
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
        

    }

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
                        // set the view controller as root
                        performSegue(withIdentifier: "newMessageNotification", sender: self)
                        }
              }
          }
          else if category == "newEvent"{
            summaryView = false
            
//            we turn off the listeners, this ensures the code below functions correctly, we then turn the listeners back on at the event page
            if availabilityListenerEngaged == true{ availabilityListenerRegistration.remove()
                 availabilityListenerEngaged = false
                print("removing the event availability listener")
            }
            if eventListenerEngaged == true{ eventListenerRegistration.remove()
                 eventListenerEngaged = false
                print("removing the event event listener")
            }
            
            if eventIDChosen == ""{
             print("eventIDChosen not set - aborting")
             UserDefaults.standard.set("", forKey: "notificationSent3")
            }
            else{
//            show the user a loading sign
                let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
                loadingNotification.label.text = "Loading event"
                loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
                loadingNotification.mode = MBProgressHUDMode.customView
                
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
                                    
                                  loadingNotification.label.text = "We're having trouble loading the event, please try again later"
                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds3){
                                        loadingNotification.hide(animated: true)
                                    }
 
                                }
                                else{
                                                                currentUserSelectedEvent = predicateReturned[0]
                                                                
                                                                //                load the required availability
                                                                currentUserSelectedAvailability = self.serialiseAvailability(eventID: eventIDChosen)
                                                                self.prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                                                                    //                 set the view controller as root
                                                                    loadingNotification.hide(animated: true)
                                    //                                set the userdefault back so that we don't interfere with other newer notifications
                                                                    UserDefaults.standard.set("", forKey: "notificationSent3")
                                                                self.performSegue(withIdentifier: "todaysEventsSegue", sender: self)
                                                                }
                                }
                            }
                        }
//                            the first predicate returned the event
                        else{
                            
                            currentUserSelectedEvent = predicateReturned[0]
                            
                            //                load the required availability
                            currentUserSelectedAvailability = self.serialiseAvailability(eventID: eventIDChosen)
                            self.prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                            //                 set the view controller as root
                                loadingNotification.hide(animated: true)
//                                set the userdefault back so that we don't interfere with other newer notifications
                                UserDefaults.standard.set("", forKey: "notificationSent3")
                            self.performSegue(withIdentifier: "todaysEventsSegue", sender: self)
                                                
                            }}}}
                    
//                }}}
//            the app was not opened from a notification
          else{
            print("category not set for app opening")
            
            let createEventCoachMarksCount = UserDefaults.standard.integer(forKey: "createEventCoachMarksCount")
            let createEventCoachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
            
            print("coachmark test summaryView: \(summaryView) createEventCoachMarksCount: \(createEventCoachMarksCount) createEventCoachMarksPermenant: \(createEventCoachMarksPermenant)")
            
            if summaryView == true && createEventCoachMarksCount < 2 || summaryView == true && createEventCoachMarksPermenant == true{
            coachMarksController.start(in: .window(over: self))
                UserDefaults.standard.set(createEventCoachMarksCount + 1, forKey: "createEventCoachMarksCount")
                summaryView = false
            }
            else{
            }

          }
            
        }
    
    func showTutorial(){
        
    let firstTimeUser = UserDefaults.standard.string(forKey: "firstTimeOpeningv2.19") ?? ""
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
        
        }}
        else{
            
            print("wasn't the first time the user opened the app")
            
        }
    }
    
//    function to check for new events and activate the listeners when the user logs in
    func prepareApp(){
        print("running func prepareApp")
        //        check we have data in core data and download all data if not is in CD. We check to see if the cdAppHasLoaded flag is set, we do this becuase we do not want CDAppHasLoaded running at the same time as the eventListener
        if cdAppHasLoaded == true{
            print("prepareApp cdAppHasLoaded = true, we end only check the current dates")
            //        get todays events
            getDaysEventsIDCD{
                self.tblViewEventList.reloadData()
            }
        }
        else{
            print("cdAppHasLoaded = false")
//            before continuning we ensure the listeners are not engaged, we re-engage them once done.
            if availabilityListenerEngaged == true{availabilityListenerRegistration.remove()
             print("userNotificationCenter - disabling availabilityListenerRegistration")
                availabilityListenerEngaged = false
            }
            if eventListenerEngaged == true{eventListenerRegistration.remove()
                print("userNotificationCenter - disabling eventListenerRegistration")
                eventListenerEngaged = false
            }
        CDAppHasLoaded{
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
        //                run consistency checks
                    self.dataConsistencyCheck()
                        cdAppHasLoaded = true
                        
                    //        get todays events
                    self.getDaysEventsIDCD{
                        self.tblViewEventList.reloadData()
                    }
                    }
            }}}
    
    
//    run some specific intro processes for a new user - userJustRegistered global bool
   @objc func userJustRegisteredIntro(){
    print("running func userJustRegisteredIntro")
//        check if this is a new user
         let firstTimeUser = UserDefaults.standard.string(forKey: "firstTimeOpeningv2.19") ?? ""
        
//        want to check if the user has an invite already, if so we set the pending even notification and show the instructions
        if firstTimeUser == ""{
        
//        retrieve the events to check if they are pending, if they are not pending we will do nothing for now
        let serialisedEvents = serialiseEvents(predicate: NSPredicate(format: "eventOwner = %@", user!), usePredicate: false)
//      filter the serilaised events for pending status
        let events = filteringEventsForDisplay(pending: true, createdByUser: false, pastEvents: false, serialisedEvents: serialisedEvents)
        
        
        if events.count != 0{
        print("the user has events")
//            turn on the pending event notificaiton
           eventNotificationPending = true
//            reload the data now we've updated the notification
            collectionViewMenu.reloadData()
//            start the coachmarks
            coachMarksController.start(in: .window(over: self))
        }
        else{
            
            UserDefaults.standard.set("nope", forKey: "firstTimeOpeningv2.19")
            }
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
        
        cell.imgNewEvent.layer.cornerRadius = 20
        cell.imgNewEvent.layer.borderWidth = 1.0
        cell.imgNewEvent.layer.borderColor = UIColor.red.cgColor
        cell.imgNewEvent.layer.masksToBounds = true
        
        
//        checking to see if the event notification should be displayed
        
        if eventNotification[indexPath.section][indexPath.row] == ""{
         cell.imgNewEvent.isHidden = true
        }
        else{
          
            if eventNotificationPending == true{
               cell.imgNewEvent.isHidden = false
            }
            else{
               cell.imgNewEvent.isHidden = true
            }
            
        }
        
//        checking to see if the chat notification should be displayed
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
                    cell.imgNewMessage.isHidden = true}
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
            
//            perform the data consistency checks before we show the user the events
            dataConsistencyCheck()
            
        performSegue(withIdentifier: segueIdentifiers[indexPath.section][indexPath.row], sender: Any.self)
            
            newEventLongitude = 0.0
            newEventLatitude = 0.0
            chosenMapItemManual = ""
            
        }
        
    }
    //    MARK: - three mandatory methods for choach tips
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?){
                 
                 let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
                
                var hintLabels = [String]()
                var nextlabels = [String]()
                
                let firstTimeUser = UserDefaults.standard.string(forKey: "firstTimeOpeningv2.19") ?? ""
                
//        if this is the first time the user has logged in and they have event invites we show them the following instructions
                if firstTimeUser == "" && eventNotificationPending == true{
                    
                     hintLabels = ["You've been invited to an event!","Planr automatically responds with your availability based on the events in your calendar, Planr will even respond in the background, lookout for new invite notifications", "You'll find the calendars Planr uses in settings"]
                     nextlabels = ["OK","OK","OK","OK","OK"]
                    
                    coachViews.bodyView.hintLabel.text = hintLabels[index]
                    coachViews.bodyView.nextLabel.text = nextlabels[index]
                    
                }
//                    The only other time the instructions are called is after the user has created an event
                    else{
                
                  hintLabels = ["Congratulations! You created your first event. Your newly created event can be viewed in Pending Events"]
                  nextlabels = ["OK"]
                 
                 coachViews.bodyView.hintLabel.text = hintLabels[index]
                 coachViews.bodyView.nextLabel.text = nextlabels[index]
                    
     //            coachViews.bodyView.nextLabel.isEnabled = false
                    
                    
                    }
                 
                 return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
                 
             }
             
             
             func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
                 //    Defines where the coachmark will appear
                var pointOfInterest = UIView()
                let firstTimeUser = UserDefaults.standard.string(forKey: "firstTimeOpeningv2.19") ?? ""
                
                if firstTimeUser == ""{
                   
                    let hintPositions = [CGRect(x: screenWidth/2 + 20, y: topDistance + 75, width: screenWidth/2 - 50, height: screenWidth/2 - 53),CGRect(x: screenWidth/2 + 20, y: topDistance + 75, width: screenWidth/2 - 50, height: screenWidth/2 - 53),CGRect(x: screenWidth - 60, y: topDistance - 40, width: 40, height: 40)]
                    
                    pointOfInterest.frame = hintPositions[index]
                }
                else{
                 let hintPositions = [CGRect(x: screenWidth/2 + 20, y: topDistance + 75, width: screenWidth/2 - 50, height: screenWidth/2 - 53)]
                 
                 pointOfInterest.frame = hintPositions[index]
                }
                 return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
             }
             
             
             
         //    The number of coach marks we wish to display
             func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
                
                var numberOfCoachMarks = Int()
                let firstTimeUser = UserDefaults.standard.string(forKey: "firstTimeOpeningv2.19") ?? ""
                
                if firstTimeUser == ""{
                    
                   numberOfCoachMarks = 3 
                }
                else{
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
            
//            set the user default so we do not show this again
            if index == 2{
                UserDefaults.standard.set("false", forKey: "firstTimeOpeningv2.19")
            }
   
         }
    
}
    

extension CreateEventViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = Int()
        
        if todaysEventsSearch.count == 0{
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
        
        if todaysEventsSearch.count == 0{
          
            cell.lblTableView.text = ""
            cell.lbl2TableView.text = "No events in your Planr"
            cell.lbl3TableView.text = ""
            
        }
        else{
            
            let text = ("\(convertToLocalTime(inputTime: todaysEventsSearch[indexPath.row].eventStartTime)) - \(convertToLocalTime(inputTime: todaysEventsSearch[indexPath.row].eventEndTime))")
            
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
        
        
        if todaysEventsSearch.count == 0{
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else{
        
        currentUserSelectedEvent = todaysEventsSearch[indexPath.row]
        
        currentUserSelectedAvailability = serialiseAvailability(eventID: todaysEventsSearch[indexPath.row].eventID)
        self.prepareForEventDetailsPageCD(segueName: "todaysEventsSegue", isSummaryView: false, performSegue: true, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
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

    todaysEventsSearch = serialiseEvents(predicate: NSPredicate(format: "chosenDateYear = %@ && chosenDateMonth = %@ && chosenDateDay = %@ || chosenDateYear = %@ && chosenDateMonth = %@ && chosenDateDay = %@ || chosenDateYear = %@ && chosenDateMonth = %@ && chosenDateDay = %@", argumentArray: [yearAsNr,monthAsNr,dayAsNr,yearAsNrPlus1,monthAsNrPlus1,dayAsNrPlus1,yearAsNrMinus1,monthAsNrMinus1,dayAsNrMinus1]), usePredicate: true)
    
//    we need to check if the events are occuring today once adjsuted for the timezone
    let dateFormatterTZ = DateFormatter()
    dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
    dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
    let todayDay = Calendar.current.component(.day, from: today.addingTimeInterval(TimeInterval(secondsFromGMT)))
     print("todayDay \(todayDay)")
    
    for i in todaysEventsSearch{
        print("todaysEventsSearch \(todaysEventsSearch)")
        let startDates = i.startDateArray
        let chosenDatePosition = i.chosenDatePosition
        let eventChosenDateString = startDates[chosenDatePosition]
        let eventChosenDateDate = dateFormatterTZ.date(from: eventChosenDateString)
        let eventDay = Calendar.current.component(.day, from: eventChosenDateDate!)
        print("eventDay \(eventDay)")
        

//        remove those events that don't occur today
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



