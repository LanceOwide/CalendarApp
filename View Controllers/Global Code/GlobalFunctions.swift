//
//  GlobalFunctions.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 11/11/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
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



var messageNotificationDateChosen = Bool()

// Mark: Code - used to house all the global functions within the App
class GlobalFunctions: UIViewController {
    
    
}
    
    
    extension UIViewController{
        

    //    Function: converts the input string into a date and converts to local timezone. Input: String, Output: String
    func convertToLocalTime(inputTime: String) -> String{
        
        print("running func convertToLocalTime inputs - inputTime: \(inputTime)")
        
        var timeInLocal = String()
        let dateFormatterTime = DateFormatter()
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")

        let dateStartDate = dateFormatterTime.date(from: inputTime)
        let adjStartTimeDate = dateStartDate!.addingTimeInterval(TimeInterval(secondsFromGMT))
        let adjStartTimeString = dateFormatterTime.string(from: adjStartTimeDate)
        
        timeInLocal = adjStartTimeString
        print("timeInLocal \(timeInLocal)")
        
       return timeInLocal
    }
    
    
    //    Function: converts the input string into a date and converts to GMT. Input: String, Output: String
    func convertToGMT(inputTime: String) -> String{
        
        print("running func convertToGMT inputs - inputTime: \(inputTime)")
        
        var timeInGMT = String()
        let dateFormatterTime = DateFormatter()
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        
        let dateStartDate = dateFormatterTime.date(from: inputTime)
        let adjStartTimeDate = dateStartDate!.addingTimeInterval(TimeInterval(-secondsFromGMT))
        let adjStartTimeString = dateFormatterTime.string(from: adjStartTimeDate)
        
        timeInGMT = adjStartTimeString
        print("timeInGMT \(timeInGMT)")
        
        return timeInGMT
    }
    
    
    //    Function: converts the input string into a date and converts to the display format for dates in the app
    func convertToDisplayDate(inputDate: String) -> String{
        
        print("running func convertToDisplayDate inputs - inputDate: \(inputDate)")
        
        var displayDate = String()
        let dateFormatterDisplayDate = DateFormatter()
        dateFormatterDisplayDate.dateFormat = "dd MMM YYYY"
        dateFormatterDisplayDate.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterStringDate = DateFormatter()
        dateFormatterStringDate.dateFormat = "yyyy-MM-dd"
        dateFormatterStringDate.locale = Locale(identifier: "en_US_POSIX")
        
        let dateDate = dateFormatterStringDate.date(from: inputDate)

        let dateString = dateFormatterDisplayDate.string(from: dateDate!)
        
        displayDate = dateString
        print("displayDate \(displayDate)")
        
        return displayDate
    }
    

    
    //    Function: converts the input string into a date and converts to the database storage format for dates in the app
    func convertToStringDate(inputDate: String) -> String{
        
        print("running func convertToDisplayDate inputs - inputDate: \(inputDate)")
        
        var displayDate = String()
        let dateFormatterDisplayDate = DateFormatter()
        dateFormatterDisplayDate.dateFormat = "dd MMM yyyy"
        dateFormatterDisplayDate.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterStringDate = DateFormatter()
        dateFormatterStringDate.dateFormat = "yyyy-MM-dd"
        dateFormatterStringDate.locale = Locale(identifier: "en_US_POSIX")
        print("inputDate: \(inputDate)")
        
        let dateDate = dateFormatterDisplayDate.date(from: inputDate)
        print("dateDate: \(String(describing: dateDate))")
        
        let dateString = dateFormatterStringDate.string(from: dateDate!)
        print("dateString: \(dateString)")
        
        displayDate = dateString
        print("displayDate \(displayDate)")
        
        return displayDate
    }
    
    func convertToStringDateDisplay(inputDate: String) -> String{
        
        print("running func convertToDisplayDate inputs - inputDate: \(inputDate)")
        
        var displayDate = String()
        let dateFormatterDisplayDate = DateFormatter()
        dateFormatterDisplayDate.dateFormat = "dd MMM yyyy"
        dateFormatterDisplayDate.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterStringDate = DateFormatter()
        dateFormatterStringDate.dateFormat = "yyyy-MM-dd"
        dateFormatterStringDate.locale = Locale(identifier: "en_US_POSIX")
        print("inputDate: \(inputDate)")
        
        let dateDate = dateFormatterStringDate.date(from: inputDate)
        print("dateDate: \(String(describing: dateDate))")
        
        let dateString = dateFormatterDisplayDate.string(from: dateDate!)
        print("dateString: \(dateString)")
        
        displayDate = dateString
        print("displayDate \(displayDate)")
        
        return displayDate
    }
    
    func convertLongDateToDisplayDate(inputDate: String) -> String{
        var displayDate = String()
        let dateFormatterDisplayDate = DateFormatter()
        dateFormatterDisplayDate.dateFormat = "dd MMM YYYY"
        dateFormatterDisplayDate.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterStringDate = DateFormatter()
        dateFormatterStringDate.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterStringDate.locale = Locale(identifier: "en_US_POSIX")
        
        let dateDate = dateFormatterStringDate.date(from: inputDate)
        
        let dateString = dateFormatterDisplayDate.string(from: dateDate!)
        
        displayDate = dateString
        print("displayDate \(displayDate)")
        
        return displayDate
    }
    
    
//    function to allow for the process of a string array into the phone number cleaning function
    
    func getSelectedContactsPhoneNumbers2() -> (phoneNumbers:[String], names:[String]){
        
        print("running func getSelectedContactsPhoneNumbers2")
        
        selectedContacts.removeAll()
        selectedContactNames.removeAll()
        
        print("contactsSelected: \(contactsSelected)")

            for contact in contactsSelected{
                if contact.selectedContact == true {
                    
                   let cleanPhoneNumber = cleanPhoneNumbers(phoneNumbers: contact.phoneNumber)
                    let contactName = contact.name
                    
                        selectedContacts.append(cleanPhoneNumber)
                        selectedContactNames.append(contactName)
   
                }}
        print("output: phoneNumbers: \(selectedContacts) names: \(selectedContactNames)")
        return (phoneNumbers: selectedContacts, names: selectedContactNames)
        }
    
    
    func createUserIDArrays(phoneNumbers: [String], names: [String], completionHandler: @escaping (_ nonExistentArray: [String], _ existentArray: [String], _ existentNameArray: [String], _ nonExistentNameArray: [String]) -> ()){
        
        var nonExistentArray = [String]()
        var existentArray = [String]()
        var existentNameArray = [String]()
        var nonExistentNameArray = [String]()
        var n = 0
        let phoneNumbersCount = phoneNumbers.count
        
        print("running func createUserIDArrays, inputs - phoneNumbers: \(phoneNumbers) names: \(names)")

        for numbers in phoneNumbers{
        
            getUserID(phoneNumber: numbers) { (userID, userExists, userName) in
  
            if userExists == false{
                n = n + 1
                
                let indexOfItem = phoneNumbers.index(of: numbers)
                print("indexOfItem: \(String(describing: indexOfItem))")
                
              nonExistentArray.append(numbers)
                nonExistentNameArray.append(names[indexOfItem!])
                
                if n == phoneNumbersCount{
                    print("nonExistentArray: \(nonExistentArray), existentArray: \(existentArray), existentNameArray: \(existentNameArray), nonExistentNameArray: \(nonExistentNameArray)")
                    completionHandler(nonExistentArray, existentArray, existentNameArray, nonExistentNameArray)
                    
                }
            
            }
            else{
                n = n + 1
                
                existentArray.append(userID)
                existentNameArray.append(userName)
                
                if n == phoneNumbersCount{
                    print("nonExistentArray: \(nonExistentArray), existentArray: \(existentArray), existentNameArray: \(existentNameArray), nonExistentNameArray: \(nonExistentNameArray)")
                    completionHandler(nonExistentArray, existentArray, existentNameArray, nonExistentNameArray)
                    
                }
                
            }
                
                
            }
            
            }
        
        
    }
    
//    (_ userID: String,_ userExists: Bool,_ userName: String)
    
    func getUserID(phoneNumber: String, completionHandler: @escaping (_ userID: String, _ userExists: Bool, _ userName: String) -> ()){
    
        var userExists = Bool()
        var userID = String()
        var userName = String()
        
        print("running func - getUserID - inputs - phoneNumber: \(phoneNumber)")
        
        
        dbStore.collection("users").whereField("phoneNumbers", arrayContains: phoneNumber).getDocuments { (querySnapshot, error) in
            
//            print("querySnapshot \(String(describing: querySnapshot))")
            
            if error != nil {
                print("there was an error")
            }
            else {
                print("querySnapshot!.isEmpty: \(querySnapshot!.isEmpty)")
                
                if querySnapshot!.isEmpty{
                    
                    print("The phone number is not in the Circles DB")
                    
                    userExists = false
                    userID = ""
                    completionHandler(userID, userExists, userName)
                    
                }
                else{
                    for document in querySnapshot!.documents {
                        print("document information: \(document.documentID) => \(document.data())")
                        
                        userExists = true
                        
                        let myAddedUserID = document.get("uid") as! String
                        let myAddedUserName = document.get("name") as! String
                        print("Next user to be added to the userIDArray \(myAddedUserID)")
                        userID = myAddedUserID
                        userName = myAddedUserName
                        
                        print("func - getUserID - outputs - userID: \(userID) userExists: \(userExists) userName: \(userName)")
                        
                        completionHandler(userID, userExists, userName)
                    }}
            }
            
        }
   
    }
    
    
    func addNonExistingUsers2(phoneNumbers: [String], eventID: String, names: [String]){
        
        var nameToUpload = String()
        
        print("running func addNonExistingUsers2, inputs - phoneNumbers: \(phoneNumbers) eventID: \(eventID) names: \(names)")
        
        for phoneNumber in phoneNumbers{
            
            let indexOfItem = phoneNumbers.index(of: phoneNumber)
            
            print("indexOfItem: \(String(describing: indexOfItem))")
            print("current phone number: \(phoneNumber)")
            print("current name: \(names[indexOfItem!])")
            
//            Check to esnure a users name is always uploaded
            if names[indexOfItem!] == ""{
              
                nameToUpload = "Unknown Name"
                
            }
            else{
                nameToUpload = names[indexOfItem!]
            }
        
            dbStore.collection("temporaryUserEventStore").addDocument(data: ["eventID": eventID, "phoneNumber": phoneNumber, "name": nameToUpload])
            
        }
        
    }
    
    
//    adds the user and eventID into the userEventStore
    func userEventLinkArray( userID: [String], userName: [String], eventID: String){
        
        print("running func userEventLinkArray, inputs - userID: \(userID) userName: \(userName) eventID: \(eventID)")
        
        let ref = Database.database().reference()
        let numberOfUsers = userID.count
        print("numberOfUsers: \(numberOfUsers)")
        var n = 0
        
        while n <= numberOfUsers - 1{
        
            dbStore.collection("userEventStore").addDocument(data: ["eventID": eventID, "uid": userID[n], "userName": userName[n], "userResponded": false])
            
            
//            We don't want to send notifications to the user who added the event
            
            if userID[n] == user!{
                
                
            }
            else{
//            adds the username to the real time database
            ref.child("userEventLink/\(userID[n])/\(eventID)").setValue(eventID)
                
            }
        
            n = n + 1
            
        }
    }
    
    
//    deletes the user and eventId from the userEventStore
    func deleteUserEventLinkArray(userID: [String], eventID: String){
        
        print("running func deleteuserEventLinkArray - inputs userID: \(userID) eventID: \(eventID)")
        
      for users in userID{
        print("users: \(users)")

        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).whereField("uid", isEqualTo: users).getDocuments() { (querySnapshot, err) in
            
            print("querySnapshot: \(String(describing: querySnapshot))")
            print("is querySnapshot empty \(String(describing: querySnapshot?.isEmpty))")
            
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    let documentID = document.documentID
                    print("documentID: \(documentID)")
                    
                    docRefUserEventStore.document(documentID).delete()
                    
                    docRefUserEventStore.document(documentID).updateData(["userAvailability" : FieldValue.delete()]){ err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    
//                    docRefUserEventStore.document(documentID).delete()
                }
                
            }
            
        }
        
        }
   
    }
    
    

    //    get the current users phone number
    func getCurrentUsersPhoneNumber2() -> [String]{
        
        print("running func getCurrentUsersPhoneNumber2")
        
        var usersPhoneNumber = String()
        
        dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments{ (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents{
                    usersPhoneNumber = document.get("phoneNumber") as! String
                    print("Current users phone number to add to selected contacts \(String(describing: usersPhoneNumber))")
                }
  
            }
        }
        print("[usersPhoneNumber]: \([usersPhoneNumber])")
        return [usersPhoneNumber]
    }
    
