//
//  EventEditViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 09/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import DLRadioButton



class EventEditViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UIPopoverPresentationControllerDelegate, CellSubclassDelegate {

    
    var dateFormatter = DateFormatter()
    var dateFormatterTime = DateFormatter()
    private var timePicker: UIDatePicker?
    private var datePicker: UIDatePicker?
    var dateFormatterDay = DateFormatter()
    var dateFormatterString = DateFormatter()

    

    @IBOutlet var eventTitle: UITextField!
    @IBOutlet var eventLoction: UITextField!
    @IBOutlet var eventStartTime: UITextField!
    @IBOutlet var eventEndTime: UITextField!
    @IBOutlet var eventStartDate: UITextField!
    @IBOutlet var eventEndDate: UITextField!
    @IBOutlet var invitees: UITableView!
    @IBOutlet weak var mondayButton: DLRadioButton!
    @IBOutlet weak var tuesdayButton: DLRadioButton!
    @IBOutlet weak var wednesdayButton: DLRadioButton!
    @IBOutlet weak var thursdayButton: DLRadioButton!
    @IBOutlet weak var fridayButton: DLRadioButton!
    @IBOutlet weak var saturdayButton: DLRadioButton!
    @IBOutlet weak var sundayButton: DLRadioButton!
    
    
    
    @IBAction func deleteEventPressed(_ sender: UIButton) {

        let alert = UIAlertController(title: "Delete event", message: "Are you sure you would like to delete the event? (this can't be undone)", preferredStyle: UIAlertController.Style.alert)
        
    
       alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { action in
            
            print("User yes on the event delete")
            
            self.deleteEventStore(eventID: currentUserSelectedEvent.eventID)
            self.deleteEventRequest(eventID: currentUserSelectedEvent.eventID)
            self.deleteTemporaryUserEventStore(eventID: currentUserSelectedEvent.eventID)
            self.deleteRealTimeDatabaseEventInfo(eventID: currentUserSelectedEvent.eventID)
            self.deleteRealTimeDatabaseUserEventLink(eventID: currentUserSelectedEvent.eventID)
            self.eventDeletedNotification(userIDs: currentUserSelectedEvent.users, eventID: currentUserSelectedEvent.eventID)
            
            self.performSegue(withIdentifier: "saveSelected", sender: Any.self)
  
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = setAppHeader(colour: UIColor.black)

        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
//        setup the time picker
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        timePicker = UIDatePicker()
        timePicker?.datePickerMode = .time
        createTimePicker()
        
//        setup the date picker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        createDatePicker()
        dateFormatterString.dateFormat = "yyyy-MM-dd"
        dateFormatterString.locale = Locale(identifier: "en_US_POSIX")
        
        dateFormatter.dateFormat = "dd MMM YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") 
        
//        setup tableview
        invitees.delegate = self
        invitees.dataSource = self
        self.invitees.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        

        //Looks for single or multiple taps.
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
//        view.addGestureRecognizer(tap)
        
        
        eventTitle.text = currentUserSelectedEvent.eventDescription
        eventLoction.text = currentUserSelectedEvent.eventLocation
        eventStartTime.text = convertToLocalTime(inputTime: currentUserSelectedEvent.eventStartTime)
        eventEndTime.text = convertToLocalTime(inputTime: currentUserSelectedEvent.eventEndTime)
        eventStartDate.text = convertToDisplayDate(inputDate: currentUserSelectedEvent.eventStartDate)
        eventEndDate.text = convertToDisplayDate(inputDate:currentUserSelectedEvent.eventEndDate)
        
        
        
        //        enable location popover
        eventLoction.addTarget(self, action: #selector(myTargetFunction), for: .allEditingEvents)
        
        //        listener to detect when the location has been chosen
        NotificationCenter.default.addObserver(self, selector: #selector(setLocationLabel), name: .locationSet, object: nil)
    
        
        
        let borderColour = UIColor(red: 250, green: 250, blue: 250)
        eventTitle.layer.borderColor = borderColour.cgColor
        eventTitle.layer.borderWidth = 1.0
        eventLoction.layer.borderColor = borderColour.cgColor
        eventLoction.layer.borderWidth = 1.0
        eventStartTime.layer.borderColor = borderColour.cgColor
        eventStartTime.layer.borderWidth = 1.0
        eventEndTime.layer.borderColor = borderColour.cgColor
        eventEndTime.layer.borderWidth = 1.0
        eventEndDate.layer.borderColor = borderColour.cgColor
        eventEndDate.layer.borderWidth = 1.0
        eventStartDate.layer.borderColor = borderColour.cgColor
        eventStartDate.layer.borderWidth = 1.0
        
        inviteesNamesLocation = currentUserSelectedEvent.users
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveSelected))
        
//        setup radio buttons
        
        self.mondayButton.isMultipleSelectionEnabled = true;
        self.tuesdayButton.isMultipleSelectionEnabled = true;
        self.wednesdayButton.isMultipleSelectionEnabled = true;
        self.thursdayButton.isMultipleSelectionEnabled = true;
        self.fridayButton.isMultipleSelectionEnabled = true;
        self.saturdayButton.isMultipleSelectionEnabled = true;
        self.sundayButton.isMultipleSelectionEnabled = true;
        setRatioButons()
        
        
//        adds the non user to the tableview
        checkForNonUsers()
    }
    
    
    
//    function to add the non users to the tableview
    func checkForNonUsers(){
//        check to see whether there is already data in the table, if there is then we do not update the table
        if currentUserSelectedEvent.nonUserNames.count != 0 || deletedNonUserInviteeNames.count != 0 && currentUserSelectedEvent.nonUserNames.count == 0 {
            
        }
        else{
            
        
            if currentUserSelectedEvent.nonUserNames.count == 0 {
//        nonUserInviteeNames = [""]

        }
        else{
            nonUserInviteeNames = currentUserSelectedEvent.nonUserNames
            }}}
    
    
//    set the rabio buttons status
    
