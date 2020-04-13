//
//  FirebaseCode.swift
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
import BackgroundTasks

var chatNotificationPending = Bool()
var chatNotificationDateChosen = Bool()
var chatNotificationiDs = [String]()


class FirebaseCode: UIViewController {
   
}
    
    
extension UIViewController{

    func prepareForEventDetailsPage(eventID: String, isEventOwnerID : String, segueName: String, isSummaryView: Bool, performSegue: Bool, completion: @escaping () -> Void){
            
            summaryView = isSummaryView
            eventIDChosen = eventID
            
            if isEventOwnerID == user!{
            
            selectEventToggle = 1
            }
            else{
                
                selectEventToggle = 0
                
            }
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Loading"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
            loadingNotification.mode = MBProgressHUDMode.customView
            
            
        //        gets all the event details needed to create the event detail arrays
        addDatesToResultQuery2(eventID: eventID, selectEventToggle: 0){ (arrayForEventResultsPage, arrayForEventResultsPageDetails, numberOfDatesInArray)  in
            
            let noResultsArrayGlobal = self.noResultArrayCompletion2(numberOfDatesInArray: numberOfDatesInArray).noResultsArray
            let nonUserArray = self.noResultArrayCompletion2(numberOfDatesInArray: numberOfDatesInArray).nonUserArray
            
            self.addUserToEventArray2(eventID: eventID, noResultArray: noResultsArrayGlobal){ (arrayForEventResultsPageAvailability, arrayOfUserDocumentIDs) in
                
                self.addNonExistentUsers(eventID: eventID, noResultArray: nonUserArray){ (addNonExistentUsersAvailability, nonExistentNames, nonExistentPhoneNumbers) in
                
                    eventResultsArrayDetails = arrayForEventResultsPageDetails + [nonExistentNames] + [nonExistentPhoneNumbers] + [arrayOfUserDocumentIDs]
                    print("eventResultsArrayDetails \(eventResultsArrayDetails)")
                    
                    let resultsSummary = self.resultsSummary(resultsArray: arrayForEventResultsPage + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability).countedResults
                    
                    fractionResults = self.resultsSummary(resultsArray: arrayForEventResultsPage + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability).fractionResults

                    availabilitySummaryArray = resultsSummary
                    
                    print("resultsSummaryArray: \(resultsSummary)")
                arrayForEventResultsPageFinal = arrayForEventResultsPage + resultsSummary + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability
                print("arrayForEventResultsPageFinal \(arrayForEventResultsPageFinal)")
                    loadingNotification.hide(animated: true)
                
                    
                    if performSegue{
                        NotificationCenter.default.post(name: .availabilityUpdated, object: nil)
                       self.performSegue(withIdentifier: segueName, sender: self)
                        completion()
                    }
                    else{
                        NotificationCenter.default.post(name: .availabilityUpdated, object: nil)
                        completion()
                        
                    }
                
                
            }}}
            
        }

    
    
    func checkEventChatNotificationStatus(eventID: String, completion: @escaping (_ notifcationBool: Bool) -> ()){
        
        print("running func: checkEventChatNotificationStatus inputs: eventID: \(eventID)")
        
        var notifcationBool = Bool()
        
        let ref2 = Database.database().reference().child("messageNotifications").child(eventID).child(user!)
        
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
          // Get notification value
          let value = snapshot.value as? NSDictionary
            
            notifcationBool = value?["notification"] as? Bool ?? false
            
            print("notificationBool \(notifcationBool)")
            
            completion(notifcationBool)
            
          }) { (error) in
            print(error.localizedDescription)
            
            print("notificationBool \(notifcationBool)")
            completion(notifcationBool)
            
        
        }
        
    }
    