//    add user IDs to the eventRequests table
    
    func addUserIDsToEventRequests(userIDs: [String], currentUserID: [String],existingUserIDs: [String], eventID: String, addCurrentUser: Bool) {
        
        var allUsers = [String]()
        
        let ref = Database.database().reference().child("events").child(eventID)
        
        
        print("running func addUserIDsToEventRequests, inputs - userID: \(userIDs) currentUserID: \(currentUserID) existingUserIDs: \(existingUserIDs) eventID: \(eventID) addCurrentUser: \(addCurrentUser)")
        
        if addCurrentUser == true{
            
            allUsers = userIDs + currentUserID + existingUserIDs
            
            dbStore.collection("eventRequests").document(eventID).setData(["users" : allUsers], merge: true)
            ref.child("invitedUsers").setValue(allUsers)
            
        }
        else{
        
        allUsers = userIDs + existingUserIDs
            dbStore.collection("eventRequests").document(eventID).setData(["users" : allUsers], merge: true)
            ref.child("invitedUsers").setValue(allUsers)
            
        }
   
    }
    
//function returns a clean phone number fron the dirty phone number used as an input
func cleanPhoneNumbers(phoneNumbers: String) -> String{
    
    print("running func cleanPhoneNumbers: Input PhoneNumbers: \(phoneNumbers)")
        
        let currentLocale = NSLocale.current.regionCode
        let countryPrefix = countryCodePrefixes.countryCodes[currentLocale!]!
        let phoneNumberLen = phoneNumbers.count
        
        //        print(countryPrefix)
        //        print(currentLocale!)
        
        var returnedPhoneNumber = String()
        
        //            used to remove all the non digit characters within the phone numbers
        let phoneNumberClean = phoneNumbers.components(separatedBy:CharacterSet.decimalDigits.inverted).joined(separator: "")
        
        
        
        //        If the phone number starts with a + we assume it is in the correct format
    
    if phoneNumberLen > 10 && phoneNumbers[0] == "+" {
        let phoneNumberLenClean = phoneNumberClean.count
        let phoneNumberZero = phoneNumberLenClean - 11
        let numberZero = phoneNumberClean[phoneNumberZero]
        
        if numberZero == "0"{
            
            let phoneNumberZero = phoneNumberLenClean - 11
            let phoneNumberZeroSecond = phoneNumberLenClean - 10
            
            let firstPart = phoneNumberClean[..<phoneNumberZero]
            print("firstPart: \(firstPart)")
            let secondPart = phoneNumberClean[phoneNumberZeroSecond...]
            print("secondPart: \(secondPart)")
            
            print("combined: \(firstPart)\(secondPart)")
            
            returnedPhoneNumber = "+\(firstPart)\(secondPart)"
        }
        else{
            returnedPhoneNumber = "+\(phoneNumberClean)"
            
        }
        
        
    }
            
        else if phoneNumberClean.count == 10{
            returnedPhoneNumber = "+\(countryPrefix)\(phoneNumberClean)"
            
        }
            
        else if phoneNumberClean.count == 11 && phoneNumberClean[0] == "0"{
            
            returnedPhoneNumber = "+\(countryPrefix)\(phoneNumberClean.dropFirst(1))"
        }
            
        else if phoneNumberClean.count == 11 {
            
            //                remove the first character
            returnedPhoneNumber = "+\(phoneNumberClean)"
        }
        else if phoneNumberClean.count == 12 && phoneNumberClean[0] == "0" && phoneNumberClean[1] == "0"{
            
            //                remove the first character
            
            returnedPhoneNumber = "+\(countryPrefix)\(phoneNumberClean.dropFirst(1))"
        }
        else if phoneNumberClean.count == 12 && phoneNumberClean[0] == "0"{
            
            returnedPhoneNumber = "+\(phoneNumberClean.dropFirst(1))"
        }
        else if phoneNumberClean.count == 13 && phoneNumberClean[0] == "0" && phoneNumberClean[1] == "0"{
            
            returnedPhoneNumber = "+\(phoneNumberClean.dropFirst(2))"
        }
        else if phoneNumberClean.count == 13 && phoneNumberClean[0] == "0"{
            
            returnedPhoneNumber = "+\(phoneNumberClean.dropFirst(1))"
        }
        else if phoneNumberClean.count == 14 && phoneNumberClean[0] == "0" && phoneNumberClean[1] == "0"{
            
            returnedPhoneNumber = "+\(phoneNumberClean.dropFirst(2))"
        }
        else if phoneNumberClean.count == 14 && phoneNumberClean[0] == "0"{
            
            returnedPhoneNumber = "+\(phoneNumberClean.dropFirst(1))"
        }
        else{
            returnedPhoneNumber = phoneNumberClean
        }
        
        print("returnedPhoneNumber \(returnedPhoneNumber)")
        return returnedPhoneNumber
    }
    
    
    func sendInviteTextMessages(notExistingUserArray: [String]){
        print("sendTextMessages Initiated")
        
        //            dummy numbers for testing, comment out when commiting
        //        let notExistingUserArray = ["+15557664823","+1888555512"]
        
        for phoneNumbers in notExistingUserArray{
            
            let parameters = ["From": "+17372105712", "To": phoneNumbers, "Body": "Hello from the Planr Team! Your friend XX invited you to sign-up, click the link below to download the App and join the Planr revolution"]
            
            Alamofire.request(twilioLogIn.url, method: .post, parameters: parameters)
                .authenticate(user: twilioLogIn.accountSID, password: twilioLogIn.authToken)
                .responseString { response in
                    debugPrint(response)
                    
            }}}
    
    func dateChosenAlert(){
        
        print("running func dateChosenAlert")
        
        let alertEventComplete = UIAlertController(title: "Congratualtions! Your event has been finalised", message: "You invitees will be sent a message notifying them of the date", preferredStyle: UIAlertController.Style.alert)
        
        alertEventComplete.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            print("User Selected OK on event creation alert")
            
            self.performSegue(withIdentifier: "dateChosenSave", sender: self)

            
        }))
        self.present(alertEventComplete, animated: true, completion: {
    
        
        
        })
        
    }
    