    func setRatioButons(){
        
        let weekDayArray = currentUserSelectedEvent.daysOfTheWeekArray
        print("weekDayArray \(weekDayArray)")
        
        let sunday = weekDayArray[0]
        let monday = weekDayArray[1]
        let tuesday = weekDayArray[2]
        let wednesday = weekDayArray[3]
        let thursday = weekDayArray[4]
        let friday = weekDayArray[5]
        let saturday = weekDayArray[6]
        
        if sunday != 10{
            sundayButton.isSelected = true
        }
        if monday != 10{
            mondayButton.isSelected = true
        }
        if tuesday != 10{
            tuesdayButton.isSelected = true
        }
        if wednesday != 10{
            wednesdayButton.isSelected = true
        }
        if thursday != 10{
            thursdayButton.isSelected = true
        }
        if friday != 10{
            fridayButton.isSelected = true
        }
        if saturday != 10{
            saturdayButton.isSelected = true
        }
    }

    
//    //Calls this function when the tap is recognized.
//    @objc func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }
    
    @objc func setLocationLabel() {
     
     eventLoction.text = locationPassed
     
          
     }
    
    
    //    function to call show popover when location selected
    @objc func myTargetFunction(textField: UITextField) {
        
        let popController = storyboard?.instantiateViewController(withIdentifier: "locationSearchTableNavigation") as! UINavigationController

        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover

        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self


        // present the popover
        self.present(popController, animated: true, completion: nil)
    }
    
    
    @objc func saveSelected() {
        //the user selected to save the event
        
//        variable to hold a bool indicating whether the user needs to resend thier availability
        var sendAvailability = false
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        print("eventEndTime: \(eventEndTime.text ?? "")")
        print("eventStartTime: \(eventStartTime.text ?? "")")
        print("eventEndDate: \(eventEndDate.text ?? "")")
        print("eventStartDate: \(eventStartDate.text ?? "")")
         
        
        if eventTitle.text == "" {
            showProgressHUD(notificationMessage: "Please add an event title", imageName: "Unavailable", delay: 1)
        }
        else if eventStartDate.text == "" {
            showProgressHUD(notificationMessage: "Please add an event start date", imageName: "Unavailable", delay: 1)
        }
       else if eventEndDate.text == "" {
            showProgressHUD(notificationMessage: "Please add an end date", imageName: "Unavailable", delay: 1)
        }
        else if eventStartTime.text == "" {
            showProgressHUD(notificationMessage: "Please add an event start time", imageName: "Unavailable", delay: 1)
        }
       else if eventEndTime.text == "" {
            
            showProgressHUD(notificationMessage: "Please add an event end time", imageName: "Unavailable", delay: 1)
        }
            
       else if mondayButton.isSelected ==  false && tuesdayButton.isSelected ==  false && wednesdayButton.isSelected ==  false && thursdayButton.isSelected ==  false && fridayButton.isSelected ==  false && saturdayButton.isSelected ==  false && sundayButton.isSelected ==  false{
            
            showProgressHUD(notificationMessage: "Please select at least one day of the week", imageName: "Unavailable", delay: 1)
            
        }
            
       else if dateFormatter.date(from: eventEndDate.text!)!  < dateFormatter.date(from: eventStartDate.text!)! {
            
            showProgressHUD(notificationMessage: "Start date must be before end date", imageName: "Unavailable", delay: 1)
         }
            
       else if dateFormatterTime.date(from: eventEndTime.text!)! < dateFormatterTime.date(from: eventStartTime.text!)!{
            
            showProgressHUD(notificationMessage: "Start time must be before start time", imageName: "Unavailable", delay: 1)
            }
            
        else {
            
            daysOfTheWeekNewEvent.removeAll()
            
            //            create the event days of the week array
            
            if sundayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(0, at: 0)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 0)
            }
            if mondayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(1, at: 1)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 1)
            }
            if tuesdayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(2, at: 2)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 2)
            }
            if wednesdayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(3, at: 3)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 3)
            }
            if thursdayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(4, at: 4)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 4)
            }
            if fridayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(5, at: 5)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 5)
            }
            if saturdayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(6, at: 6)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 6)
            }
            print("daysOfTheWeekNewEvent: \(daysOfTheWeekNewEvent)")
            
