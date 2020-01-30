//
//  ViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import EventKit
import SwiftyJSON
import Alamofire
import FirebaseMessaging
import MBProgressHUD

var availabilitySummaryArray = [[Any]]()
var fractionResults = [[Any]]()
var noResultsArrayGlobal = [Int]()
var sectionUpcomingEvents = [eventSearch]()
var sectionPastEvents = [eventSearch]()
var sectionUserHostedEvents = [eventSearch]()
var newMessageNotification = Bool()


class  ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //    variables for the apple event calendar
    
    var calendarArray = [EKEvent]()
    var calendarEventArray : [Event] = [Event]()
    
    //    variables for the search dates chosen
    let dateFormatter = DateFormatter()
    let dateFormatterSimple = DateFormatter()
    let dateFormatterForResults = DateFormatter()
    let dateFormatterForResultsCreateEvent = DateFormatter()
    let dateFormatterTime = DateFormatter()
    let dateFormatterTZ = DateFormatter()
    var startDate = Date()
    var endDate = Date()
    var startDateEnd = Date()
    var startDateGetEvent = Date()
    var endDateGetEvent = Date()
    var startEndDateGetEvent = Date()
    var isAllDay: Bool = false
    var selectedCalendars: [EKCalendar]?
    var source = ""
    var userIDArray = Array<String>()
    var userNameArray = Array<String>()
    var myAddedUserName = ""
    var ref: DocumentReference? = nil
    var myAddedUserID: String = ""
    var eventCreationID: String = ""
    var textPassedOver : String?
    var contactsList = [contactList]()
    var selectedContacts: [String] = [""]
    var numberOfItems = 1
    var datesBetweenChosenDatesStart = Array<Date>()
    var datesBetweenChosenDatesEnd = Array<Date>()
    var datesOfTheEvents = Array<Date>()
    var startDatesOfTheEvents = Array<Date>()
    var startEndDate = Date()
    var finalAvailabilityArray = Array<Int>()
    var eventLocation = ""
    var eventDescription = ""
    var eventOwnerName = ""
    

    
//    the variables below are the required variables for the event search
    var startDateInput = String()
    var endDateInput = String()
    var startTimeInput = String()
    var endTimeInput = String()


//    variable for refreshing the UITableViews on pull down
    var refreshControlCreated = UIRefreshControl()
    
    
    var buttonHidden = false
    
    
//    Table views for invited and created events
    @IBOutlet var userCreatedEvents: UITableView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = setAppHeader(colour: UIColor.black)
        
        updatePendingNotificationStatus()
        
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        self.view.backgroundColor = UIColor(red: 253, green: 253, blue: 253)
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
//        setting to allow the add event image to be used as a button
        
        
        print(user!)
        userCreatedEvents.delegate = self
        userCreatedEvents.dataSource = self
        userCreatedEvents.rowHeight = 140
        self.userCreatedEvents.separatorStyle = UITableViewCell.SeparatorStyle.none
        
//        get the events created by the user to display in the tableview
        getUsersCreatedEvents()
  
        dbStore.settings = settings

//        capital HH denotes the 24hr clock
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterForResults.dateFormat = "E d MMM"
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterForResultsCreateEvent.dateFormat = "E d MMM HH:mm"
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterSimple.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterForResults.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterForResultsCreateEvent.locale = Locale(identifier: "en_US_POSIX")
        startDate = dateFormatter.date(from: startDateInput + " " + startTimeInput) ?? dateFormatter.date(from: "2019-01-01 00:00")!
        
//        these two elements must contain the same time HH:mm:ss
        startEndDate = dateFormatter.date(from: startDateInput + " " + endTimeInput) ?? dateFormatter.date(from: "2019-01-01 00:00")!
        endDate = dateFormatter.date(from: endDateInput + " " + endTimeInput) ?? dateFormatter.date(from: "2019-01-01 00:00")!
        
        
        
// Refresh control add in tableview.
        refreshControlCreated.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlCreated.addTarget(self, action: #selector(refreshCreated), for: .valueChanged)
        self.userCreatedEvents.addSubview(refreshControlCreated)

//        The end of the viewDidLoad
    }
    

    
    //    function to get any updated data once the table is pulled down
    @objc func refreshCreated(_ sender: Any) {
        
        getUsersCreatedEvents()
        refreshControlCreated.endRefreshing()

    }

   
    //    determines what day of the week the date is
    func getDayOfWeek(_ today:String) -> Int? {
        guard let todayDate = dateFormatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
//        print("weekday \(weekDay)")
        return weekDay
    }
    
    