//  Code to create the array we send to the event results page
    func addDatesToResultQuery2( eventID: String, selectEventToggle: Int, completion: @escaping (_ arrayForEventResultsPage: [[Any]], _ arrayForEventResultsPageDetails: [[Any]], _ numberOfDatesInArray: Int) -> Void) -> (){
        
        
        print("running func addDatesToResultQuery2 inputs - eventID: \(eventID) selectEventToggle: \(selectEventToggle)")
        
        //        add the top row of dates and a single blank
        //        arrayForEventResultsPage
        
        var arrayForEventResultsPage = [[Any]]()
        var arrayForEventResultsPageDetails = [[Any]]()
        var emptyArray = Array<Any>()
        var emptyArray3 = Array<Any>()
        var emptyArray6 = Array<Any>()
        var emptyArray7 = Array<Any>()
        var emptyArray8 = Array<Any>()
        var emptyArray9 = Array<Any>()
        var emptyArray10 = Array<Any>()
        var emptyArray11 = Array<Any>()
        var emptyArray12 = Array<Any>()
        var emptyArray13 = Array<Any>()
        var emptyArray14 = Array<Any>()
        var startDate = Date()
        var endDate = Date()
        let dateFormatter = DateFormatter()
        let dateFormatterForResults = DateFormatter()
        let dateFormatterSimple = DateFormatter()
        var numberOfDatesInArray = Int()
        let dateFormatterTz = DateFormatter()

        
        
        emptyArray.removeAll()
        emptyArray3.removeAll()
        emptyArray6.removeAll()
        emptyArray7.removeAll()
        emptyArray8.removeAll()
        datesToChooseFrom.removeAll()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterForResults.dateFormat = "E d MMM"
        dateFormatterTz.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterSimple.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterForResults.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTz.locale = Locale(identifier: "en_US_POSIX")
        
        let docRefEventRequest = dbStore.collection("eventRequests").document(eventID)
        docRefEventRequest.getDocument { (document, error) in
            if let document = document, document.exists {
                
//                get the start and end time of the event
                let startTimeString = document.get("startTimeInput") as! String
                let endTimeString = document.get("endTimeInput") as! String
                
                let startDateInputResult = document.get("startDateInput") as! String
                let eventDescriptionInputResult = document.get("eventDescription") as! String
                let eventLocationInputResult = document.get("location") as! String
                let startTimeInputResult = self.convertToLocalTime(inputTime: startTimeString)
                let endDateInputResult = document.get("endDateInput") as! String
                let dateChosenInput = document.get("chosenDate") as? String ?? ""
                chosenDateForEvent = dateChosenInput
                let endTimeInputResult = self.convertToLocalTime(inputTime: endTimeString)
                let documentIDResult = document.documentID
                let invitees = document.get("users")  as! Array<String>
                newEventLongitude = document.get("locationLongitude")  as? Double ?? 0.0
                newEventLatitude = document.get("locationLatitude")  as? Double ?? 0.0
                daysOfTheWeek = document.get("daysOfTheWeek") as! [Int]
                startDate = dateFormatter.date(from: startDateInputResult + " " + startTimeInputResult)!
                print(startDate)
                endDate = dateFormatter.date(from: endDateInputResult + " " + endTimeInputResult)!
                print(endDate)
                
                
//                we use this to tell the chat controller which notification bool to set
                
                if dateChosenInput == ""{
                   
                    messageNotificationDateChosen = false
                    
                }
                else{
                    
                    messageNotificationDateChosen = true
                    
                    
                }
                
//                get the dates between the start and end date
                self.getArrayOfChosenDates3(eventID: eventID, completion: { (startDates, endDates) in
                    

                
                for dates in startDates {
 
//                    converting the dates to test back to the string and format we want to display
                    let newDate = dateFormatterTz.date(from: dates)
                    
                    emptyArray.append(dateFormatterForResults.string(from: newDate!))
//                    adds all other event information into arrays for adding to the details array later
                    emptyArray3.append(dateFormatterSimple.string(from: newDate!))
                    emptyArray6.append(eventLocationInputResult)
                    emptyArray7.append(eventDescriptionInputResult)
                    emptyArray8.append(documentIDResult)
                    emptyArray9.append(startDateInputResult)
                    emptyArray10.append(endDateInputResult)
                    emptyArray11.append(startTimeString)
                    emptyArray12.append(endTimeString)
                    emptyArray13.append(invitees)
                    emptyArray14.append(daysOfTheWeek)
                }
                var x = emptyArray
                x.insert(dateChosenInput, at: 0)
                datesToChooseFrom = x
                print("datesToChooseFrom: \(datesToChooseFrom)")
                emptyArray.insert("", at: 0)
                emptyArray3.insert("", at: 0)
                emptyArray6.insert("", at: 0)
                emptyArray7.insert("", at: 0)
                emptyArray8.insert("", at: 0)
                //                adds the date and select text to the top of the results array
                arrayForEventResultsPage.append(emptyArray)
                print("arrayForEventResultsPage: \(arrayForEventResultsPage)")
                //                creates second array with details of the event
                arrayForEventResultsPageDetails.append(emptyArray3)
                arrayForEventResultsPageDetails.append(emptyArray6)
                arrayForEventResultsPageDetails.append(emptyArray7)
                arrayForEventResultsPageDetails.append(emptyArray8)
                arrayForEventResultsPageDetails.append(emptyArray9)
                arrayForEventResultsPageDetails.append(emptyArray10)
                arrayForEventResultsPageDetails.append(emptyArray11)
                arrayForEventResultsPageDetails.append(emptyArray12)
                arrayForEventResultsPageDetails.append(emptyArray13)
                arrayForEventResultsPageDetails.append(emptyArray14)
                print("arrayForEventResultsPageDetails: \(arrayForEventResultsPageDetails)")
                numberOfDatesInArray = emptyArray.count
                completion(arrayForEventResultsPage, arrayForEventResultsPageDetails, numberOfDatesInArray)
                
                    })
            }
        }
        
    }
    
    
//    creates an array of both 10 and 11 for use in the user availability arrays, this denotes the not responded and those who have not signed up as users
    func noResultArrayCompletion2(numberOfDatesInArray: Int) -> (noResultsArray: [Int],nonUserArray: [Int]){
    
       print("running func getDayOfWeek2 inputs - numberOfDatesInArray: \(numberOfDatesInArray)")
        
        var noResultsArray = [Int]()
        var nonUserArray = [Int]()
        var n = 0
        let y = 10
        let x = 11
        
        
        while n <= numberOfDatesInArray - 2 {
            
            noResultsArray.append(y)
            nonUserArray.append(x)
            n = n + 1
        }
        print("noResultsArray \(noResultsArray) nonUserArray \(nonUserArray)")
        return (noResultsArray: noResultsArray, nonUserArray: nonUserArray)
    }
    
    
    //    pop-up used to ask if the user would like to invite their friends who are not users yet, inputs notExistingUserArray: phone numbers, nonExistingNameArray: names
    func inviteFriendsPopUp(notExistingUserArray: [String], nonExistingNameArray: [String]){
        print("inviteFriendsPopUp Initiated")
        
        let displayArray = nonExistingNameArray.joined(separator:",")
        
        // create the alert
        let alert = UIAlertController(title: "Not all the friends you invited are Planr App users", message: "Would you like to invite \(displayArray) to Planr?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: { action in
            
//            self.eventAdditionComplete()
            
        }))
        alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { action in
            
            print("User Selected to send texts to thier friends")
//            self.sendInviteTextMessages(notExistingUserArray: notExistingUserArray)
            
            self.shareLinkToTheEvent()
//            self.eventAdditionComplete()
        }))
        // show the alert
        
        if self.presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: false, completion: nil)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
        
        
    func eventAdditionComplete(){
        
//        performSegue(withIdentifier: "eventCreatedSegue", sender: self)
        
        
        print("running func eventAdditionComplete")
        
        let alertEventComplete = UIAlertController(title: "Congratualtions! Your event has been created", message: "Check 'Pending Events' to see responses", preferredStyle: UIAlertController.Style.alert)
        
        alertEventComplete.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            print("User Selected OK on event creation alert")
            
            self.performSegue(withIdentifier: "eventSummaryComplete", sender: self)
        }))
        
        if self.presentedViewController == nil {
            self.present(alertEventComplete, animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: false, completion: nil)
            self.present(alertEventComplete, animated: true, completion: nil)
        }
        }
    
    
    func resultsResponseComplete(){
            
    //        performSegue(withIdentifier: "eventCreatedSegue", sender: self)
            
            
            print("running func resultsResponseComplete")
            
            let alertEventComplete = UIAlertController(title: "Availability Added! ", message: "Your availability has been added to the event", preferredStyle: UIAlertController.Style.alert)
            
            alertEventComplete.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                
                print("User Selected OK on event creation alert")
       
            }))
            
            if self.presentedViewController == nil {
                self.present(alertEventComplete, animated: true, completion: nil)
            }
            else {
                self.dismiss(animated: false, completion: nil)
                self.present(alertEventComplete, animated: true, completion: nil)
            }
            
            }
    
    