//            convert the dates into the correct format
            
            let dateFormatterInput = DateFormatter()
            
            dateFormatterInput.dateFormat = "yyyy-MM-dd"
            dateFormatterInput.locale = Locale(identifier: "en_US_POSIX")
            
            let startDateInputDates = dateFormatter.date(from: eventStartDate.text!)
            let endDateInputDates = dateFormatter.date(from: eventEndDate.text!)
            let startDateInputString = dateFormatterInput.string(from: startDateInputDates!)
            let endDateInputString = dateFormatterInput.string(from: endDateInputDates!)
            
            let dateArray = getStartAndEndDates3NC(startDate: startDateInputString, endDate: endDateInputString, startTime: eventStartTime.text!, endTime: eventEndTime.text!, daysOfTheWeek: daysOfTheWeekNewEvent).0
//            check if there are any dates in between the chosen parameters
            print("the date in the array - dateArray \(dateArray.count)")
            if dateArray.count == 0{
            showProgressHUD(notificationMessage: "No dates in search period, adjust dates or days of the week ", imageName: "Unavailable", delay: 1)
            }
            else{
// checks to see whether the user has made any changes to the event timing
            if eventStartTime.text == convertToLocalTime(inputTime: currentUserSelectedEvent.eventStartTime) &&
                eventEndTime.text == convertToLocalTime(inputTime: currentUserSelectedEvent.eventEndTime) &&
                eventStartDate.text == convertToDisplayDate(inputDate: currentUserSelectedEvent.eventStartDate) &&
            eventEndDate.text == convertToDisplayDate(inputDate: currentUserSelectedEvent.eventEndDate) && currentUserSelectedEvent.daysOfTheWeekArray == daysOfTheWeekNewEvent {
//                set the bool to send amendAvailability to the event notifications DB

                showProgressHUD(notificationMessage: "Event Information Updated", imageName: "icons8-double-tick-100", delay: 2)
                
//                SAVE THE EVENT!!
//                saveTheEventInformation(startDateInputString: startDateInputString, endDateInputString: endDateInputString, sendAvailability: sendAvailability)
            
        }
            else{
//                if the date for the event has been chosen we want to confirm withe user that they want to continue
                if currentUserSelectedEvent.chosenDate == ""{
                    //            removes any availability arrays that have already been saved down
                    print("event timmings have changed")
                    sendAvailability = true
                    updateEventStoreAvailability(eventID: currentUserSelectedEvent.eventID)
                    
                    //                SAVE THE EVENT!!
//                    saveTheEventInformation(startDateInputString: startDateInputString, endDateInputString: endDateInputString, sendAvailability: sendAvailability)
                    
                    showProgressHUD(notificationMessage: "Event Information Updated - availability data reset", imageName: "icons8-double-tick-100", delay: 2)
                }
                else{
//                    show the user and alert
                          let alert = UIAlertController(title: "Changing search period", message: "You're about to change the search period for an event with a chosen date. This will remove the chosen date and notify everyone that you're searching for a new date", preferredStyle: UIAlertController.Style.alert)
                          
                      
                         alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: nil))
                          
                          alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { action in
                              print("User chose to continue")
                            sendAvailability = true
                            
                            //                SAVE THE EVENT!!
//                            self.saveTheEventInformation(startDateInputString: startDateInputString, endDateInputString: endDateInputString, sendAvailability: sendAvailability)
                            
                            self.updateEventStoreAvailability(eventID: currentUserSelectedEvent.eventID)
                            self.showProgressHUD(notificationMessage: "Event Information Updated - availability data reset", imageName: "icons8-double-tick-100", delay: 2)
                    
                          }))
                          
                          self.present(alert, animated: true, completion: nil)

                }
  
            }
    

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `1.0` to the desired number of seconds.
//            self.performSegue(withIdentifier: "saveSelected", sender: Any.self)
        }
            }}
        
