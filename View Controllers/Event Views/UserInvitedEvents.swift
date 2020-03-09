//
//  UserInvitedEvents.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 02/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD


var currentUserSelectedEvent = eventSearch()
var currentUserSelectedAvailability = [AvailabilityStruct]()

class UserInvitedEvents: UIViewController, UITableViewDataSource, UITableViewDelegate {

//    general variables
    var startDate = Date()
    var endDate = Date()
    var datesBetweenChosenDatesStart = Array<Date>()
    var numberOfDatesInArray = 0
    var dateFormatterSimple = DateFormatter()
    var dateFormatterForResults = DateFormatter()
    var noResultsArray = Array<Any>()
    var sectionUpcomingEvents = [eventSearch]()
    var sectionPastEvents = [eventSearch]()
    
//    variable for refreshing the UITableViews on pull down
    var refreshControlCreated   = UIRefreshControl()
    
//    date formatters
    var dateFormatter = DateFormatter()
    let dateFormatterTime = DateFormatter()
  
    
    @IBOutlet var userInvitedEvents: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        updateDateChosenNotificationStatus()
        
//        navigation bar setup

        navigationItem.titleView = setAppHeader(colour: UIColor.black)
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        
        self.view.backgroundColor = UIColor(red: 253, green: 253, blue: 253)
        self.userInvitedEvents.separatorStyle = UITableViewCell.SeparatorStyle.none

        
//        tableviewsetup
        userInvitedEvents.delegate = self
        userInvitedEvents.dataSource = self
        userInvitedEvents.rowHeight = 150
        
//        get the users invited events once the page loads
        getUsersInvtedEvents()
        
//        set date fromatters
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterForResults.dateFormat = "E d MMM"
        dateFormatterTime.dateFormat = "HH:mm"
        
        
        
        // Refresh control add in tableview.
        refreshControlCreated.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlCreated.addTarget(self, action: #selector(refreshCreated), for: .valueChanged)
        self.userInvitedEvents.addSubview(refreshControlCreated)
        
        //        The end of the viewDidLoad
    }
    
//   reload data to ensure the chat notification dissapear
    override func viewDidAppear(_ animated: Bool) {
        userInvitedEvents.reloadData()
    }
    
    //    function to get any updated data once the table is pulled down
    @objc func refreshCreated(_ sender: Any) {
        
        print("user pulled to refresh the userinvited table")
        
        getUsersInvtedEvents()
        refreshControlCreated.endRefreshing()
        
    }
    
    
    
