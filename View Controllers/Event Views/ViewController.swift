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
import CoreData

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
        
//        function to populate any non populated availability
        nonRespondedEvents()
        
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        self.view.backgroundColor = UIColor(red: 253, green: 253, blue: 253)
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
//        setting to allow the add event image to be used as a button
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
    
    override func viewDidAppear(_ animated: Bool) {
        userCreatedEvents.reloadData()
    }
    

    
    //    function to get any updated data once the table is pulled down
    @objc func refreshCreated(_ sender: Any) {
        getUsersCreatedEvents()
        refreshControlCreated.endRefreshing()
    }
    
//    MARK: code to pull down all events and then display them
        func getUsersCreatedEvents(){
            
//            DUMMY predicate
            let serialisedEvents = serialiseEvents(predicate: NSPredicate(format: "eventOwner = %@", user!), usePredicate: false)
            
    //      filter the serilaised events for events hosted by the user and in the pending status
         sectionUserHostedEvents = filteringEventsForDisplay(pending: true, createdByUser: true, pastEvents: false, serialisedEvents: serialisedEvents)
            
    //      filter the serilaised events for events not hosted by the user and in the pending status
            sectionUpcomingEvents = filteringEventsForDisplay(pending: true, createdByUser: false, pastEvents: false, serialisedEvents: serialisedEvents)
            
    //      filter the serilaised events for events not hosted by the user and in the pending status, but in the past
            sectionPastEvents = filteringEventsForDisplay(pending: true, createdByUser: false, pastEvents: true, serialisedEvents: serialisedEvents) + filteringEventsForDisplay(pending: true, createdByUser: true, pastEvents: true, serialisedEvents: serialisedEvents)
            
        }