//     save selected end
    }
    
    
//    func saveTheEventInformation(startDateInputString: String, endDateInputString: String, sendAvailability: Bool){
//                print("contactsSelected: \(contactsSelected)")
//                
//        //            MARK: loop through a series of checks to update the users invited to the event and save down the event
//                    
//        //        0. if the user didn't make any change so the event we can save down the new event information
//                    if deletedUserIDs.count == 0 && deletedNonUserInviteeNames.count == 0 && contactsSelected.count == 0{
//                        print("user didn't change the invitees")
//                        commitDataToDB(startDateInputString: startDateInputString, endDateInputString: endDateInputString, deletedUsers: false, deletedNonUser: false, addedNewInvitees: false, nonUserNames: [""], userNames: [""], userIDs: [""], amendAvailability: sendAvailability)
//                    }
//                    else{
//                    
//        //        1. Did the user delete users and non users and not add anyone?
//                if deletedUserIDs.count != 0 && deletedNonUserInviteeNames.count != 0 && contactsSelected.count == 0{
//                    deletedUsers{
//                        self.deletedNonUsers {
//                            self.commitDataToDB(startDateInputString: startDateInputString, endDateInputString: endDateInputString, deletedUsers: true, deletedNonUser: true, addedNewInvitees: false, nonUserNames: [""], userNames: [""], userIDs: [""], amendAvailability: sendAvailability)
//                        }
//                    }
//                }
//        //        2. Did the user delete users and not add anyone?
//                        if deletedUserIDs.count != 0 && contactsSelected.count == 0{
//                            deletedUsers{
//                                self.commitDataToDB(startDateInputString: startDateInputString, endDateInputString: endDateInputString, deletedUsers: true, deletedNonUser: false, addedNewInvitees: false, nonUserNames: [""], userNames: [""], userIDs: [""], amendAvailability: sendAvailability)
//                            }
//                        }
//                        
//        //        3. Did the user delete non users and not add anyone?
//                        if deletedNonUserInviteeNames.count != 0 && contactsSelected.count == 0{
//                            deletedNonUsers {
//                                self.commitDataToDB(startDateInputString: startDateInputString, endDateInputString: endDateInputString, deletedUsers: false, deletedNonUser: true, addedNewInvitees: false, nonUserNames: [""], userNames: [""], userIDs: [""], amendAvailability: sendAvailability)
//                            }
//                        }
//        //        4. Did the user add somone new to the event?
//                        if contactsSelected.count != 0{
//        //                    check if the user also deleted anyone
//                            if deletedUserIDs.count != 0{
//                                deletedUsers{}
//                                
//                            }
//                            if deletedNonUserInviteeNames.count != 0{
//                                deletedNonUsers {}
//                            }
//
//                                   print("the user has added new invitees")
//                                        var selectedPhoneNumbers = [String]()
//                                        var selectedNames = [String]()
//                                        
//                        //                1. get the phone numbers and names of the new users added
//                                        selectedPhoneNumbers = ["",""]
//                                        selectedNames = ["",""]
//                                        
//                        //                2. confirm which of the new invitees are users or not and add them to the arrya
//                                        createUserIDArrays(phoneNumbers: selectedPhoneNumbers, names: selectedNames) { (nonExistentArray, existentArray, userNameArray, nonExistentNameArray) in
//                                                        
//                                        print("nonExistentArray \(nonExistentArray)")
//                                        print("existentArray \(existentArray)")
//                                                        
//                        //           3. adds the non users to the database
//                                        self.addNonExistingUsers2(phoneNumbers: nonExistentArray, eventID: currentUserSelectedEvent.eventID, names: nonExistentNameArray)
//                                                        
//                        //            4. Adds the user event link to the userEventStore. this also adds the required availability notification
//                                    self.userEventLinkArray(userID: existentArray, userName: userNameArray, eventID: currentUserSelectedEvent.eventID){
//                                                            
//                                                        }
//                        //           5. Add the new user names and IDs to the database
//                                            self.commitDataToDB(startDateInputString: startDateInputString, endDateInputString: endDateInputString, deletedUsers: false, deletedNonUser: false, addedNewInvitees: true, nonUserNames: nonUserInviteeNames + nonExistentNameArray, userNames: inviteesNames + userNameArray, userIDs: inviteesUserIDs + existentArray, amendAvailability: sendAvailability)
//                                    
//                                                        
//                                                        print("new users added")
//                                                        
//                                        //            remove the selected contacts from the array
//                                                     contactsSelected.removeAll()
//                                                        inviteesNamesNew.removeAll()
//                                                        selectedContacts.removeAll()
//                                    }
//                            
//                        }
//                    }
//        
//    }

    func createTimePicker(){
        //        assign date picker to our text input
        
        eventStartTime.inputView = timePicker
        eventEndTime.inputView = timePicker
        
        
        //        add a toolbar to the datepicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        
        //        add a done button to the toolbar
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClickedTime))
        
        
        //        Adds space to the left of the done button, pushing the button to the right
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexSpace, doneButton], animated: false)
        
        
        eventStartTime.inputAccessoryView = toolBar
        eventEndTime.inputAccessoryView = toolBar
    }
    
    
    @objc func doneClickedTime(){
        dateFormatter.dateFormat = "HH:mm"
        if eventStartTime.isFirstResponder{
            
            eventStartTime.text = dateFormatter.string(from: timePicker!.date)
            self.view.endEditing(true)
        }
        
        if eventEndTime.isFirstResponder{
            
            eventEndTime.text = dateFormatter.string(from: timePicker!.date)
            self.view.endEditing(true)
            
        }
    }
    

    func createDatePicker(){
        //        assign date picker to our text input
        
        eventStartDate.inputView = datePicker
        eventEndDate.inputView = datePicker
        
        
        //        add a toolbar to the datepicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        
        //        add a done button to the toolbar
        
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClickedDate))
        
        //    moves the done button to the right
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexSpace, doneButton], animated: false)
        
        eventStartDate.inputAccessoryView = toolBar
        eventEndDate.inputAccessoryView = toolBar
    }
    
    
    @objc func doneClickedDate(){
        dateFormatter.dateFormat = "dd MMM YYYY"
        if eventStartDate.isFirstResponder{
            
            eventStartDate.text = dateFormatter.string(from: datePicker!.date)
            newEventStartDate = dateFormatterString.string(from: datePicker!.date)
            self.view.endEditing(true)
        }
        
        if eventEndDate.isFirstResponder{
            
            eventEndDate.text = dateFormatter.string(from: datePicker!.date)
            newEventEndDate = dateFormatterString.string(from: datePicker!.date)
            self.view.endEditing(true)
            
        }
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = Int()
        
        
        
        let combinedInvitees = inviteesNames + nonUserInviteeNames + inviteesNamesNew
        numberOfRows = combinedInvitees.count
        
        print("numberOfRows \(numberOfRows)")
    
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = invitees.dequeueReusableCell(withIdentifier: "inviteesCell", for: indexPath) as? EditTableViewCell
        else{
            fatalError("could not deque edit cell")
        }
        
        let combinedInvitees = inviteesNames + nonUserInviteeNames + inviteesNamesNew
        print("combinedInvitees \(combinedInvitees)")
        
        cell.delegate = self
        cell.cellLabel.text = combinedInvitees[indexPath.row]
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.clipsToBounds = true
            
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

            return 40
        
        ;//Choose your custom row height
    }
    

    