    //    MARK: code to pull down the events the user is invited to and display them
    @objc func getUsersInvtedEvents(){
        
        

        //            DUMMY predicate
        let serialisedEvents = serialiseEvents(predicate: NSPredicate(format: "eventOwner = %@", user!), usePredicate: false)
                        
//      filter the serilaised events for events hosted by the user and not in the pending status
        sectionUserHostedEvents = filteringEventsForDisplay(pending: false, createdByUser: true, pastEvents: false, serialisedEvents: serialisedEvents)
                        
//      filter the serilaised events for events not hosted by the user and not in the pending status
        sectionUpcomingEvents = filteringEventsForDisplay(pending: false, createdByUser: false, pastEvents: false, serialisedEvents: serialisedEvents)
                        
//      filter the serilaised events for events not hosted by the user and not in the pending status, but in the past
        sectionPastEvents = filteringEventsForDisplay(pending: false, createdByUser: false, pastEvents: true, serialisedEvents: serialisedEvents) + filteringEventsForDisplay(pending: false, createdByUser: true, pastEvents: true, serialisedEvents: serialisedEvents)
        
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

            
                guard let cell = userInvitedEvents.dequeueReusableCell(withIdentifier: "userInvitedCell", for: indexPath) as? UserInvitedEventsCell
                    else{
                        fatalError("failed to create user created events cell")
            }
            
            
            cell.selectionStyle = .none
            
            cell.userInvitedCellLabel1.adjustsFontSizeToFitWidth = true
            cell.userInvitedCellLabel2.adjustsFontSizeToFitWidth = true
            cell.userInvitedCellLabel3.adjustsFontSizeToFitWidth = true
            cell.userInvitedCellLabel4.adjustsFontSizeToFitWidth = true
            
            if (sectionPastEvents.count + sectionUpcomingEvents.count + sectionUserHostedEvents.count) == 0{
                
                cell.userInvitedCellLabel2.text = "Here you'll see your confirmed events"
                cell.userInvitedCellLabel3.text = ""
                cell.userInvitedCellLabel4.text = "Create an event to get started"
                cell.userInvitedCellLabel1.text = ""
                cell.imgChatNotification.isHidden = true
            }
            else{
                cell.accessoryType = .none
                cell.backgroundColor = UIColor.white
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 0.5
                cell.clipsToBounds = true
            
                if indexPath.section == 0{
                  
                    item = sectionUserHostedEvents[indexPath.row]

                            let eventTitleDescription = NSMutableAttributedString(string: item.eventDescription,
                                                                                      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
                                eventTitleDescription.append(NSMutableAttributedString(string: " by: \(item.eventOwnerName)",
                                                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
                                
                            cell.userInvitedCellLabel1.attributedText = eventTitleDescription
                            cell.userInvitedCellLabel2.text =  item.eventLocation
                            cell.userInvitedCellLabel4.text = ("\(convertToLocalTime(inputTime: item.eventStartTime)) - \(convertToLocalTime(inputTime: item.eventEndTime))")
                            cell.userInvitedCellLabel3.text = dateTZToDisplayDate(date: item.chosenDate)
                    
                    
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
                    
                }
                if indexPath.section == 1{
                  
                    item = sectionUpcomingEvents[indexPath.row]
                            let eventTitleDescription = NSMutableAttributedString(string: item.eventDescription,
                                                                                      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
                                eventTitleDescription.append(NSMutableAttributedString(string: " by: \(item.eventOwnerName)",
                                                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
                                
                                
                            cell.userInvitedCellLabel1.attributedText = eventTitleDescription
                            cell.userInvitedCellLabel2.text = ("\(item.eventLocation) \n\(item.eventStartTime) - \(item.eventEndTime)")
                            cell.userInvitedCellLabel4.text = ("\(convertToLocalTime(inputTime: item.eventStartTime)) - \(convertToLocalTime(inputTime: item.eventEndTime))")
                            cell.userInvitedCellLabel3.text = dateTZToDisplayDate(date: item.chosenDate)
                    
                    
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
                             
                }
                if indexPath.section == 2{
                  
                    item = sectionPastEvents[indexPath.row]
                            let eventTitleDescription = NSMutableAttributedString(string: item.eventDescription,
                                                                                      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
                                eventTitleDescription.append(NSMutableAttributedString(string: " by: \(item.eventOwnerName)",
                                                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
                                
                                
                            cell.userInvitedCellLabel1.attributedText = eventTitleDescription
                            cell.userInvitedCellLabel2.text = ("Location: \(item.eventLocation) \nTime: \(item.eventStartTime) - \(item.eventEndTime)")
                            cell.userInvitedCellLabel4.text = ("\(convertToLocalTime(inputTime: item.eventStartTime)) - \(convertToLocalTime(inputTime: item.eventEndTime))")
                            cell.userInvitedCellLabel3.text = dateTZToDisplayDate(date: item.chosenDate)
                    
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
                }
            }
            
            
            cell.setCircledCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row, forSection: indexPath.section)
               
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
                
              sectionHeaders.append("Past Events")
                
            }
                
                label.frame = CGRect(x: 16, y: 5, width: screenWidth - 16, height: 40)
                label.text = sectionHeaders[section]
                headerView.addSubview(label)
                
                return headerView
            }
        
    
    
    
//    didselect row at
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("You selected cell #\(indexPath.section)!")
            eventResultsArrayDetails.removeAll()
            anyArray.removeAll()
            
            let segue = "circledEventsSplitViewSegue"

            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Loading"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
            loadingNotification.mode = MBProgressHUDMode.customView
            
            if (sectionPastEvents.count + sectionUpcomingEvents.count + sectionUserHostedEvents.count) == 0 {
                
            }
            else{
            if indexPath.section == 0{
//                set shared property to pass the event selected to other page
                currentUserSelectedEvent = sectionUserHostedEvents[indexPath.row]
                //            reset the non user invitees to ensure we don't carry over any non saved changes from previous view of the edit page
                userInvitedEvents.deselectRow(at: indexPath, animated: false)
 
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
                            userInvitedEvents.deselectRow(at: indexPath, animated: false)
                
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
                
                currentUserSelectedEvent = sectionPastEvents[indexPath.row]
                userInvitedEvents.deselectRow(at: indexPath, animated: false)
                
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

                }}}}


extension UserInvitedEvents: UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    //    the number of columns in the collectionview
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

            
            var numberOfItemsForSection = Int()
            
            
            print("collectionView.tag: \(collectionView.tag)")
            
            
            
    //        if no data for the events exists yet then do not display any cells in the collectionView
            if (sectionUserHostedEvents.count + sectionUpcomingEvents.count + sectionPastEvents.count) == 0 {
               
                numberOfItemsForSection = 0
                
            }
            
    //        The number of cells in the collectionView is determined by the count of dates in the event. The section is determined by the tag. A check is perfomed to ensure the event has data
            else if collectionView.tag < 100 && sectionUserHostedEvents.count != 0{

                numberOfItemsForSection = sectionUserHostedEvents[(collectionView.tag - 1)].currentUserNames.count + sectionUserHostedEvents[(collectionView.tag - 1)].nonUserNames.count

            }
            else if collectionView.tag < 10000 && sectionUpcomingEvents.count != 0{

              numberOfItemsForSection = sectionUpcomingEvents[(collectionView.tag - 1)/100].currentUserNames.count + sectionUpcomingEvents[(collectionView.tag - 1)/100].nonUserNames.count

            }
            else if collectionView.tag < 1000000 && sectionPastEvents.count != 0{
                
                
                numberOfItemsForSection = sectionPastEvents[(collectionView.tag - 1)/10000].currentUserNames.count + sectionPastEvents[(collectionView.tag - 1)/10000].nonUserNames.count

                
                
            }
            else{
                
              numberOfItemsForSection = 0
            }
                
            
            return numberOfItemsForSection
                
            
        }
        
        
    //    number of rows in the collectionview
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            
            
            
            
            return 1
        }
        
        
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            print("collectionView.tag: \(collectionView.tag)")
            


                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "circledEventsCell", for: indexPath) as? CircledEventsCollectionViewCell else{
                    
                    fatalError()
                }
                
            
            cell.lblCircledInvitees.font = .systemFont(ofSize: 13)
            
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 5
            
            cell.backgroundColor = UIColor.white
            
                
            if (sectionUserHostedEvents.count + sectionUpcomingEvents.count + sectionPastEvents.count) == 0 {
               
                print("sectionUpcoming not populated")

                cell.lblCircledInvitees.text = "loading"
                
            }
                
            else if collectionView.tag < 100 && sectionUserHostedEvents.count != 0{
                
                let nameArray = sectionUserHostedEvents[(collectionView.tag - 1)].currentUserNames + sectionUserHostedEvents[(collectionView.tag - 1)].nonUserNames
                cell.lblCircledInvitees.text = nameArray[indexPath.row]

            }
            else if collectionView.tag < 10000 && sectionUpcomingEvents.count != 0{
                let nameArray = sectionUpcomingEvents[(collectionView.tag - 1)/100].currentUserNames + sectionUpcomingEvents[(collectionView.tag - 1)/100].nonUserNames

               cell.lblCircledInvitees.text = nameArray[indexPath.row]


            }
            else if collectionView.tag < 1000000 && sectionPastEvents.count != 0{
                
                let nameArray = sectionPastEvents[(collectionView.tag - 1)/10000].currentUserNames + sectionPastEvents[(collectionView.tag - 1)/10000].nonUserNames
                 

                cell.lblCircledInvitees.text = nameArray[indexPath.row]
                
                
            }
            else{
                
             cell.lblCircledInvitees.text = "Loading"
                
                
            }
                return cell
        }
  
    
}