//    functiont to check if the user has any new events or chat notifications, these are then displayed on the home page
    func checkNotificationStatus(completion: @escaping () -> Void){
        
        print("running func checkNotificationStatus")
//        check to see if the user isnt nil
        if user == nil{
         print("running func checkNotificationStatus user is nil, stop running")
        }
        else{
        
        
     let docRefEventRequest = dbStore.collection("userNotification").document(user!)
        docRefEventRequest.getDocument { (document, error) in
            if let document = document, document.exists {
             
                 chatNotificationPending = document.get("chatNotificationPending") as? Bool ?? false
                 chatNotificationDateChosen = document.get("chatNotificationDateChosen") as? Bool ?? false
                chatNotificationiDs.append(contentsOf: document.get("chatNotificationEventIDs") as? [String] ?? [""])
                
                print("chatNotificationiDs \(chatNotificationiDs)")
                
//                once we have pulled down the new notification eventID data we need to remove the field
                dbStore.collection("userNotification").document(user!).updateData(["chatNotificationEventIDs" : FieldValue.delete()]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    }}
                
                completion()
            }
            }}
    }
        
    
    
    
//    fucntion to update the chat notificaiton pending
    func updatePendingNotificationStatus(){
        
       chatNotificationPending = false
        
        if user == nil{
        }
        else{
     let docRef = dbStore.collection("userNotification").document(user!)
        
      docRef.setData(["chatNotificationPending" : false], merge: true)
            
        }
    }
    
    func updateDateChosenNotificationStatus(){
        
        chatNotificationDateChosen = false
        
        if user == nil{
        }
        else{
        
     let docRef = dbStore.collection("userNotification").document(user!)
        
      docRef.setData(["chatNotificationDateChosen" : false], merge: true)
        }
    }
    
    
    func sendUserAvailability(eventID: String){
        
        print("running sendUserAvailability with inputs - eventID: \(eventID)")
        
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).whereField("uid", isEqualTo: user!).getDocuments() { (querySnapshot, err) in
            
            print("querySnapshot: \(String(describing: querySnapshot))")
            print("is querySnapshot empty \(String(describing: querySnapshot?.isEmpty))")
            
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                
                for document in querySnapshot!.documents{
                    
                let documentID = document.documentID
                

                    self.getEventInformation3(eventID: eventID, userEventStoreID: documentID) { (userEventStoreID, eventSecondsFromGMT, startDates, endDates, users) in
                                
                                print("Succes getting the event data")
                                
                                print("startDates: \(startDates), endDates: \(endDates)")
                                
                                
                                let numberOfDates = endDates.count - 1
                        
                                let dateFormatterTZ = DateFormatter()
                                dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
                                dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
                                
                                let startDateDate = dateFormatterTZ.date(from: startDates[0])
                                let endDateDate = dateFormatterTZ.date(from: endDates[numberOfDates])

                                let endDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).endDatesOfTheEvents
                                let startDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).startDatesOfTheEvents
        
                                let finalAvailabilityArray2 = self.compareTheEventTimmings3(datesBetweenChosenDatesStart: startDates, datesBetweenChosenDatesEnd: endDates, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents)
                                
                                
                                
//                          Add notitications that the availability has been loaded
                        self.availabilityCreatedNotification(userIDs: users, availabilityDocumentID: userEventStoreID)
//                        add the finalAvailabilityArray to the userEventStore
                        self.commitUserAvailbilityData(userEventStoreID: userEventStoreID, finalAvailabilityArray2: finalAvailabilityArray2, eventID: eventID)
                                }}}}}
    
    func getUserPushTokenGlobal(){
        
        print("running func getUserPushTokenGlobal")
    InstanceID.instanceID().instanceID { (result, error) in
    if let error = error {
    print("Error fetching remote instance ID: \(error)")
    } else if let result = result {
    print("Remote instance ID token: \(result.token)")
        
        if user == nil{
            
            print("user hasn't signed-in yet")
            
        }
        else{
    
        dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments { (querySnapshot, error) in
            
            print("querySnapshot \(String(describing: querySnapshot))")
            
            if error != nil {
                print("there was an error")
            }
            else {
                for document in querySnapshot!.documents {
                 
                    let documentID = document.documentID
                    let name = document.get("name")
                    UserDefaults.standard.set(name, forKey: "name")
                    // Reference for the realtime database
                    let ref = Database.database().reference()
                    
                    dbStore.collection("users").document(documentID).setData(["tokenID" : result.token], merge: true)
                    
                    ref.child("users/\(user!)/\(result.token)").setValue(result.token)
                    ref.child("users/\(user!)/name").setValue(name)

                    
                }}}}}}}
    
    
    