//    function for pulling down the array containing the days of the week our event can be on
    func getDayOfTheWeekArray(eventID: String){
        
        let docRef = dbStore.collection("eventRequests").document(eventID)
        print(eventID)
        
        docRef.getDocument(
            completion: { (document, error) in
                if error != nil {
                    print("Error getting documents")
                }
                else {
                    
                    daysOfTheWeek = document?.get("daysOfTheWeek") as? [Int] ?? [10,10,10,10,10,10,10]

                }})}
    
    
    //    Adds the dates between our start date and end date to the Array datesBetweenChosenDates
    func getArrayOfChosenDates() {
        
        datesBetweenChosenDatesStart.removeAll()
        var currentDate = startDate
        let calendar = NSCalendar.current
        
        //        filters through the dates until the currentDate and endDate are equal
        while currentDate <= endDate {

            let myDateString = dateFormatter.string(from: currentDate)
            let dayOfWeek = getDayOfWeek(myDateString)! - 1
            print(dayOfWeek)
            
            if daysOfTheWeek.contains(dayOfWeek) {
                
                let myDateNonString = dateFormatter.date(from: myDateString)
                
                datesBetweenChosenDatesStart.append(myDateNonString!)
                print(datesBetweenChosenDatesStart)
                
                
                                print(myDateString)
            }
            else {
                
            }
            
            //            Adds one day to the current date
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate as Date)!
        }
    }
    
    
    //    Adds the dates between our start date and end date to the Array datesBetweenChosenDates
    func getArrayOfChosenDatesEnd() {
        
        datesBetweenChosenDatesEnd.removeAll()
        var currentDate = startEndDate
        let calendar = NSCalendar.current
        
        //        filters through the dates until the currentDate and endDate are equal
        while currentDate <= endDate {
            
            
            let myDateString = dateFormatter.string(from: currentDate)
            
            let dayOfWeek = getDayOfWeek(myDateString)! - 1
            
            if daysOfTheWeek.contains(dayOfWeek) {
                
                let myDateNonString = dateFormatter.date(from: myDateString)
                
                datesBetweenChosenDatesEnd.append(myDateNonString!)
//                print(myDateString)
                
            }
            else {
                
                
            }
            
            //            Adds one day to the current date
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate as Date)!
        }
    }
    
    
    //    MARK: code to pull down the events created by the user and display them
    @objc
    func getUsersCreatedEvents(){
        
        print("running func getUsersCreatedEvents")

        sectionUpcomingEvents.removeAll()
        sectionPastEvents.removeAll()
        sectionUserHostedEvents.removeAll()
        
        let dateFormatterTz = DateFormatter()
        let dateFormatterForResults = DateFormatter()
        
        dateFormatterTz.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTz.locale = Locale(identifier: "en_US_POSIX")
        
        dateFormatterForResults.dateFormat = "E d MMM"
        dateFormatterForResults.locale = Locale(identifier: "en_US_POSIX")
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
               loadingNotification.label.text = "Loading"
               loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
               loadingNotification.mode = MBProgressHUDMode.customView
        
        
        dbStore.collection("eventRequests").whereField("users", arrayContains: user!).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                
                if querySnapshot!.isEmpty == true{
                  
                    loadingNotification.hide(animated: true)
                    
                }
                else{
                
                for document in querySnapshot!.documents {
                    print("pending events page events pulldown \(document.documentID) => \(document.data())")
                    
                    
                    var nextUserEventToAdd = eventSearch()
                    
                    let startTimeString = document.get("startTimeInput") as! String
                    let adjStartTimeDate = self.dateFormatterTime.date(from: startTimeString)!.addingTimeInterval(TimeInterval(secondsFromGMT))
                    let adjStartTimeString = self.dateFormatterTime.string(from: adjStartTimeDate)
                    let endTimeString = document.get("endTimeInput") as! String
                    let adjEndTimeDate = self.dateFormatterTime.date(from: endTimeString)!.addingTimeInterval(TimeInterval(secondsFromGMT))
                    let adjEndTimeString = self.dateFormatterTime.string(from: adjEndTimeDate)
                    
                    nextUserEventToAdd.eventDescription = document.get("eventDescription") as! String
                    nextUserEventToAdd.eventStartTime = adjStartTimeString
                    nextUserEventToAdd.eventEndTime = adjEndTimeString
                    nextUserEventToAdd.eventLocation = document.get("location") as! String
                    nextUserEventToAdd.eventEndDate = document.get("endDateInput") as! String
                    nextUserEventToAdd.eventStartDate = document.get("startDateInput") as! String
                    nextUserEventToAdd.timeStamp = document.get("timeStamp") as? Float ?? 0.0
                    nextUserEventToAdd.eventID = document.documentID
                    nextUserEventToAdd.eventOwnerID = document.get("eventOwner") as! String
                    
                    
                    self.checkEventChatNotificationStatus(eventID: nextUserEventToAdd.eventID){ (notificationBool) in
                    
                        nextUserEventToAdd.newChatMessage = notificationBool
                        
                    }
                    
//                    check to see if we have a chat notification
                    
                    
                    
                    let eventOwner = document.get("eventOwner") as! String
                    
                    
                    if eventOwner == user! {
                        
                        nextUserEventToAdd.eventOwnerName = "You"
                    }
                    else{
                        nextUserEventToAdd.eventOwnerName = document.get("eventOwnerName") as! String
                    }
                    
                    nextUserEventToAdd.chosenDate = document.get("chosenDate") as? String ?? "2019-01-01"
                    let calendar = Calendar(identifier: .gregorian)
                    let eventSearchEndDate = self.dateFormatterSimple.date(from: nextUserEventToAdd.eventEndDate)
                    let eventChosenDate = self.dateFormatterSimple.date(from: nextUserEventToAdd.chosenDate)
                    let date = Date()
                    let newDate = date.addingTimeInterval(TimeInterval(secondsFromGMT))
                    let eventSearchEndDateAdj = eventSearchEndDate!.addingTimeInterval(TimeInterval(secondsFromGMT))
                    let dateComponents = DateComponents(year: Calendar.current.component(.year, from: newDate), month: Calendar.current.component(.month, from: newDate), day: Calendar.current.component(.day, from: newDate), hour: 0, minute: 0, second: 0)
                    let dateFromComponents = calendar.date(from: dateComponents)!.addingTimeInterval(TimeInterval(secondsFromGMT))
                    
                    print("dates for events: eventSearchEndDate: \(eventSearchEndDate!) eventChosenDate:\(eventChosenDate!) date:\(date)")
                    
                    
                    self.getInviteeNames(eventID: nextUserEventToAdd.eventID) { (userArray) in
    
                        
                    self.getInviteeNamesNonUsers(eventID: nextUserEventToAdd.eventID) { (userArrayNonUsers) in
                    
                        
                        nextUserEventToAdd.inviteeNamesArray = userArray + userArrayNonUsers
                    
                    self.getArrayOfChosenDates3(eventID: nextUserEventToAdd.eventID, completion: { (startDates, endDates) in
                        
                    
                        for dates in startDates {
                         
                        //                    converting the dates to test back to the string and format we want to display
                                            let newDate = dateFormatterTz.date(from: dates)
                                            
                            nextUserEventToAdd.startDateArray.append(dateFormatterForResults.string(from: newDate!))
                            
                            print("nextUserEventToAdd.startDateArray: \(nextUserEventToAdd.startDateArray)")
                            
                        }

                        //                    if the end date of our serach period for the event is after today or the
                        
                        if nextUserEventToAdd.chosenDate != "2019-01-01"{
  
                        }
                        else if eventSearchEndDateAdj < dateFromComponents {
                            
                            print("past event: \(nextUserEventToAdd.eventDescription)")
                            sectionPastEvents.append(nextUserEventToAdd)
                        }
                        else if eventOwner == user!{
                            
                            print("user hosted event: \(nextUserEventToAdd.eventDescription)")
                            
                            sectionUserHostedEvents.append(nextUserEventToAdd)
    
                        }
                        else {
                        
                        print("upcoming event: \(nextUserEventToAdd.eventDescription)")
                        
                        sectionUpcomingEvents.append(nextUserEventToAdd)
                            
                        }
                        loadingNotification.hide(animated: true)
                        self.userCreatedEvents.reloadData()
                    })
                }
            }}}
        }
    }
    }