//    retrieves each users availability for the event
//        UPDATED - now includes the documentID array
        func addUserToEventArray2( eventID: String, noResultArray: Array<Any>, completion: @escaping (_ arrayForEventResultsPage: [[Any]], _ arrayOfUserDocumentIDs: [Any]) -> Void){
    
    print("running func addUserToEventArray2 inputs - eventID: \(eventID) noResultArray: \(noResultArray)")
    
        var emptyArray = Array<Any>()
        var arrayOfUserDocumentIDs = [Any]()
        var arrayForEventResultsPageAvailability = [[Any]]()
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else { emptyArray.removeAll()
                for document in querySnapshot!.documents {
                    
                    print("\(document.documentID) => \(document.data())")
                    
                    let userAvailability = document.get("userAvailability") as? [Any]
                    let userID = document.get("uid") as? String
                    let documentID = document.documentID
                    
                    if userAvailability == nil {
                        emptyArray = noResultArray
                        
                    }
                    else if userAvailability?.count == 0 {
                        emptyArray = noResultArray
                        
                    }
                        
                    else {
                        
                        emptyArray = document.get("userAvailability") as! [Int]
                        
                        if userID == user{
                            
                            currentUsersAvailability = emptyArray as! [Int]
                            currentUserAvailabilityDocID = documentID
                            
                        }
                        else{
                            print("not the current user")
                        }
                    }
                    emptyArray.insert(document.get("userName")!, at: 0)
                    arrayOfUserDocumentIDs.append(documentID)
                    arrayForEventResultsPageAvailability.append(emptyArray)
                    
                }
                
            }
            completion(arrayForEventResultsPageAvailability, arrayOfUserDocumentIDs)
        }
    }
    
        func addNonExistentUsers( eventID: String, noResultArray: Array<Any>, completion: @escaping (_ arrayForEventResultsPage: [[Any]], _ nonExistentNames: Array<Any>, _ nonExistentPhoneNumbers: Array<Any>) -> Void){
        
        print("running func addNonExistentUsers inputs - eventID: \(eventID) noResultArray: \(noResultArray)")
        
        var emptyArray = Array<Any>()
        var addNonExistentUsersAvailability = [[Any]]()
        var nonExistentNames = Array<Any>()
        var nonExistentPhoneNumbers = Array<Any>()
        let docRefUserEventStore = dbStore.collection("temporaryUserEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else { emptyArray.removeAll()
                for document in querySnapshot!.documents {
                    
                    print("\(document.documentID) => \(document.data())")
                    
                    let name = document.get("name") ?? "Unknown Name"
                    let phoneNumber = document.get("phoneNumber") ?? "+447333333333"
  
                    emptyArray = noResultArray
                    emptyArray.insert(name, at: 0)
                    nonExistentNames.append(name)
                    nonExistentPhoneNumbers.append(phoneNumber)
                    addNonExistentUsersAvailability.append(emptyArray)
                }
                
            }
            completion(addNonExistentUsersAvailability, nonExistentNames, nonExistentPhoneNumbers)
        }
    }
    
    
//    function to delete non users from the temporary user event store
    
    func deleteNonUsers(eventID: String, userNames: [String]){
        
        
        print("running func deleteNonUsers inputs - eventID: \(eventID) userNames: \(userNames)")
        
        let docRefUserEventStore = dbStore.collection("temporaryUserEventStore")
        
        for names in userNames{
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).whereField("name", isEqualTo: names).getDocuments() { (querySnapshot, err) in
            
            print("querySnapshot: \(String(describing: querySnapshot))")
            
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    let documentID = document.documentID
                    print("documentID: \(documentID)")
                    
                    docRefUserEventStore.document(documentID).delete()
                }}}}}
    
        
        
    func getDayOfTheWeekArray2(eventID: String, userEventStoreID: String, completion: @escaping (_ daysOfTheWeek2: [Int], _ userEventStoreID: String) -> Void){
        
        
        print("running func getDayOfTheWeekArray2 inputs - eventID: \(eventID)")
        
        let docRef = dbStore.collection("eventRequests").document(eventID)
        print(eventID)
        var daysOfTheWeek2 = [Int]()
        
        docRef.getDocument(
            completion: { (document, error) in
                if error != nil {
                    print("Error getting documents")
                }
                else {
                    
                    daysOfTheWeek2 = document?.get("daysOfTheWeek") as? [Int] ?? [10,10,10,10,10,10,10]
                    
                    print("daysOfTheWeek2 \(daysOfTheWeek2)")
                    completion(daysOfTheWeek2, userEventStoreID)
                    
                }})
    
    }
    
    
    func checkCalendarStatus2(){
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            requestAccessToCalendar2()
        case EKAuthorizationStatus.authorized:
            print("We got access to the calendar")
            loadCalendars2()
        case EKAuthorizationStatus.denied:
            print("No access to the calendar")
            showNoAccessToCalendarAlert()

            
        case .restricted:
            print("Access denied to the calendar")
        }
        
    }
      
//        function to show the settings page to the user, so that they can change the calendar settings, this will only occur when the user has denied the App access.
    func showNoAccessToCalendarAlert(){
            
            if UserDefaults.standard.bool(forKey: "dismissCalendarAccess") == true {
                
            }
            else{
            
 
            let alertEventComplete = UIAlertController(title: "No access to calendar", message: "Planr doesn't have access to your calendar and can't determine your availability, select Settings to manually enable access or Dismiss and the App will not show this message again", preferredStyle: UIAlertController.Style.alert)
            
                                        alertEventComplete.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
            
                                            print("User selected take me to settings")
                                            
                                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                                return
                                            }
                                            
                                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                                print("Settings opened: \(success)") // Prints true
                                            })}
                                        }))
            
                                            alertEventComplete.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: { action in
            
                                            print("User selected dismiss")
            
                                           UserDefaults.standard.set(true, forKey: "dismissCalendarAccess")
            
                                        }))
            
            
                                        self.present(alertEventComplete, animated: true, completion: {
                                        })
            
            
            
            }}
        
        
    
    //        request access to the users calendar
    func requestAccessToCalendar2() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                //                print("we got access")
            }
            else{
                print("no access to the calendar")
            }
            
        })
    }
    
    
    
    func getCalendarData2(startDate: Date, endDate: Date) -> (datesOfTheEvents: Array<Date>, startDatesOfTheEvents: Array<Date>, endDatesOfTheEvents: Array<Date>){
        
        
        print("running func getCalendarData2 inputs - startDate: \(startDate) endDate: \(endDate)")
        
        var datesOfTheEvents = Array<Date>()
        var startDatesOfTheEvents = Array<Date>()
        var endDatesOfTheEvents = Array<Date>()
        var calendarToUse: [EKCalendar]?
        if SelectedCalendarsStruct.calendarsStruct.count == 0 {
            calendarToUse = calendars
            
            print("calendars being used \(String(describing: calendarToUse))")
            
        }
        else{
            calendarToUse = SelectedCalendarsStruct.calendarsStruct
            
            print("calendars being used \(String(describing: calendarToUse))")
            
        }
        datesOfTheEvents.removeAll()
        startDatesOfTheEvents.removeAll()
        endDatesOfTheEvents.removeAll()
        calendarArray = eventStore.events(matching: eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: calendarToUse))
        
        
        print("Start date of the period to search \(startDate)")
        print("End date of the period to search \(endDate)")
        
        //                print(calendarArray)
        
        numberOfItems = calendarArray.count
        
        for event in calendarArray{
            
            //            appends new items into the array calendarEventsArray
            let newItemInArray = Event()
            newItemInArray.alarms = event.alarms
            newItemInArray.title = event.title
            newItemInArray.location = event.location!
            newItemInArray.URL = event.url
            newItemInArray.lastModified = event.lastModifiedDate
            newItemInArray.startDate = event.startDate
            newItemInArray.endDate = event.endDate
            newItemInArray.allDay = event.isAllDay
            newItemInArray.recurrence = event.recurrenceRules
            newItemInArray.attendees = event.attendees
            newItemInArray.timezone = event.timeZone
            newItemInArray.availability = event.availability
            newItemInArray.occuranceDate = event.occurrenceDate
            
            calendarEventArray.append(newItemInArray)
            
            //                creates an array of the dates on which the user has events
            datesOfTheEvents.append(event.occurrenceDate)
            startDatesOfTheEvents.append(event.startDate)
            endDatesOfTheEvents.append(event.endDate)
            
            print("dates of the events \(datesOfTheEvents)")
            print("start dates of the events \(startDatesOfTheEvents)")
            print("end dates of the events \(endDatesOfTheEvents)")
            
        }
        
        return (datesOfTheEvents: datesOfTheEvents, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents)
        
        
    }
    
    
    
    func commitUserAvailbilityData(userEventStoreID: String, finalAvailabilityArray2: [Int]){
        
        let dbStoreInd = Firestore.firestore()
    
        print("running func commitUserAvailbilityData inputs - userEventStoreID: \(userEventStoreID) finalAvailabilityArray2: \(finalAvailabilityArray2)")
    
    
        dbStoreInd.collection("userEventStore").document(userEventStoreID).setData(["userAvailability" : finalAvailabilityArray2,"userResponded": true], merge: true)
    
    }
    