//    reloads the table views whenever the page apears, this ensures it refreshes when a user creates a new event
        override func viewWillAppear(_ animated: Bool) {
            getUsersCreatedEvents()
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
                        
                cell.userCreatedCellLabel3.text = ("\(convertToLocalTime(inputTime: item.eventStartTime)) - \(convertToLocalTime(inputTime: item.eventEndTime))")
                        
//                        check if there is an outstanding chat message
                if chatNotificationiDs.contains(item.eventID) == true{
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
                                cell.userCreatedCellLabel2.text =  item.eventLocation
                                
                        cell.userCreatedCellLabel3.text = ("\(convertToLocalTime(inputTime: item.eventStartTime)) - \(convertToLocalTime(inputTime: item.eventEndTime))")
                        
                //                        check if there is an outstanding chat message
                if chatNotificationiDs.contains(item.eventID) == true{
                    
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
            if indexPath.section == 2{
              
                item = sectionPastEvents[indexPath.row]
                        let eventTitleDescription = NSMutableAttributedString(string: item.eventDescription,
                                                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
                            eventTitleDescription.append(NSMutableAttributedString(string: " by: \(item.eventOwnerName)",
                                                                               attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
                            
                            
                        cell.userCreatedCellLabel1.attributedText = eventTitleDescription
                                cell.userCreatedCellLabel2.text =  item.eventLocation
                                
                        cell.userCreatedCellLabel3.text = ("\(convertToLocalTime(inputTime: item.eventStartTime)) - \(convertToLocalTime(inputTime: item.eventEndTime))")
    
                //                        check if there is an outstanding chat message
                if chatNotificationiDs.contains(item.eventID) == true{
                    
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
        let segue = "splitViewResultsController"
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
        loadingNotification.label.text = "Loading"
        loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
        loadingNotification.mode = MBProgressHUDMode.customView
        
        if (sectionPastEvents.count + sectionUpcomingEvents.count + sectionUserHostedEvents.count) == 0{
            
        }
        else{
        if indexPath.section == 0{
//            set shared property to pass the event selected to other page
            currentUserSelectedEvent = sectionUserHostedEvents[indexPath.row]

            if currentUserSelectedEvent.newChatMessage == true{
                newMessageNotification = true
            }
            else{
            
            newMessageNotification = false
            
            }
            
            currentUserSelectedAvailability = serialiseAvailability(eventID: currentUserSelectedEvent.eventID)
            self.prepareForEventDetailsPageCD(segueName: segue, isSummaryView: false, performSegue: true, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                
                loadingNotification.hide(animated: true)
            }
            
        }
          else if indexPath.section == 1{
        currentUserSelectedEvent = sectionUpcomingEvents[indexPath.row]
            
            
            if currentUserSelectedEvent.newChatMessage == true{
                newMessageNotification = true
            }
            else{
            
            newMessageNotification = false
            
            }
            currentUserSelectedAvailability = serialiseAvailability(eventID: currentUserSelectedEvent.eventID)
            self.prepareForEventDetailsPageCD(segueName: segue, isSummaryView: false, performSegue: true, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                
                loadingNotification.hide(animated: true)
            }
            
                    }
        else if indexPath.section == 2{
            
            currentUserSelectedEvent = sectionPastEvents[indexPath.row]
            if currentUserSelectedEvent.newChatMessage == true{
                newMessageNotification = true
            }
            else{
            newMessageNotification = false
            }
            
           currentUserSelectedAvailability = serialiseAvailability(eventID: currentUserSelectedEvent.eventID)
           self.prepareForEventDetailsPageCD(segueName: segue, isSummaryView: false, performSegue: true, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
               
               loadingNotification.hide(animated: true)
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

            numberOfItemsForSection = sectionUserHostedEvents[(collectionView.tag - 1)].startDatesDisplay.count

        }
        else if collectionView.tag < 10000 && sectionUpcomingEvents.count != 0{

          numberOfItemsForSection = sectionUpcomingEvents[(collectionView.tag - 1)/100].startDatesDisplay.count

        }
        else if collectionView.tag < 1000000 && sectionPastEvents.count != 0{
            
            
            numberOfItemsForSection = sectionPastEvents[(collectionView.tag - 1)/10000].startDatesDisplay.count
            
            
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

                numberOfItemsForSection = sectionUserHostedEvents[(collectionView.tag - 1)/1000000].currentUserNames.count + sectionUserHostedEvents[(collectionView.tag - 1)/1000000].nonUserNames.count

                    }
                    else if collectionView.tag < 10000000000 && sectionUpcomingEvents.count != 0{
                
                print("data for invitee names - upcoming events")

                      numberOfItemsForSection = sectionUpcomingEvents[(collectionView.tag - 1)/100000000].currentUserNames.count + sectionUpcomingEvents[(collectionView.tag - 1)/100000000].nonUserNames.count

                    }
                    else if collectionView.tag < 1000000000000 && sectionPastEvents.count != 0{
                        
                
                print("data for invitee names - missed events")
                        
                        numberOfItemsForSection = sectionPastEvents[(collectionView.tag - 1)/10000000000].currentUserNames.count + sectionPastEvents[(collectionView.tag - 1)/10000000000].nonUserNames.count
                        
                        
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


            cell.lblUserCreatedDates.text = sectionUserHostedEvents[(collectionView.tag - 1)].startDatesDisplay[indexPath.row]

        }
        else if collectionView.tag < 10000 && sectionUpcomingEvents.count != 0{



            cell.lblUserCreatedDates.text = sectionUpcomingEvents[(collectionView.tag - 1)/100].startDatesDisplay[indexPath.row]


        }
        else if collectionView.tag < 1000000 && sectionPastEvents.count != 0{
            
//            cell.lblUserCreatedDates.text = "loading"
             

            cell.lblUserCreatedDates.text = sectionPastEvents[(collectionView.tag - 1)/10000].startDatesDisplay[indexPath.row]
            
            
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
                let nameArray = sectionUserHostedEvents[(collectionView.tag - 1)/1000000].currentUserNames + sectionUserHostedEvents[(collectionView.tag - 1)/1000000].nonUserNames


                cell.lblInviteeNames.text = nameArray[indexPath.row]

                    }
                    else if collectionView.tag < 10000000000 && sectionUpcomingEvents.count != 0{
                let nameArray = sectionUpcomingEvents[(collectionView.tag - 1)/100000000].currentUserNames + sectionUpcomingEvents[(collectionView.tag - 1)/100000000].nonUserNames

                        cell.lblInviteeNames.text = nameArray[indexPath.row]

                    }
                    else if collectionView.tag < 1000000000000 && sectionPastEvents.count != 0{
                     let nameArray = sectionPastEvents[(collectionView.tag - 1)/10000000000].currentUserNames + sectionPastEvents[(collectionView.tag - 1)/10000000000].nonUserNames

                        cell.lblInviteeNames.text = nameArray[indexPath.row]
                        
                        
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