//    reloads the table views whenever the page apears, this ensures it refreshes when a user creates a new event
    override func viewWillAppear(_ animated: Bool) {
        
//        getUsersCreatedEvents()
        
        userCreatedEvents.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        let sectionUpcomingRows = sectionUpcomingEvents.count
        let sectionUserHostedEventsRows = sectionUserHostedEvents.count
        let sectionPastRows = sectionPastEvents.count
        var numberOfRows = [Int]()
        
        if (sectionUpcomingRows + sectionPastRows + sectionUserHostedEventsRows) == 0 {
            
            
        numberOfRows = [1,0,0]
            
            print("numberOfRows: \(numberOfRows)")
            
        }
        else{
        
        numberOfRows = [sectionUserHostedEventsRows,sectionUpcomingRows,sectionPastRows]
            print("numberOfRows: \(numberOfRows)")
        }
        

        return numberOfRows[section]
    }
    
        
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var item: eventSearch

        
            guard let cell = userCreatedEvents.dequeueReusableCell(withIdentifier: "userEventCell", for: indexPath) as? UserCreatedEventsCell
                else{
                    fatalError("failed to create user created events cell")
        }
        
        cell.userCreatedCellLabel1.adjustsFontSizeToFitWidth = true
        cell.userCreatedCellLabel2.adjustsFontSizeToFitWidth = true
        cell.userCreatedCellLabel3.adjustsFontSizeToFitWidth = true
        
        
        if (sectionPastEvents.count + sectionUpcomingEvents.count + sectionUserHostedEvents.count) == 0{
            
            cell.userCreatedCellLabel1.text = ""
            cell.userCreatedCellLabel2.text = "You haven't created any events"
            cell.userCreatedCellLabel3.text = "Head to 'Create An Event' to get started"
            cell.userCreatedCollectionViewDates.isHidden = true
            cell.userCreatedCollectionViewNames.isHidden = true
            cell.imgChatNotification.isHidden = true
            
        }
        else{
            
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = UIColor.white
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 0.5
            cell.clipsToBounds = true
            cell.selectionStyle = .none
        
            
            if indexPath.section == 0{
              
                item = sectionUserHostedEvents[indexPath.row]
                        let eventTitleDescription = NSMutableAttributedString(string: item.eventDescription,
                                                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
                            eventTitleDescription.append(NSMutableAttributedString(string: " by: \(item.eventOwnerName)",
                                                                               attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
                            
                            
                        cell.userCreatedCellLabel1.attributedText = eventTitleDescription
                        cell.userCreatedCellLabel2.text =  item.eventLocation
                        
                        cell.userCreatedCellLabel3.text = ("\(item.eventStartTime) - \(item.eventEndTime)")
                        
//                        check if there is an outstanding chat message
                if item.newChatMessage == true{
                    
                    cell.imgChatNotification.isHidden = false
                    cell.imgChatNotification.layer.cornerRadius = 15
                    cell.imgChatNotification.layer.borderWidth = 1.0
                    cell.imgChatNotification.layer.borderColor = UIColor.red.cgColor
                    cell.imgChatNotification.layer.masksToBounds = true
                    
                }
                else{
                    
                    cell.imgChatNotification.isHidden = true
                }

                        cell.userCreatedCollectionViewDates.isHidden = false
                        cell.userCreatedCollectionViewNames.isHidden = false

                          
                //        Removed whilst testing the string process
                //        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
                
            }
            if indexPath.section == 1{
              
                item = sectionUpcomingEvents[indexPath.row]
                        let eventTitleDescription = NSMutableAttributedString(string: item.eventDescription,
                                                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
                            eventTitleDescription.append(NSMutableAttributedString(string: " by: \(item.eventOwnerName)",
                                                                               attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
                            
                            
                        cell.userCreatedCellLabel1.attributedText = eventTitleDescription
                        cell.userCreatedCellLabel2.text = ("\(item.eventLocation) \n\(item.eventStartTime) - \(item.eventEndTime)")
                        
                        cell.userCreatedCellLabel3.text = ("\(item.eventStartTime) - \(item.eventEndTime)")
                        
                //                        check if there is an outstanding chat message
                if item.newChatMessage == true{
                    
                    cell.imgChatNotification.isHidden = false
                    cell.imgChatNotification.layer.cornerRadius = 15
                    cell.imgChatNotification.layer.borderWidth = 1.0
                    cell.imgChatNotification.layer.borderColor = UIColor.red.cgColor
                    cell.imgChatNotification.layer.masksToBounds = true
                    
                }
                else{
                    
                    cell.imgChatNotification.isHidden = true
                }
                
                        cell.userCreatedCollectionViewDates.isHidden = false
                        cell.userCreatedCollectionViewNames.isHidden = false
                
                
                        
                          
                //        Removed whilst testing the string process
                //        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
                
                
            }
            if indexPath.section == 2{
              
                item = sectionPastEvents[indexPath.row]
                        let eventTitleDescription = NSMutableAttributedString(string: item.eventDescription,
                                                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
                            eventTitleDescription.append(NSMutableAttributedString(string: " by: \(item.eventOwnerName)",
                                                                               attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
                            
                            
                        cell.userCreatedCellLabel1.attributedText = eventTitleDescription
                        cell.userCreatedCellLabel2.text = ("Location: \(item.eventLocation) \nTime: \(item.eventStartTime) - \(item.eventEndTime)")
                        
                        cell.userCreatedCellLabel3.text = ("Time: \(item.eventStartTime) - \(item.eventEndTime)")
    
                //                        check if there is an outstanding chat message
                if item.newChatMessage == true{
                    
                    cell.imgChatNotification.isHidden = false
                    cell.imgChatNotification.layer.cornerRadius = 15
                    cell.imgChatNotification.layer.borderWidth = 1.0
                    cell.imgChatNotification.layer.borderColor = UIColor.red.cgColor
                    cell.imgChatNotification.layer.masksToBounds = true
                    
                }
                else{
                    
                    cell.imgChatNotification.isHidden = true
                }
                        cell.userCreatedCollectionViewDates.isHidden = false
                        cell.userCreatedCollectionViewNames.isHidden = false
  
            }
        
        
            
        }
        
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row, forSection: indexPath.section)
        
        
        cell.setCollectionViewDataSourceDelegateNames(dataSourceDelegate: self, forRow: indexPath.row, forSection: indexPath.section)
        
            return cell
 
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        
        var  numberOfSections = Int()
        
        if (sectionPastEvents.count + sectionUpcomingEvents.count + sectionUserHostedEvents.count) == 0 {
         numberOfSections = 1

        }
        else{
            numberOfSections = 3

            
        }
        
        print("numberOfSections: \(numberOfSections)")

        return numberOfSections
    }
    
    
    
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cellSpacingHeight: CGFloat = 50
        return cellSpacingHeight
    }
        
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let label = UILabel()
        var sectionHeaders = [String]()
        sectionHeaders.removeAll()
        headerView.backgroundColor = UIColor.clear
        
        if sectionUserHostedEvents.count == 0{
            
            sectionHeaders.append("")
        }
        else{
            
            sectionHeaders.append("Your Hosted Events 🏠")
            
            
        }
        
        if sectionUpcomingEvents.count == 0{
           sectionHeaders.append("")
            
        }
        else{
        
        sectionHeaders.append("Upcoming Events")
            
        }
        
        if sectionPastEvents.count == 0{
           sectionHeaders.append("")
            
        }
        else{
            
          sectionHeaders.append("Missed Events")
            
        }
                        
            
            label.frame = CGRect(x: 16, y: 5, width: screenWidth - 16, height: 40)
            label.text = sectionHeaders[section]
            headerView.addSubview(label)
            
            return headerView
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.section)!")
        eventResultsArrayDetails.removeAll()
        anyArray.removeAll()
    
        summaryView = false
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
        loadingNotification.label.text = "Loading"
        loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
        loadingNotification.mode = MBProgressHUDMode.customView
        
        if (sectionPastEvents.count + sectionUpcomingEvents.count + sectionUserHostedEvents.count) == 0{
            
        }
        else{
        if indexPath.section == 0{
            let info = sectionUserHostedEvents[indexPath.row]
            print("info: \(info)")
        
            
//            reset the non user invitees to ensure we don't carry over any non saved changes from previous view of the edit page
            nonUserInviteeNames.removeAll()
            deletedInviteeNames.removeAll()
            deletedNonUserInviteeNames.removeAll()
            deletedUserIDs.removeAll()
            
            if info.newChatMessage == true{
                newMessageNotification = true
            }
            else{
            
            newMessageNotification = false
            
            }
            
            print(info)
            eventIDChosen = info.eventID
            chosenDateForEvent = info.chosenDate
            let segue = "splitViewResultsController"
            
            //        gets all the event details needed to create the event detail arrays
            prepareForEventDetailsPage(eventID: eventIDChosen, isEventOwnerID: user!, segueName: segue, isSummaryView: false, performSegue: true){
                loadingNotification.hide(animated: true)
                self.userCreatedEvents.deselectRow(at: indexPath, animated: false)
                
            }
            
            
        }
          else if indexPath.section == 1{
                        let info = sectionUpcomingEvents[indexPath.row]
                        print("info: \(info)")

                        print(info)
                        eventIDChosen = info.eventID
                        chosenDateForEvent = info.chosenDate
                    let segue = "splitViewResultsController"
            
            
            if info.newChatMessage == true{
                newMessageNotification = true
            }
            else{
            
            newMessageNotification = false
            
            }
            
            
            prepareForEventDetailsPage(eventID: eventIDChosen, isEventOwnerID: "", segueName: segue, isSummaryView: false, performSegue: true){
                loadingNotification.hide(animated: true)
                self.userCreatedEvents.deselectRow(at: indexPath, animated: false)
                
            }
                
                    
                        
                    }
        else if indexPath.section == 2{
            
            let info = sectionPastEvents[indexPath.row]
            print(info)
            let segue = "splitViewResultsController"
            eventIDChosen = info.eventID
            let eventOwnerID = info.eventOwnerID
            chosenDateForEvent = info.chosenDate
            
            
            if info.newChatMessage == true{
                newMessageNotification = true
            }
            else{
            
            newMessageNotification = false
            
            }
            
            prepareForEventDetailsPage(eventID: eventIDChosen, isEventOwnerID: eventOwnerID, segueName: segue, isSummaryView: false, performSegue: true){
                
                loadingNotification.hide(animated: true)
                
                self.userCreatedEvents.deselectRow(at: indexPath, animated: false)
                
            }
            
            
            
        }
            else{
                
                print("section not created selected")
        }
        }
    }
    
//    used to determine whether the delete button should be visible on the event results page, the button is set to hidden for the events we were invited to. The buttons natural state is visible
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "eventResultsInvited") {
            let destinationController = segue.destination as! ViewController2
            destinationController.buttonHidden = true
        }
    }
    
    
//    used to set the carrier, battery and time colour to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
//    the number of columns in the collectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        
        var numberOfItemsForSection = Int()
        
        
        print("collectionView.tag: \(collectionView.tag)")
        
        if collectionView.tag < 1000000 {
        
        
//        if no data for the events exists yet then do not display any cells in the collectionView
        if (sectionUserHostedEvents.count + sectionUpcomingEvents.count + sectionPastEvents.count) == 0 {
           
            numberOfItemsForSection = 0
            
        }
        
//        The number of cells in the collectionView is determined by the count of dates in the event. The section is determined by the tag. A check is performed to ensure the event has data
        else if collectionView.tag < 100 && sectionUserHostedEvents.count != 0{

            numberOfItemsForSection = sectionUserHostedEvents[(collectionView.tag - 1)].startDateArray.count

        }
        else if collectionView.tag < 10000 && sectionUpcomingEvents.count != 0{

          numberOfItemsForSection = sectionUpcomingEvents[(collectionView.tag - 1)/100].startDateArray.count

        }
        else if collectionView.tag < 1000000 && sectionPastEvents.count != 0{
            
            
            numberOfItemsForSection = sectionPastEvents[(collectionView.tag - 1)/10000].startDateArray.count
            
            
        }
        else{
            
          numberOfItemsForSection = 0
        }
            
        
        return numberOfItemsForSection
            
        }
            
//        collectionView for invitee names
        else{
            
            if (sectionUserHostedEvents.count + sectionUpcomingEvents.count + sectionPastEvents.count) == 0 {
                       
                
            print("no data for invitee names")
                        numberOfItemsForSection = 1
                        
                    }
                    
            //        The number of cells in the collectionView is determined by the count of dates in the event. The section is determined by the tag. A check is performed to ensure the event has data
                    else if collectionView.tag < 100000000 && sectionUserHostedEvents.count != 0{
                
                print("data for invitee names - your events")

                numberOfItemsForSection = sectionUserHostedEvents[(collectionView.tag - 1)/1000000].inviteeNamesArray.count

                    }
                    else if collectionView.tag < 10000000000 && sectionUpcomingEvents.count != 0{
                
                print("data for invitee names - upcoming events")

                      numberOfItemsForSection = sectionUpcomingEvents[(collectionView.tag - 1)/100000000].inviteeNamesArray.count

                    }
                    else if collectionView.tag < 1000000000000 && sectionPastEvents.count != 0{
                        
                
                print("data for invitee names - missed events")
                        
                        numberOfItemsForSection = sectionPastEvents[(collectionView.tag - 1)/10000000000].inviteeNamesArray.count
                        
                        
                    }
                    else{
                        
                      numberOfItemsForSection = 0
                    }
                        
                    
                    return numberOfItemsForSection
            
        }
        
    }
    
    
//    number of rows in the collectionview
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        
        
        
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("collectionView.tag: \(collectionView.tag)")
        

        if collectionView.tag < 1000000 {

            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCreatedDatesCell", for: indexPath) as? UserCreatedCollectionViewCell else{
                
                fatalError()
            }
            
        
        cell.lblUserCreatedDates.font = .systemFont(ofSize: 13)
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        cell.backgroundColor = UIColor.white
        
            
        if (sectionUserHostedEvents.count + sectionUpcomingEvents.count + sectionPastEvents.count) == 0 {
           
            print("sectionUpcoming not populated")

            cell.lblUserCreatedDates.text = "loading"
            
        }
            
        else if collectionView.tag < 100 && sectionUserHostedEvents.count != 0{


            cell.lblUserCreatedDates.text = sectionUserHostedEvents[(collectionView.tag - 1)].startDateArray[indexPath.row]

        }
        else if collectionView.tag < 10000 && sectionUpcomingEvents.count != 0{



            cell.lblUserCreatedDates.text = sectionUpcomingEvents[(collectionView.tag - 1)/100].startDateArray[indexPath.row]


        }
        else if collectionView.tag < 1000000 && sectionPastEvents.count != 0{
            
//            cell.lblUserCreatedDates.text = "loading"
             

            cell.lblUserCreatedDates.text = sectionPastEvents[(collectionView.tag - 1)/10000].startDateArray[indexPath.row]
            
            
        }
        else{
            
         cell.lblUserCreatedDates.text = "Loading"
            
            
        }
            
            return cell
   
        }
        
        else{

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCreatedNamesCell",
                                                                for: indexPath) as? UserCreatedEventsInviteesCollectionViewCell else {
                                                                    fatalError()

            }

            cell.lblInviteeNames.font = .systemFont(ofSize: 13)

            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 5

            cell.backgroundColor = UIColor.white
            
            
            if (sectionUserHostedEvents.count + sectionUpcomingEvents.count + sectionPastEvents.count) == 0 {
                       
                        print("no data for invitee names")

                        cell.lblInviteeNames.text = "loading"
                        
                    }
                        
                    else if collectionView.tag < 100000000 && sectionUserHostedEvents.count != 0{
                
                print("user hosted invitee names - \(sectionUserHostedEvents[(collectionView.tag - 1)/1000000].inviteeNamesArray[indexPath.row])")


                cell.lblInviteeNames.text = sectionUserHostedEvents[(collectionView.tag - 1)/1000000].inviteeNamesArray[indexPath.row]

                    }
                    else if collectionView.tag < 10000000000 && sectionUpcomingEvents.count != 0{
                
                print("user hosted invitee names - \(sectionUpcomingEvents[(collectionView.tag - 1)/100000000].inviteeNamesArray[indexPath.row])")

                        cell.lblInviteeNames.text = sectionUpcomingEvents[(collectionView.tag - 1)/100000000].inviteeNamesArray[indexPath.row]


                    }
                    else if collectionView.tag < 1000000000000 && sectionPastEvents.count != 0{
                        
            //            cell.lblUserCreatedDates.text = "loading"
                         
                print("user hosted invitee names - \(sectionPastEvents[(collectionView.tag - 1)/10000000000].inviteeNamesArray[indexPath.row])")

                        cell.lblInviteeNames.text = sectionPastEvents[(collectionView.tag - 1)/10000000000].inviteeNamesArray[indexPath.row]
                        
                        
                    }
                    else{
                        
                     cell.lblInviteeNames.text = "Loading"
                        
                        
                    }



            return cell


        }
        
        
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 20, height: 20)
    }
    
    
    
    
}