//    function to adjust the days of the week for timezones, if the users is in a timezone where there start date of thier event will be the next day we adjust thier days of the week array forward one day
    func adjustDaysOfWeekArrayForTZ(daysOfTheWeek: [Int], hoursToGMT: Int, startTime: String) -> [Int]{
        
      print("running func adjustDaysOfWeekArrayForTZ inputs - daysOfTheWeek: \(daysOfTheWeek) hoursToGMT: \(hoursToGMT) startTime: \(startTime)")
        
        var useableTime = Int()
        var n = 6

        var newDaysOfTheWeek = [Int]()
        
//      convert the time into a useable
        useableTime = Int(startTime[..<2].string) ?? 0
        print("useableTime: \(useableTime)")
        print("useableTime + hoursToGMT: \(useableTime + hoursToGMT)")
        
        if useableTime + hoursToGMT < 0 {
            
            while n >= 0 {
                
                if n == 0 && daysOfTheWeek[6] != 10 && daysOfTheWeek[0] != 10{
                    
                  
                    newDaysOfTheWeek.insert(0, at: 0)
                    newDaysOfTheWeek[1] = 1
                }
                else if n == 0 && daysOfTheWeek[6] != 10{
                    
                    newDaysOfTheWeek.insert(0, at: 0)
                    newDaysOfTheWeek[1] = 10
                }
                else if n == 0 && daysOfTheWeek[0] == 10{
                    
                    newDaysOfTheWeek.insert(10, at: 0)
                    newDaysOfTheWeek[1] = 10
                }
                else if daysOfTheWeek[n - 1] != 10{
                   newDaysOfTheWeek.insert(n, at: 0)
                }
                else if daysOfTheWeek[n - 1] == 10{
                    newDaysOfTheWeek.insert(10, at: 0)
                }
                
                n = n - 1
            }
            print("newDaysOfTheWeek: \(newDaysOfTheWeek)")
            return newDaysOfTheWeek
            
        }
            
            
        else{
            print("daysOfTheWeek: \(daysOfTheWeek)")
            return daysOfTheWeek
            
            
        }
        
    
    }
    
    
//    function to adjust the days of the week array for event end times that end the following day
    func adjustDaysOfWeekArrayForLateEnd(daysOfTheWeek: [Int]) -> [Int]{
        
        print("running func adjustDaysOfWeekArrayForTZLateEnd inputs - daysOfTheWeek: \(daysOfTheWeek)")
        
        var n = 0
        
        var newDaysOfTheWeek = [0]

            while n <= 6 {
                
                if n == 6 && daysOfTheWeek[n] != 10 && daysOfTheWeek[n - 1] != 10{
                   newDaysOfTheWeek[0] = 0
                    newDaysOfTheWeek[6] = 6
   
                }
                else if n == 6 && daysOfTheWeek[n] != 10 && daysOfTheWeek[n - 1] == 10{
                    newDaysOfTheWeek[0] = 0
                    newDaysOfTheWeek[6] = 10
   
                }
                else if n == 6 && daysOfTheWeek[n] == 10 {
                    newDaysOfTheWeek[0] = 10
                }

               else if daysOfTheWeek[n] != 10{
                    
                 newDaysOfTheWeek.insert(n + 1, at: n + 1)
                    
                }
                else if daysOfTheWeek[n] == 10{
                    
                  newDaysOfTheWeek.insert(10, at: n + 1)
                }

                n = n + 1
            }
            return newDaysOfTheWeek
            
        }
    
        
        
    //        adds the event to the calendar
        func addEventToCalendar(title: String, description: String?, startDate: String, endDate: String, location: String, eventOwner: String, startDateDisplay: String, eventOwnerID: String, locationLongitude: Double, locationLatitude: Double, userEventStoreID: String, calendarEventIDInput: String, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
            
            
            var calendarEventID = String()
            
        print("running func addEventToCalendar inputs - title: \(title), description: \(description!), startDate: \(startDate), endDate: \(endDate), location:\(location), userEventStoreID: \(userEventStoreID), calendarEventIDInput: \(calendarEventIDInput)")
            
//        let dateFormatterForResultsCreateEvent = DateFormatter()
//        dateFormatterForResultsCreateEvent.dateFormat = "E d MMM HH:mm"
//        dateFormatterForResultsCreateEvent.locale = Locale(identifier: "en_US_POSIX")
        
        var eventOwnerName = String()
        var alertText = String()
        var alertTitle = String()
            
        let dateFormatterTZCreate = DateFormatter()
        dateFormatterTZCreate.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZCreate.locale = Locale(identifier: "en_US_POSIX")
        let displayDate = convertToDisplayDate(inputDate: startDateDisplay)
        

        
        let chosenStartDateDate = dateFormatterTZCreate.date(from:startDate)
        print("chosenStartDateDate: \(String(describing: chosenStartDateDate))")
        let chosenEndDateDate = dateFormatterTZCreate.date(from:endDate)
        print("chosenEndDateDate: \(String(describing: chosenEndDateDate))")
            
            
            if eventOwnerID == user!{
                
                eventOwnerName = "You have"
            }
            else{
                
                eventOwnerName = ("\(eventOwner) has")
            }
        
            
//            checks to see if the event is already in the calendar, the alert message text is updated accordingly
            if calendarEventIDInput == ""{
                
                alertTitle = "Event Date Chosen"
                alertText = ("\(eventOwnerName) chosen the date for event \( description!), on \(displayDate), would you like to add it to your phone calendar? The event can now be found in Confirmed Events") 
            }
            else{
                
                alertTitle = "Event Updated"
               alertText = ("\(eventOwnerName) has changed the date of event \( description!), now on \(displayDate), would you like to add it to your phone calendar?")
            }
    
        
        let eventStore = EKEventStore()
        let defaultCalendarToSave = UserDefaults.standard.string(forKey: "saveToCalendar") ?? ""
        
        let alert = UIAlertController(title: alertTitle, message: alertText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { action in
            print("user chose to save down the new event")
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    
                    if calendarEventIDInput == "" || eventStore.event(withIdentifier: calendarEventIDInput) == nil{
                    
                  let event = EKEvent(eventStore: eventStore)
                    
                    //                    let event = EKEvent(eventStore: eventStore)
                        event.title = title
                        print("Event being saved: Title \(String(describing: event.title))")
                        event.startDate = chosenStartDateDate
                        print("Event being saved: startDate \(String(describing: event.startDate))")
                        event.endDate = chosenEndDateDate
                        print("Event being saved: endDate \(String(describing: event.endDate))")
                        event.notes = description
                        print("Event being saved: description \(String(describing: event.description))")
                        
                        if locationLongitude == 0.0{
                            
                            event.location = location
                            print("Event being saved: Location \(String(describing: event.location))")
                            
                        }
                        else{
                            
                            let geoLocation = CLLocation(latitude: locationLatitude, longitude: locationLongitude)
                            let structuredLocation = EKStructuredLocation(title: location)
                            
                            structuredLocation.geoLocation = geoLocation
                            event.structuredLocation = structuredLocation
                            
                        }
                        
                        if defaultCalendarToSave == ""{
                            event.calendar = eventStore.defaultCalendarForNewEvents
                        }
                        else{
                            event.calendar = eventStore.calendar(withIdentifier: UserDefaults.standard.string(forKey: "saveToCalendar")!)
                            
                        }
                        print("Event being saved: calendar being saved to \(String(describing: event.calendar))")
                        
                        
                        do {
                            try eventStore.save(event, span: .thisEvent)
                    
                            print("Trying to save down event")
                        } catch let e as NSError {
                            completion?(false, e)
                            return
                        }
                        
                    calendarEventID = event.eventIdentifier ?? "NO ID"
                        
                        
                        dbStore.collection("userEventStore").document(userEventStoreID).setData(["calendarEventID" : calendarEventID, "chosenDateSeen" : true], merge: true)
                        
                        completion?(true, nil)
                        
                        print("event saved for date \(startDate)")
                    
                }
                else{
                                    
                   let event = eventStore.event(withIdentifier: calendarEventIDInput)!
                    //                    let event = EKEvent(eventStore: eventStore)
                        event.title = title
                        print("Event being saved: Title \(String(describing: event.title))")
                        event.startDate = chosenStartDateDate
                        print("Event being saved: startDate \(String(describing: event.startDate))")
                        event.endDate = chosenEndDateDate
                        print("Event being saved: endDate \(String(describing: event.endDate))")
                        event.notes = description
                        print("Event being saved: description \(String(describing: event.description))")
                        
                        if locationLongitude == 0.0{
                            
                            event.location = location
                            print("Event being saved: Location \(String(describing: event.location))")
                            
                        }
                        else{
                            
                            let geoLocation = CLLocation(latitude: locationLatitude, longitude: locationLongitude)
                            let structuredLocation = EKStructuredLocation(title: location)
                            
                            structuredLocation.geoLocation = geoLocation
                            event.structuredLocation = structuredLocation
                            
                        }
                        
                        if defaultCalendarToSave == ""{
                            event.calendar = eventStore.defaultCalendarForNewEvents
                        }
                        else{
                            event.calendar = eventStore.calendar(withIdentifier: UserDefaults.standard.string(forKey: "saveToCalendar")!)
                            
                        }
                        print("Event being saved: calendar being saved to \(String(describing: event.calendar))")
                        
                        
                        do {
                            try eventStore.save(event, span: .thisEvent)
                    
                            print("Trying to save down event")
                        } catch let e as NSError {
                            completion?(false, e)
                            return
                        }
                        
                        calendarEventID = event.eventIdentifier ?? "NO ID"
                        
                        
                        dbStore.collection("userEventStore").document(userEventStoreID).setData(["chosenDateSeen" : true], merge: true)
                        
                        completion?(true, nil)
                        
                        print("event saved for date \(startDate)")
                    
                }
                    

                }
                
                
                else {
                    completion?(false, error as NSError?)
                    print(error ?? "no error message")
                    print("error saving event")
                }
            }
            )}))
        
        alert.addAction(UIAlertAction(title: "Reject", style: .cancel, handler: { action in
            print("user chose not to save the new event - chosenDateSeen set")
            
            dbStore.collection("userEventStore").document(userEventStoreID).setData(["chosenDateSeen" : true], merge: true)
            
        }))
            
            if self.presentedViewController == nil {
                self.present(alert, animated: true)
            }
            else {
                self.dismiss(animated: false, completion: nil)
                self.present(alert, animated: true)
            }
        
    }
    
    
