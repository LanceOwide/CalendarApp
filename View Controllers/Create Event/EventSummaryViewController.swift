//
//  EventSummaryViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 14/10/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import DLRadioButton
import MBProgressHUD
import Firebase
import Alamofire


var summaryView = Bool()

class EventSummaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    //    variable to describe the time, in seconds, from GMT of the user
        var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
        
    //    other variables
        var userIDArray = Array<String>()
        var fireStoreRef: DocumentReference? = nil
        var myAddedUserName = String()
        var userNameArray = Array<String>()
        var myAddedUserID = String()
    
    
    @IBOutlet weak var inviteesTableView: UITableView!
    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    
    @IBOutlet weak var endDateLabel: UILabel!
    

    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        
        //        setup the navigation controller Planr text
        
        navigationItem.titleView = setAppHeader(colour: UIColor.black)
        
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        
        self.view.backgroundColor = UIColor(red: 253, green: 253, blue: 253)
        
        
        inviteesTableView.delegate = self
        inviteesTableView.dataSource = self
        
        inviteesTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        inviteesTableView.backgroundColor = UIColor(red: 253, green: 253, blue: 253)

        inviteesTableView.rowHeight = 51
        
        
//        set the text of each label
        
        titleLabel.text = newEventDescription
        
        locationLabel.text = newEventLocation
        
        startTimeLabel.text = convertToLocalTime(inputTime: newEventStartTime)
        
        endTimeLabel.text = convertToLocalTime(inputTime: newEventEndTime)
        
        startDateLabel.text = convertToStringDateDisplay(inputDate: newEventStartDate)
        
        endDateLabel.text = convertToStringDateDisplay(inputDate: newEventEndDate)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneSelected))


    }
    
    @objc func doneSelected(){
        
        summaryView = true
        selectEventToggle = 1
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
        loadingNotification.label.text = "Creating Event"
        loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
        loadingNotification.mode = MBProgressHUDMode.customView
        

        addEventToEventStore(){
            
            
            self.addDatesToResultQuery2(eventID: eventIDChosen, selectEventToggle: 0){ (arrayForEventResultsPage, arrayForEventResultsPageDetails, numberOfDatesInArray)  in
            
            
            
            let noResultsArray = self.noResultArrayCompletion2(numberOfDatesInArray: numberOfDatesInArray).noResultsArray
            let nonUserArray = self.noResultArrayCompletion2(numberOfDatesInArray: numberOfDatesInArray).nonUserArray
            
            self.addUserToEventArray2(eventID: eventIDChosen, noResultArray: noResultsArray){ (arrayForEventResultsPageAvailability, arrayOfUserDocumentIDs) in
                
                self.addNonExistentUsers(eventID: eventIDChosen, noResultArray: nonUserArray){ (addNonExistentUsersAvailability, nonExistentNames, nonExistentPhoneNumbers) in
                
                    eventResultsArrayDetails = arrayForEventResultsPageDetails + [nonExistentNames] + [nonExistentPhoneNumbers] + [arrayOfUserDocumentIDs]
                    print("eventResultsArrayDetails \(eventResultsArrayDetails)")
                    
                    let resultsSummary = self.resultsSummary(resultsArray: arrayForEventResultsPage + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability).countedResults
                    
                    fractionResults = self.resultsSummary(resultsArray: arrayForEventResultsPage + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability).fractionResults
                    
                    
                    
                    availabilitySummaryArray = resultsSummary
                    
                    print("resultsSummaryArray: \(resultsSummary)")
                    
                    loadingNotification.hide(animated: true)
                    
                    
                arrayForEventResultsPageFinal = arrayForEventResultsPage + resultsSummary + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability
                print("arrayForEventResultsPageFinal \(arrayForEventResultsPageFinal)")
                    
                    
                }}}}}
    
    
    
    @IBAction func donePictureButton(_ sender: UIButton) {
        
        doneSelected()
        
    }
    
    
    
      func numberOfSections(in tableView: UITableView) -> Int {

              return contactsSelected.count
      }
      
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
              
      return 1
    
      }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = inviteesTableView.dequeueReusableCell(withIdentifier: "inviteesCell", for: indexPath) as? SummaryCellTableViewCell
            else{
                fatalError("failed to create user created events cell")
        }
        
        let item = contactsSelected[indexPath.section]
        
            cell.inviteeNameLabel.text = item.name

            cell.backgroundColor = UIColor.white
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 0
            cell.clipsToBounds = true
        
        cell.inviteeNameLabel.adjustsFontSizeToFitWidth = true
        
        
        return cell
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cellSpacingHeight: CGFloat = 10
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func addEventToEventStore(completion: @escaping () -> Void){
            notExistingUserArray.removeAll()
            var selectedPhoneNumbers = [String]()
            var selectedNames = [String]()
            let currentUserID = Auth.auth().currentUser?.uid
            let eventOwnerName = UserDefaults.standard.string(forKey: "name")

            eventQuery { (eventID) in
                print("event commited to the database")
                print("eventID: \(eventID)")
                
                eventIDChosen = eventID
            
            selectedPhoneNumbers = self.getSelectedContactsPhoneNumbers2().phoneNumbers
            selectedNames = self.getSelectedContactsPhoneNumbers2().names
            
            self.createUserIDArrays(phoneNumbers: selectedPhoneNumbers, names: selectedNames) { (nonExistentArray, existentArray, userNameArray, nonExistentNameArray) in
                
                print("nonExistentArray \(nonExistentArray)")
                print("existentArray \(existentArray)")
                
                //           adds the non users to the database
                self.addNonExistingUsers2(phoneNumbers: nonExistentArray, eventID: eventID, names: nonExistentNameArray)
                
                //            Adds the user event link to the userEventStore
                
                self.userEventLinkArray(userID: existentArray + [currentUserID!], userName: userNameArray + [eventOwnerName ?? ""], eventID: eventID)
                
                self.addUserIDsToEventRequests(userIDs: existentArray, currentUserID: [currentUserID!], existingUserIDs: [], eventID: eventID, addCurrentUser: true, currentUserNames: userNameArray, nonUserNames: nonExistentNameArray)
                
//                Add a notification to the notificaiton table for each user invited to the event
                self.eventCreatedNotification(userIDs: existentArray + [user!], eventID: eventID)
                
                
                if nonExistentArray.isEmpty == false{
                    
                print("there are some invitees that arent users")
                    
                    
                    nonExistingUsers = nonExistentNameArray
                    nonExistingNumbers = nonExistentArray
                    
                    self.eventAdditionComplete()
                    
                    
                    contactsSelected.removeAll()
                    inviteesNamesNew.removeAll()
                    contactsSorted.removeAll()
                    contactsFiltered.removeAll()
                    completion()

                }
                else{
                    
                    print("there are no invitees that arent users")
                    
                    self.eventAdditionComplete()
                        contactsSelected.removeAll()
                        inviteesNamesNew.removeAll()
                        contactsSorted.removeAll()
                        contactsFiltered.removeAll()
                    completion()
                    
      
                }

                }

            }
            
        }

        
    //    get the phone numbers of the users selected for the event
        func getSelectedContactsPhoneNumbers( completion: @escaping () -> Void){
            selectedContacts.removeAll()
            
            getCurrentUsersPhoneNumber {
                
                
                for contact in contactsSelected{
                    if contact.selectedContact == true {
                        
                        let phoneNumber = contact.phoneNumber
                        
                        let cleanPhoneNumber = self.cleanPhoneNumbers(phoneNumbers: phoneNumber)
                        
                            selectedContacts.append(cleanPhoneNumber)
                        }}
                print("Selected Contacts Phone Numbers \(selectedContacts)")
                completion()
                
            }}
        
        

        
    //    get the current users phone number
        func getCurrentUsersPhoneNumber( completion: @escaping () -> Void){
            
            dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments{ (querySnapshot, error) in
                if error != nil {
                    print("Error getting documents: \(error!)")
                }
                else {
                    for document in querySnapshot!.documents{
                        let usersPhoneNumber = document.get("phoneNumber")
                        selectedContacts.append(usersPhoneNumber as! String)
                        print("Current users phone number to add to selected contacts \(selectedContacts)")
                    }}
                completion()
            }}
        
        
        
        
        //    Adds the new event into the evetRequests table
        func eventQuery( completion: @escaping (_ eventID: String) -> Void){
            
            let timestamp = NSDate().timeIntervalSince1970
            let eventOwnerName = UserDefaults.standard.string(forKey: "name")
            
            getStartAndEndDates3(startDate: newEventStartDate, endDate: newEventEndDate, startTime: newEventStartTimeLocal, endTime: newEventEndTimeLocal, daysOfTheWeek: daysOfTheWeekNewEvent){(startDates,endDates) in
                
                let eventSearchArray: [String:Any] = ["startDateInput": newEventStartDate,"endDateInput": newEventEndDate,"startTimeInput": newEventStartTime,"endTimeInput": newEventEndTime,"daysOfTheWeek": daysOfTheWeekNewEvent,"isAllDay": "0","users": self.userIDArray, "eventOwner": user!, "location": newEventLocation, "eventDescription": newEventDescription, "timeStamp": timestamp, "eventOwnerName":  eventOwnerName ?? "", "secondsFromGMT": self.secondsFromGMT/3600, "startDates": startDates, "endDates": endDates, "locationLongitude": newEventLongitude, "locationLatitude": newEventLatitude]
                
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
                    ref.child("invitedUsers").setValue(self.userIDArray)
                    
                    print("eventID from eventQuery \(eventCreationID)")
                    completion(eventCreationID)
                    
                }
            }
   
        }
}