//    MARK: section to retrieve the non-user who have been invited
    
    func getNonUsers(eventID: String, completion: @escaping(_ userNames: [String],_ userNumbers: [String]) -> Void){
        print("running func getNonUsers inputs - eventID \(eventID)")
        
        var namesArray = [String]()
        var numbersArray = [String]()
        
        dbStore.collection("temporaryUserEventStore").whereField("eventID", isEqualTo: eventID).getDocuments { (querySnapshot, error) in
        if error != nil {
            print("Error getting documents: \(error!)")
        }
        else {
            for document in querySnapshot!.documents {
                
                namesArray.append(document.get("name") as! String)
                numbersArray.append(document.get("phoneNumber") as! String)
            }
            print("output for func getNonUsers inputs - userNames: \(namesArray), userNumbers: \(numbersArray)")
            completion (namesArray, numbersArray)
            
            }
        }

    }
    
    
    //    MARK: section get any events the user has already been invited to, move them from temporary and adds them to permanant, it then deletes the temporary entries
    
    func checkForPhoneNumberInvited(phoneNumber: String, completion: @escaping () -> Void){
        
        var fireStoreRef: DocumentReference? = nil
        
        print("running func checkForPhoneNumberInvited, inputs: phoneNumber: \(phoneNumber)")
        dbStore.collection("temporaryUserEventStore").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
                    let eventID = document.get("eventID") as! String
//                    pull down the users name as it is shown in the temporaryUserEventStore, we need to remove this from the details list
                    let userCreatedName = document.get("name") as! String
                    let uid = Auth.auth().currentUser?.uid
                    //                    add the required info to the userEventStore
                    fireStoreRef = dbStore.collection("userEventStore").addDocument(data: ["eventID": eventID, "uid": uid!, "userName": registeredName]){
                        error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
//                print("Document added with ID: \(ref!.documentID)")
                    let availabilityID = fireStoreRef!.documentID

//                    adds the uid to the eventRequests
                    let docRef = dbStore.collection("eventRequests").document(eventID)
                    
//                    add the new users userID to the event,  add the notifiction for everyone invited to update their event
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            
//                            get the userIDs from the eventRequest table, post a new availability notification and event notification for the userIDs
                            var userIDs = document.get("users") as! [String]
                            userIDs.append(uid!)
                            var currentUsersNames = document.get("currentUserNames") as! [String]
                            currentUsersNames.append(registeredName)
                            
//                            get the nonUserNames and remove the current users name
                            var nonUserNames = document.get("nonUserNames") as! [String]
                            if let index = nonUserNames.index(of: userCreatedName){
                                nonUserNames.remove(at: index)
                            }
                            
//                            debug only
//                            print("userIDs \(userIDs)")
//                            print("currentUsersNames \(currentUsersNames)")

//                            update the userIDs array
                            dbStore.collection("eventRequests").document(eventID).updateData(["users" : FieldValue.arrayUnion([uid!])])
//                            update the current user names array
                            dbStore.collection("eventRequests").document(eventID).updateData(["currentUserNames" : FieldValue.arrayUnion(currentUsersNames)])
//                            update the nonUsersName array names array
                            dbStore.collection("eventRequests").document(eventID).updateData(["nonUserNames" : nonUserNames])
                            
//                          notify the users that the information has been updated
                            self.eventAmendedNotification(userIDs: userIDs, eventID: eventID)
                            self.availabilityAmendedNotification(userIDs: userIDs, availabilityDocumentID: availabilityID)
                            
                        } else {
                            print("Document does not exist")
                        }
                    }
                    }
                                
                    }
                  completion()
                }
                
            }
            
        }}
    
    //    deletes the entry for the phone number into the temporaryUserEventStore
    func deletePhoneNumberInvited(phoneNumber: String){
        
        print("running func deletePhoneNumberInvited, inputs: phoneNumber \(phoneNumber)")
        
        let docRefUserEventStore = dbStore.collection("temporaryUserEventStore")
        
        docRefUserEventStore.whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    print("deleted temporary document")
                    
                    let documentID = document.documentID
                    
                    docRefUserEventStore.document(documentID).delete()
                }}}}
    
    //    end of the code
}