//    the user selecte the delete button in the tableview
    @objc func deleteButtonPressed(indexPath: IndexPath){
        print("delete button pressed")
      
        
        
    }
    
    
    
//    removing the invitees button tapped, part of the tableview cell
    func buttonTapped(cell: EditTableViewCell) {
        guard let indexPath = self.invitees.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
        
//        check to ensure the user isnt trying to remove themselves from the event and show a message is they are
        if indexPath.row == 0{
         showProgressHUD(notificationMessage: "You can't delete yourself from the event", imageName: "Unavailable", delay: 1)
        }
        else{
        
        //  which row was the button tapped on
        print("Button tapped on row \(indexPath.row)")
        
//        number of invitees already invited who are alrady users
        let originalInvitees = inviteesNames.count - 1
        print("originalInvitees: \(originalInvitees)")
//        the position of the start of the non user names that have been invited
        let nonUserInvitees = nonUserInviteeNames.count + originalInvitees
        print("nonUserInvitees: \(nonUserInvitees)")
//        total number of invitees
        let combinedInvitees = inviteesNames + nonUserInviteeNames + inviteesNamesNew
        print("combinedInvitees: \(combinedInvitees)")
        
//            if the index path is less than or euqal to the position of the user invitees than we know the user had removed a user invitee
        if indexPath.row <= originalInvitees {
        deletedInviteeNames.append(inviteesNames[indexPath.row])
        print("deleted invitee: \(inviteesNames[indexPath.row])")

            
        deletedUserIDs.append(inviteesNamesLocation[indexPath.row])
            print("deletedUserIDs: \(deletedUserIDs)")
            
        inviteesNames.remove(at: indexPath.row)
            
        let indexOfItem = inviteesUserIDs.index(of: inviteesNamesLocation[indexPath.row])!
        inviteesUserIDs.remove(at: indexOfItem)
        inviteesNamesLocation.remove(at: indexPath.row)
       
            
        print("new invitee names \(inviteesNames)")
        print("new invitee uid \(inviteesUserIDs)")
        invitees.reloadData()
//        remove the selected status of the user
        }
        
//        if the index path is greater than the original invitees but less the non user invitees, the user removed a non user invitee
        if originalInvitees < indexPath.row && indexPath.row  <= nonUserInvitees{
            
            
            deletedNonUserInviteeNames.append(combinedInvitees[indexPath.row])
            print("deletedNonUserInviteeNames: \(deletedNonUserInviteeNames)")
            let indexOfItem = nonUserInviteeNames.index(of: combinedInvitees[indexPath.row])!
            nonUserInviteeNames.remove(at: indexOfItem)
            print("nonUserInviteeNames: \(nonUserInviteeNames)")
            invitees.reloadData()
            
        }
        
//            the user has removed a one of the newly added users
        if indexPath.row > nonUserInvitees{
            
          inviteesNamesNew.remove(at: indexPath.row - (nonUserInvitees + 1))
            contactsSelected.remove(at: indexPath.row - (nonUserInvitees + 1))
            invitees.reloadData()
            
        }
    }
    }
    
  
    @IBAction func addUsersTapped(_ sender: UIButton) {
        
//        we remove the contacts to reset the selected list each time we add new people
        contactsSorted.removeAll()
        contactsFiltered.removeAll()
        
        performSegue(withIdentifier: "addUsersSelected", sender: Any.self)
 
        
    }
    
    
    //    MARK: Functions for deleting a created event
    func deleteEventRequest(eventID: String){
        let docRefEventRequest = dbStore.collection("eventRequests")
        
        docRefEventRequest.document(eventID).delete()
    }
    