//    function to calculate the number of respondents who are available
    func resultsSummary(resultsArray: [[Any]]) -> (countedResults: [[Any]], fractionResults: [[Float]]){
        
        print("running func resultsSummary - inputs - resultsArray: \(resultsArray)")
        
        countedResultArrayFraction.removeAll()
        
        var resultCounter = 0
        var countedResultArray = [Any]()
        
        //        number of rows in the results array, we only loop through those that include results
        let numberOfRows = resultsArray.count
        
        print("numberOfRows: \(numberOfRows)")
        
        let numberOfColumns = resultsArray[1].count
        print("numberOfColumns: \(numberOfColumns)")
        
        var n = 1
        var y = 1
        
        
        //        0 = row
//        print(resultsArray[0][2])
        
        
        while n <= numberOfColumns - 1  {
            
            while y <= numberOfRows - 1 {
                
                if resultsArray[y][n] as! Int == 1{
                    
                    resultCounter = resultCounter + 1
                    
                }
                else{
                    //                    don't do anything
                }
                y = y + 1
                
            }
            countedResultArray.append("\(resultCounter)/\(numberOfRows - 1)")
            countedResultArrayFraction.append((Float(Double(resultCounter)/(Double(numberOfRows - 1)))))
            resultCounter = 0
            y = 1
            n = n + 1
            
        }
        
        countedResultArray.insert("Availability", at: 0)
        
        
        print("countedResultArray: \(countedResultArray) countedResultArrayFraction \(countedResultArrayFraction)")
        return (countedResults: [countedResultArray], fractionResults: [countedResultArrayFraction])
        
    }
    
    func dateInXDays(increment: Int, additionType: Calendar.Component) -> Date{
        
        let todaysDate = Date()
        let calendar = NSCalendar.current
        
        let newDate = calendar.date(byAdding: additionType, value: increment, to: todaysDate)!
        
        
        return newDate
        
    }
    
    
    //    input formats dates: yyyy-MM-dd
    func getStartAndEndDates3(startDate: String, endDate: String, startTime: String, endTime: String, daysOfTheWeek: [Int], completion: @escaping (_ startDates: [String], _ endDates: [String]) -> Void){
        
        print("running func getStartAndEndDates3 inputs - startDate: \(startDate) endDate: \(endDate) startTime: \(startTime) endTime: \(endTime) daysOfTheWeek: \(daysOfTheWeek)")
        
        var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
        var hoursFromGMT = secondsFromGMT / 3600
        var hoursFromGMTString = String()
        if hoursFromGMT >= 0{
            hoursFromGMTString = ("+\(hoursFromGMT)")
            
        }
        else{
           hoursFromGMTString = ("\(hoursFromGMT)")
            
        }
        var startDates = [String]()
        var endDates = [String]()
        let calendar = NSCalendar.current
        let dateFormatter = DateFormatter()
        let dateFormatterTime = DateFormatter()
        let tz = TimeZone.current.abbreviation()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        
        //        create a start and end date with time from the strings input into the function
        
      
        let startDateString = ("\(startDate) \(startTime) GMT\(hoursFromGMTString)")
        print("startDateString: \(startDateString)")
        let startEndDateString = ("\(startDate) \(endTime) GMT\(hoursFromGMTString)")
        print("startEndDateString: \(startEndDateString)")
        let endDateString = ("\(endDate) \(endTime) GMT\(hoursFromGMTString)")
        print("endDateString: \(endDateString)")
        
        //        convert the sring dates into NSDates
        var startDateDate = dateFormatter.date(from: startDateString)
        print("startDateDate: \(startDateDate!)")
        var startEndDateDate = dateFormatter.date(from: startEndDateString)
        print("startDateDate: \(startDateDate!)")
        let endDateDate = dateFormatter.date(from: endDateString)
        print("endDateDate: \(endDateDate!)")
        
        startDates.removeAll()
        endDates.removeAll()
        
        while startDateDate! <= endDateDate! {
            
            let startDateDateString = dateFormatter.string(from: startDateDate!)
            let dayOfWeekStart = getDayOfWeek3(startDateDateString)! - 1
            print("dayOfWeekstart: \(dayOfWeekStart)")
            
            if daysOfTheWeek.contains(dayOfWeekStart) {
                
                startDates.append(startDateDateString)
                startDateDate = calendar.date(byAdding: .day, value: 1, to: startDateDate!)!
                
            }
            else{
                
                startDateDate = calendar.date(byAdding: .day, value: 1, to: startDateDate!)!
                
            }
            
        }
        print("startDates: \(startDates)")
        
        var endDatetz = endDateDate!

        
        while startEndDateDate! <= endDatetz {
            
//            We need to adjust the end time when coming out of daylight savings time, if the current date we are checking is not in daylight savings time then we move the hour of the end date forward by 1
            
            let dayLight = TimeZone.current
            
            if dayLight.isDaylightSavingTime(for: startEndDateDate!) {
                
                endDatetz = endDateDate!
   
            }
            else{

                endDatetz = calendar.date(byAdding: .hour, value: 1, to: endDateDate!)!
                
            }
            
            let startEndDateDateString = dateFormatter.string(from: startEndDateDate!)
            let dayOfWeekEnd = getDayOfWeek3(startEndDateDateString)! - 1
            //            print("dayOfWeekEnd: \(dayOfWeekEnd)")
            
            if daysOfTheWeek.contains(dayOfWeekEnd) {
                
                endDates.append(startEndDateDateString)
                startEndDateDate = calendar.date(byAdding: .day, value: 1, to: startEndDateDate!)!
                
            }
            else{
                
                startEndDateDate = calendar.date(byAdding: .day, value: 1, to: startEndDateDate!)!
                
            }
            
        }
        print("endDates: \(endDates)")
        
        completion(startDates, endDates)
        
    }
    
    func getDayOfWeek3(_ today:String) -> Int? {
        
        //        print("running func getDayOfWeek2 inputs - today: \(today)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let todayDate = dateFormatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        //        print("weekday \(weekDay)")
        return weekDay
    }
    
    
    func compareTheEventTimmings3(datesBetweenChosenDatesStart: [String], datesBetweenChosenDatesEnd: [String], startDatesOfTheEvents: Array<Date>, endDatesOfTheEvents: Array<Date>) -> Array<Int>{
        print("running func compareTheEventTimmings3 inputs - datesBetweenChosenDatesStart:\(datesBetweenChosenDatesStart) datesBetweenChosenDatesEnd: \(datesBetweenChosenDatesEnd) startDatesOfTheEvents:\(startDatesOfTheEvents) endDatesOfTheEvents: \(endDatesOfTheEvents)")
        let numeberOfDatesToCheck = datesBetweenChosenDatesStart.count - 1
        print("numeberOfDatesToCheck: \(numeberOfDatesToCheck)")
        let numberOfEventDatesToCheck = startDatesOfTheEvents.count - 1
        var finalAvailabilityArray = Array<Int>()
        var n = 0
        var y = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        finalAvailabilityArray.removeAll()
        
//        validation to cofirm the data pulled from the database is correct, we have the same number of start and end dates
        if datesBetweenChosenDatesStart.count == 0 || datesBetweenChosenDatesEnd.count == 0 || datesBetweenChosenDatesStart.count != datesBetweenChosenDatesEnd.count{
            
            print("Fatal Error, one of the date lists is empty")
            
        }
//            If the user doesn't have any events in thier calendar for the period we create a useravailability array of 0
        if startDatesOfTheEvents.count == 0{
            
            print("User deosn't have events in thier calendar for this period")
        
            while y <= numeberOfDatesToCheck{
                print("y \(y)")
                
                finalAvailabilityArray.append(1)
                
                y = y + 1
     
            }
            
            
        }
            
        else{
            
            
            datesLoop: while y <= numeberOfDatesToCheck {
                
                print("y \(y)")
                
                eventsLoop: while n <= numberOfEventDatesToCheck {
                    //                debug only
                    //                            print("n \(n)")
                    //                            print("Start dates between chosen dates \(datesBetweenChosenDatesStart)")
                    //                            print("End dates between chosen dates\(datesBetweenChosenDatesEnd)")
                    //                            print("Start Date of the events to check \(startDatesOfTheEvents)")
                    //                            print("End Date of the events to check \(endDatesOfTheEvents)")
                    //                            print("Date Test Start: Start Date \(datesBetweenChosenDatesStart[y]) End Date \(datesBetweenChosenDatesEnd[y]) Date to test \(startDatesOfTheEvents[n])")
                    //                            print("Date Test End: Start Date \(datesBetweenChosenDatesStart[y]) End Date \(datesBetweenChosenDatesEnd[y]) Date to test \(endDatesOfTheEvents[n])")
                    
                    let datesBetweenChosenDatesStartDate = dateFormatter.date(from: datesBetweenChosenDatesStart[y])!
                    let datesBetweenChosenDatesEndDates = dateFormatter.date(from: datesBetweenChosenDatesEnd[y])!
                    
                    if startDatesOfTheEvents[n] < datesBetweenChosenDatesStartDate && endDatesOfTheEvents[n] > datesBetweenChosenDatesEndDates || (datesBetweenChosenDatesStartDate ... datesBetweenChosenDatesEndDates).contains(startDatesOfTheEvents[n]) == true || (datesBetweenChosenDatesStartDate ... datesBetweenChosenDatesEndDates).contains(endDatesOfTheEvents[n]) == true{
                        print("within the dates to test")
                        finalAvailabilityArray.append(0)
                        print(finalAvailabilityArray)
                        n = 0
                        if y == numeberOfDatesToCheck{
                            
                            print("break point y checks complete: \(y) numeberOfDatesToCheck \(numeberOfDatesToCheck)")
                            
                            break datesLoop
                            
                        }
                        else{
                            y = y + 1
                            n = 0
                        }
                        
                    }
                    else {
                        
                        if n == numberOfEventDatesToCheck && y == numeberOfDatesToCheck{
                            finalAvailabilityArray.append(1)
                            print(finalAvailabilityArray)
                            print("Outside dates to test and end of the list of event dates and dates to test")
                            
                            
                            break datesLoop
                            
                        }
                        else if n == numberOfEventDatesToCheck{
                            print("Outside dates to test and end of the list of dates to test, going to next event date")
                            finalAvailabilityArray.append(1)
                            print(finalAvailabilityArray)
                            y = y + 1
                            n = 0
                        }
                        else{
                            print("Outside dates to test")
                            
                            n = n + 1
                        }
                    }
                    
                }
                n = n + 1
                
            }}
        print(finalAvailabilityArray)
        return finalAvailabilityArray
    }
    
    
    func getArrayOfChosenDates3(eventID: String, completion: @escaping (_ startDates: [String], _ endDates: [String]) -> Void){
        
        print("running func getArrayOfChosenDates3 - with inputs eventID: \(eventID)")
    
        let docRef = dbStore.collection("eventRequests").document(eventID)
        var startDates = [String]()
        var endDates = [String]()
        
        docRef.getDocument(
            completion: { (document, error) in
                if error == nil {
                    
                    startDates = document!.get("startDates") as! [String]
                    endDates = document!.get("endDates") as! [String]
                    
                    print("getArrayOfChosenDates3 output startDates: \(startDates), endDates: \(endDates)")
                    
                    completion(startDates,endDates)
                    
                }
                else{
                    
                    print("error getting documents \(String(describing: error))")
                    
                    completion(startDates,endDates)
                    print("getArrayOfChosenDates3 output startDates: \(startDates), endDates: \(endDates)")
                }
        })

    }
    
    func getCalendarData3(startDate: Date, endDate: Date) -> (datesOfTheEvents: Array<Date>, startDatesOfTheEvents: Array<Date>, endDatesOfTheEvents: Array<Date>){
        
        
        print("running func getCalendarData2 inputs - startDate: \(startDate) endDate: \(endDate)")
        
        var datesOfTheEvents = Array<Date>()
        var startDatesOfTheEvents = Array<Date>()
        var endDatesOfTheEvents = Array<Date>()
        var calendarToUse: [EKCalendar]?
        let eventStore = EKEventStore()
        var calendarArray = [EKEvent]()
        var calendarEventArray : [Event] = [Event]()
        if SelectedCalendarsStruct.calendarsStruct.count == 0 {
            calendarToUse = calendars}
        else{
            calendarToUse = SelectedCalendarsStruct.calendarsStruct}
        datesOfTheEvents.removeAll()
        startDatesOfTheEvents.removeAll()
        endDatesOfTheEvents.removeAll()
        calendarArray = eventStore.events(matching: eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: calendarToUse))
        
        print("Start date of the period to search \(startDate)")
        print("End date of the period to search \(endDate)")
        
        //                print(calendarArray)
        
        
        for event in calendarArray{
            
            //            appends new items into the array calendarEventsArray
            let newItemInArray = Event()
            newItemInArray.alarms = event.alarms
            newItemInArray.title = event.title
            newItemInArray.location = event.location ?? ""
            newItemInArray.URL = event.url
            newItemInArray.lastModified = event.lastModifiedDate
            newItemInArray.startDate = event.startDate
            newItemInArray.endDate = event.endDate
            newItemInArray.allDay = event.isAllDay
            newItemInArray.recurrence = event.recurrenceRules
            newItemInArray.attendees = event.attendees
            newItemInArray.timezone = event.timeZone
            newItemInArray.availability = event.availability
            newItemInArray.occuranceDate = event.occurrenceDate
            
            calendarEventArray.append(newItemInArray)
            
            //                creates an array of the dates on which the user has events
            datesOfTheEvents.append(event.occurrenceDate)
            startDatesOfTheEvents.append(event.startDate)
            endDatesOfTheEvents.append(event.endDate)
            
            print("dates of the events \(datesOfTheEvents)")
            print("start dates of the events \(startDatesOfTheEvents)")
            print("end dates of the events \(endDatesOfTheEvents)")
            
        }
        
        return (datesOfTheEvents: datesOfTheEvents, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents)
        
        
    }
    
    //    function used to pull down the information of the event stored in the Firebase database
    func getEventInformation3(  eventID:String, userEventStoreID: String, completion: @escaping (_ userEventStoreID: String, _ eventSecondsFromGMT: Int, _ startDates: [String], _ endDates: [String]) -> Void) {
        
        print("running func getEventInformation3 inputs - eventID: \(eventID)")
        
        let dateFormatterTime = DateFormatter()
        let dateFormatterSimple = DateFormatter()
        let dateFormatterTZ = DateFormatter()
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterSimple.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        
    
        
        
        let docRef = dbStore.collection("eventRequests").document(eventID)
        
        docRef.getDocument(
            completion: { (document, error) in
                if error != nil || document!.get("startDateInput") == nil {
                    print("Error getting documents")
                }
                else {
                    let eventSecondsFromGMT = document!.get("secondsFromGMT") as! Int
                    print("eventSecondsFromGMT: \(eventSecondsFromGMT)")
                    let endDates = document!.get("endDates") as! [String]
                    let startDates = document!.get("startDates") as! [String]
                    daysOfTheWeek = document!.get("daysOfTheWeek") as! [Int]
       
                        completion( userEventStoreID, eventSecondsFromGMT, startDates, endDates)
                    }
                
        })}
    
    
    
    func loadCalendars2(){
        
        var calendars: [EKCalendar]!
         
            calendars = eventStore.calendars(for: EKEntityType.event)
        
        
            
    //        If the calendar array hasnt been created previously then then the function creates a new array
            if SelectedCalendarsStruct.calendarsStruct.count == 0 {
                
                SelectedCalendarsStruct.calendarsStruct = calendars!
                
                
                    SelectedCalendarsStruct.calendarsStruct.removeAll(where: {$0.title == "US Holidays"})
                    
                    SelectedCalendarsStruct.calendarsStruct.removeAll(where: {$0.title == "UK Holidays"})
                    
                    SelectedCalendarsStruct.calendarsStruct.removeAll(where: {$0.title == "Birthdays"})
                
                SelectedCalendarsStruct.calendarsStruct.removeAll(where: {$0.title == "Holidays in United Kingdom"})
                
                
                    
//                    defaults.set(SelectedCalendarsStruct.calendarsStruct, forKey: "selectedCalendars")
                    
                    print("SelectedCalendarsStruct: \(SelectedCalendarsStruct.calendarsStruct)")
   
            }
                else{
                    
                    
                    
                }
        
        
        

            }
    
    
    
    func shareLinkToTheEvent(){
        
        let firstActivityItem = "Hey, I've invited you to an event on the Planr App, download the App to join https://testflight.apple.com/join/LUCwcAoC"
        
        
        let subject = "Plar App - Event Invite"
//                let secondActivityItem : NSURL = NSURL(string: "http//www.circleitapp.com")!
                // If you want to put an image
        //        let image : UIImage = UIImage(named: "image.jpg")!
        

                let activityViewController : UIActivityViewController = UIActivityViewController(
                    activityItems: [firstActivityItem], applicationActivities: nil)
        
                    activityViewController.setValue(subject, forKey: "Subject")

                activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

                // Anything you want to exclude
                activityViewController.excludedActivityTypes = [
                    UIActivity.ActivityType.postToWeibo,
                    UIActivity.ActivityType.print,
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.addToReadingList,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.airDrop,
                    UIActivity.ActivityType.markupAsPDF,
                    UIActivity.ActivityType.openInIBooks,
                    UIActivity.ActivityType.postToTwitter,
                ]
                self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func signOut(){
      
         let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            
            
            
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
        
    }
    

    func checkUserInUserDatabase(){
        
        
        if existingUserLoggedIn == false{
            
        }
        else{
        
        let phoneNumber = UserDefaults.standard.value(forKey: "userPhoneNumber")
        
        
        dbStore.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber!).getDocuments { (querySnapshot, error) in
        
                        print("querySnapshot from user check \(String(describing: querySnapshot))")
        
                        if error != nil {
                            print("there was an error")
                        }
                        else {
                            print("querySnapshot!.isEmpty: \(querySnapshot!.isEmpty)")
        
                            if querySnapshot!.isEmpty {
        
                                print("Empty: querysnapshot: \(String(describing: querySnapshot)), isEmpty: \(String(describing: querySnapshot!.isEmpty))")
        
                                    let alertEventComplete = UIAlertController(title: "Phone number not registered", message: "This phone number isn't linked to an account, please register", preferredStyle: UIAlertController.Style.alert)
        
                                    alertEventComplete.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
        
                                        print("User Selected OK on event creation alert")
        
                                        print("performing notAUserSegue segue")
                                        
                                        self.signOut()
        
                                        self.performSegue(withIdentifier: "userNotInDatabase", sender: self)
        
                                    }))
                                    self.present(alertEventComplete, animated: true, completion: {
                                    })
                                }
                            else {
                                
                                for documents in querySnapshot!.documents{
                                    
                                    let name = documents.get("name")
                                    
                                    UserDefaults.standard.set(name, forKey: "name")
                                    
                                    print("user is in the database")
                                    
                                }
                                
                                

                            }}}}
        }
        
        
        func getUserName(completion: @escaping (_ usersName: String) -> Void){
            
        let userName = UserDefaults.standard.string(forKey: "name")!
//        print("userName \(userName)")
        
        if userName == "" {
            
            dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments { (querySnapshot, error) in
            
                            print("querySnapshot from user check \(String(describing: querySnapshot))")
            
                            if error != nil {
                                print("there was an error")
                            }
                            else {
                                for documents in querySnapshot!.documents{
                                
                                let name = documents.get("name") as! String
                                    
                                    UserDefaults.standard.set(name, forKey: "name")
                                    
                                    completion(name)
                                }
                }}
        }
        else{
            completion(userName)
        }}
    
    
    func buttonSettings(uiButton: UIButton){
        
        uiButton.layer.borderColor = UIColor.lightGray.cgColor
        uiButton.layer.borderWidth = 2
        uiButton.layer.cornerRadius = 5
        uiButton.layer.backgroundColor = UIColor.white.cgColor
        
        uiButton.layer.shadowColor = UIColor.lightGray.cgColor
        uiButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        uiButton.layer.shadowRadius = 4
        uiButton.layer.shadowOpacity = 0.5
        uiButton.layer.masksToBounds = false
        uiButton.alpha = 0.90
   
    }
        
    func labelSettings(uiLabel: UILabel){
             
             uiLabel.layer.borderColor = UIColor.lightGray.cgColor
             uiLabel.layer.borderWidth = 2
             uiLabel.layer.cornerRadius = 5
             uiLabel.layer.backgroundColor = UIColor.white.cgColor
             
             uiLabel.layer.shadowColor = UIColor.lightGray.cgColor
             uiLabel.layer.shadowOffset = CGSize(width: 0, height: 0.5)
             uiLabel.layer.shadowRadius = 4
             uiLabel.layer.shadowOpacity = 0.5
             uiLabel.layer.masksToBounds = false
             uiLabel.alpha = 0.90
        
         }
    
    
        func navigationBarSettings(navigationController: UINavigationController, isBarHidden: Bool, isBackButtonHidden: Bool, tintColour: UIColor){
        
        if isBarHidden == true && isBackButtonHidden == true  {

            navigationController.setNavigationBarHidden(true, animated: true)
            navigationController.navigationItem.setHidesBackButton(true, animated: true)
                    

  
        }
        
        else if isBarHidden == true && isBackButtonHidden == false{
          
            navigationController.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)

            navigationController.navigationBar.tintColor = tintColour
                    
            navigationController.setNavigationBarHidden(true, animated: false)
                    
            navigationController.navigationBar.setBackgroundImage(UIImage(named: ""), for: UIBarMetrics.default)
                    
            navigationController.navigationBar.shadowImage = UIImage(named: "")
                    
            //        Hides the navigation bar back button on the page
            navigationController.navigationItem.setHidesBackButton(false, animated: true)
            
        }
        
        else if isBarHidden == false && isBackButtonHidden == true{
            
            navigationController.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)

            navigationController.navigationBar.tintColor = tintColour
                    
            navigationController.setNavigationBarHidden(false, animated: false)
                    
            navigationController.navigationItem.setHidesBackButton(true, animated: true)
            navigationController.navigationItem.hidesBackButton = true
            
            
        }
        else{
        
        navigationController.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)

        navigationController.navigationBar.tintColor = tintColour
                
        navigationController.setNavigationBarHidden(false, animated: false)
                
        navigationController.navigationItem.setHidesBackButton(false, animated: true)
        navigationController.navigationItem.hidesBackButton = false
            
            
 
        }
    
     }
        
        
        
        func showProgressHUD(notificationMessage: String, imageName: String, delay: Double){
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = notificationMessage
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.customView = UIImageView(image: UIImage(named: imageName))
            loadingNotification.label.adjustsFontSizeToFitWidth = true
            loadingNotification.hide(animated: true, afterDelay: delay)
            
            
            
        }
        
        
        @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
        
        
        func setBackgroundColour(currentView: UIView){
            
            
            currentView.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
            
        }
        
        
        
        
        func getInviteeNames(eventID: String, completion: @escaping (_ userArray: [String]) -> Void){

            print("running func getInviteeNames inputs - eventID: \(eventID)")
            
                var userNameArray = [String]()
                let docRefUserEventStore = dbStore.collection("userEventStore")
                
                docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            
                            
                            
                            let userName = document.get("userName") as? String ?? ""
                            
                            print("func getInviteeNames userName: \(userName)")
                            
                            userNameArray.append(userName)
                            
                            
                        }
                        
                        print("func getInviteeNames complete - userNameArray: \(userNameArray)")
                        
                        completion(userNameArray)
                        
                    }
                    
            }
            
   
        }
        
        
        
             func getInviteeNamesNonUsers(eventID: String, completion: @escaping (_ userArray: [String]) -> Void){

                 print("running func getInviteeNames inputs - eventID: \(eventID)")
                 
                     var userNameArray = [String]()
                     let docRefUserEventStore = dbStore.collection("temporaryUserEventStore")
                     
                     docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
                         if let err = err {
                             print("Error getting documents: \(err)")
                         } else {
                             for document in querySnapshot!.documents {
                                 
                                 
                                 
                                 let userName = document.get("name") as? String ?? ""
                                 
                                 print("func getInviteeNames userName: \(userName)")
                                 
                                 userNameArray.append(userName)
                                 
                                 
                             }
                             
                             print("func getInviteeNames complete - userNameArray: \(userNameArray)")
                             
                             completion(userNameArray)
                             
                         }
                         
                 }
                 
        
             }
        
        
        
        func setAppHeader(colour: UIColor) -> UILabel{
            
            let navLabel = UILabel()
            
            let navTitle = NSMutableAttributedString(string: "Plan",
                                                     attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30),NSAttributedString.Key.foregroundColor: colour])
            
            navTitle.append(NSMutableAttributedString(string: "r",
                                                      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30),NSAttributedString.Key.foregroundColor: colour]))
            
            navLabel.attributedText = navTitle
            
            
            return navLabel
            
        }
        
        
        //    Gets the users names
            func getUsersNames2( completion: @escaping () -> Void){
                
                if selectEventToggle == 0{
                }
                else{
                
                    inviteesNames.removeAll()
                    inviteesNamesNew.removeAll()
                    inviteesNamesLocation.removeAll()
                    deletedUserIDs.removeAll()
                    deletedInviteeNames.removeAll()
                    inviteesUserIDs = eventResultsArrayDetails[8][0] as! Array<String>
                    print("inviteesUserIDs \(inviteesUserIDs)")
                    let numberOfInvitee = inviteesUserIDs.count - 1
                    print("numberOfInvitee: \(numberOfInvitee)")
                

                    for items in inviteesUserIDs {

                        print("inviteesUserIDs: \(items)")
                        
                        dbStore.collection("users").whereField("uid", isEqualTo: items).getDocuments { (querySnapshot, error) in
                            if error != nil {
                                print("Error getting documents: \(error!)")
                            }
                            else {
                                for document in querySnapshot!.documents {
                                    
                                    inviteesNames.append(document.get("name") as! String)
                                    inviteesNamesLocation.append(items)
                                    
                                    print(items)
                                    print("inviteesNames: \(inviteesNames)")
                                    print("inviteesNamesLocation: \(inviteesNamesLocation)")
                                    
                                }
                               completion()
                            }
                        }
                    }
                }

                }
        
        
            

    //    end of globally available functions
    
}

//extension allowing us to convert a hex colour into a colour swift can use
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}