//    fucntion to delete the eventStore
    func deleteEventStore(eventID: String){
        
        for i in currentUserSelectedAvailability{
        
        print("running func deleteEventStore, inputs - eventID: \(i.documentID)")
        
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
            docRefUserEventStore.document(i.documentID).updateData(["userAvailability" : FieldValue.delete()]){ err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    
                    docRefUserEventStore.document(i.documentID).delete()
        }
    }
    
    func deleteTemporaryUserEventStore(eventID: String){
        
        print("running func deleteTemporaryUserEventStore, inputs - eventID: \(eventID)")
        
        let docRefUserEventStore = dbStore.collection("temporaryUserEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    let documentID = document.documentID
                    
                    docRefUserEventStore.document(documentID).delete(){ err in
                        if let err = err {
                            print("Error deleting document: \(err)")
                        } else {
                            print("Document successfully deleted")
                        }
                    }
                    
                    docRefUserEventStore.document(documentID).delete()
                }
            }
        }
    }
    
//
    func deleteEventStoreAvailability(eventID: String){
        
        print("running func deleteEventStoreAvailability, inputs - eventID: \(eventID)")
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        for i in  currentUserSelectedAvailability{
            
            docRefUserEventStore.document(i.documentID).updateData(["userAvailability" : FieldValue.delete()]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            
            docRefUserEventStore.document(i.documentID).updateData(["chosenDate" : FieldValue.delete()]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
        }
    
//    resets the availability array for all remaining users
    func updateEventStoreAvailability(eventID: String){
        
        print("running func updateEventStoreAvailability, inputs - eventID: \(eventID)")
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
//        1. get the availability for all users
        
        for i in  currentUserSelectedAvailability{
            docRefUserEventStore.document(i.documentID).updateData(["userAvailability" : FieldValue.delete(), "userResponded" : false, "chosenDate" : FieldValue.delete(), "chosenDateDay" : FieldValue.delete(), "chosenDateMonth" : FieldValue.delete(), "chosenDateYear" : FieldValue.delete()]){ err in
                                   if let err = err {
                                       print("Error updating document: \(err)")
                                   } else {
                                       print("Document successfully updated")
                                   }
                    }
//            turned off to stop the invitee phone from responding to this notification
//            availabilityAmendedNotification(userIDs: [i.uid], availabilityDocumentID: i.documentID)
        }
    }

    
//    section for deleting the realtime database entries
    func deleteRealTimeDatabaseEventInfo(eventID: String){
    let ref = Database.database().reference()
        
        ref.child("events/\(eventID)").removeValue()
   
    }
    
//    function to delete the new event notification
    func deleteRealTimeDatabaseUserEventLink(eventID: String){
        let ref = Database.database().reference()
        ref.child("userEventLink/\(user!)/newEvent/\(eventID)").removeValue()
    }
    
    
//    fucntion to commit data to the database
    func commitDataToDB(startDateInputString: String, endDateInputString: String, deletedUsers: Bool, deletedNonUser: Bool, addedNewInvitees: Bool, nonUserNames: [String], userNames: [String], userIDs: [String], amendAvailability: Bool){
        print("running func commitDataToDB - inputs: startDateInputString:\(startDateInputString) endDateInputString: \(endDateInputString) deletedUsers: \(deletedUsers) deletedNonUser: \(deletedNonUser) nonUserNames: \(nonUserNames) addedNewInvitees:\(addedNewInvitees) userNames:\(userNames) amendAvailability:\(amendAvailability)")
        
                        getStartAndEndDates3(startDate: startDateInputString, endDate: endDateInputString, startTime: eventStartTime.text!, endTime: eventEndTime.text!, daysOfTheWeek: daysOfTheWeekNewEvent){ (startDates,endDates) in
                        
            //            commit the updated event information to the database, we merge the data, if there are changes to the user invitees we deal with this later in the code
                            dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).setData(["eventDescription" : self.eventTitle.text!, "location" : self.eventLoction.text!, "endTimeInput" :self.convertToGMT(inputTime: self.eventEndTime.text!), "startTimeInput" :self.convertToGMT(inputTime: self.eventStartTime.text!), "endDateInput" : self.convertToStringDate(inputDate: self.eventEndDate.text!), "startDateInput" : self.convertToStringDate(inputDate:self.eventStartDate.text!), "daysOfTheWeek" : daysOfTheWeekNewEvent, "startDates": startDates, "endDates": endDates, "locationLongitude": newEventLongitude, "locationLatitude": newEventLatitude], merge: true)
                            
//                            did the user delete users
                            if deletedUsers == true{
                                dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).setData(["users": inviteesUserIDs, "currentUserNames": inviteesNames], merge: true)
                                
                            }
//                            did the user delete non users
                            if deletedNonUser == true{
                                dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).setData(["nonUserNames": nonUserInviteeNames], merge: true)
                            }
                            if addedNewInvitees == true{
                              
                                dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).setData(["users": userIDs, "currentUserNames": userNames, "nonUserNames": nonUserNames], merge: true)
                                
                            }
            //                AmendNotifiction  - post to the eventNotification to table that the event has been amended
                            self.eventAmendedNotification(userIDs: currentUserSelectedEvent.users, eventID: currentUserSelectedEvent.eventID, amendWithAvailability: amendAvailability)
                            
                            
//                            check to see if the event availability has been amended, we also need to remove the chosen information for the event
                            if amendAvailability == true{
                                print("amendAvailability = true")
//                                delete chosen data
                                dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).updateData(["chosenDate" : FieldValue.delete(), "chosenDateDay" : FieldValue.delete(), "chosenDateMonth" : FieldValue.delete(), "chosenDateYear" : FieldValue.delete(), "chosenDatePosition" : FieldValue.delete()])
                                
                                
//                              post a notification to the real time DB to trigger the push notification
                                let ref = Database.database().reference()
                                let userIDs = currentUserSelectedEvent.users
                                
//                                loop through each user ID and post to the database
                                for i in userIDs{
//                                    dont post a notification for the current user
                                    if i == user!{
                                    }
                                    else{
//                                        add the notification to the realtime database
                               ref.child("userEventLink/\(i)/amendedEvent/\(currentUserSelectedEvent.eventID)").setValue(currentUserSelectedEvent.eventID)
                                    }
                                }
                                
                                print("event updates committed")
                                
                            }
                        
//            updated the realtime database
                        let rRef = Database.database().reference()
                        
                            rRef.child("events/\(currentUserSelectedEvent.eventID)/eventDescription").setValue(self.eventTitle.text!)
                            
                        }
        }
    
    
//    delete data for users of the app that have been removed
    func deletedUsers(completion: @escaping () -> Void){
        
                    print("user deleted invitees that are already users \(deletedUserIDs)")
              
        //            1. deletes the userEventStore
                            deleteUserEventLinkArray(userID: deletedUserIDs, eventID: currentUserSelectedEvent.eventID)
        //            2. clear the user
                            deleteEventStoreAvailability(eventID: currentUserSelectedEvent.eventID)
        //            3. post a deleted notification for these users, so their app deletes the event
                            eventDeletedNotification(userIDs: deletedUserIDs, eventID: currentUserSelectedEvent.eventID)

        //            4. post delete notification for the users availability, so other users have thier availability deleted
                                for i in deletedUserIDs{
                                    
                                let filteredAvailability = currentUserSelectedAvailability.filter {$0.uid == i}
                                let filteredAvailabilityDocumentID = filteredAvailability[0].documentID
                                availabilityDeletedNotification(userIDs: inviteesUserIDs, availabilityDocumentID: filteredAvailabilityDocumentID)
                                    
                                }
        //            5. reset the tracking array
                    deletedUserIDs.removeAll()
        
        completion()
        
    }
    
//    delete data for non users of that app that have been removed
    func deletedNonUsers(completion: @escaping () -> Void){
        
        print("user deleted invitees that are not users \(deletedNonUserInviteeNames)")
                       
        //                1. remove the non user invitees
                     deleteNonUsers(eventID: currentUserSelectedEvent.eventID, userNames: deletedNonUserInviteeNames)
        //                2. reset the tracking array
                        deletedNonUserInviteeNames.removeAll()
        completion()
        
    }
    
}


