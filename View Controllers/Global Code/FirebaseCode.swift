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
import BackgroundTasks
import FirebaseStorage

var chatNotificationPending = Bool()
var chatNotificationDateChosen = Bool()
var chatNotificationiDs = [String]()
var eventNotificationPending = Bool()
var eventNotificationiDs = [String]()

// variable to determin if the notification listener is engaged
var notificationListenerEnagaged = Bool()
//variable to hold the listener itself
var notificationListenerRegistration: ListenerRegistration!


class FirebaseCode: UIViewController {
   
}
    
    
extension UIViewController{

    func prepareForEventDetailsPage(eventID: String, isEventOwnerID : String, segueName: String, isSummaryView: Bool, performSegue: Bool, completion: @escaping () -> Void){
            
            summaryView = isSummaryView
            eventIDChosen = eventID
            
        if isEventOwnerID == user{
            
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
    
    
//    function to check if the user has any new events or chat notifications, these are then displayed on the home page
        func checkNotificationStatusListener(){
        print("running func checkNotificationStatusListener")
               
//        we start by getting the previously stored user defaults of the chatIDs from the userDefaults
        var chatNotificationIDsDefaults = UserDefaults.standard.object(forKey: "chatNotificationEventIDs") as? [String]
//        we need to add project around the chatNotificationIDsDefaults incase it equals nil
        if chatNotificationIDsDefaults == nil{
            chatNotificationIDsDefaults = [""]
            chatNotificationiDs = chatNotificationIDsDefaults!
        }
        else{
            chatNotificationiDs = chatNotificationIDsDefaults!
        }
    //        check to see if the user isnt nil
            if user == nil{
             print("running func checkNotificationStatus user is nil, stop running")
            }
            else{
//                check if the listener is already engaged
                if notificationListenerEnagaged == false{
            notificationListenerRegistration = dbStore.collection("userNotification").document(user!).addSnapshotListener(){ (document, error) in
                
                if let document = document, document.exists {
                    let source = document.metadata.hasPendingWrites ? "Local" : "Server"
                    
                    print("checkNotificationStatusListener - source \(source)")
                     chatNotificationPending = document.get("chatNotificationPending") as? Bool ?? false
                     chatNotificationDateChosen = document.get("chatNotificationDateChosen") as? Bool ?? false
                    eventNotificationPending = document.get("eventNotificationPending") as? Bool ?? false
                    eventNotificationiDs.append(contentsOf: document.get("eventNotificationiDs") as? [String] ?? [""])
                    let newChatIDs = document.get("chatNotificationEventIDs") as? [String] ?? [""]
                    chatNotificationiDs = chatNotificationiDs + newChatIDs
                    
                    print("chatNotificationPending \(chatNotificationPending) chatNotificationDateChosen \(chatNotificationDateChosen) eventNotificationPending \(eventNotificationPending) eventNotificationiDs \(eventNotificationiDs) chatNotificationiDs \(chatNotificationiDs) newChatIDs \(newChatIDs)")
                    
                    
                    print("checkNotificationStatusListener chatNotificationiDs \(chatNotificationiDs)")
                    
//                    for the new events with chats, we pull down the chat messages and write them to the DD
//                    loop through the eventIDs
                    for i in newChatIDs{
//                        we need to check that the eventID isnt ""
                        if i == ""{
                        }
                        else{
                            print("checking eventID i \(i)")
                    userMessagesRef = Database.database().reference().child("messages").child(i)
//            create the listener to the node in the databse, we only listen for children added, we do not want to listen for anything else - we may need to add deleted etc at a later date
                userMessagesRef.observe(.value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
//                    it is likely the evnt was deleted, at the point we need to remove the newChatIDs adn remove them from Firebase
                    chatNotificationiDs.removeAll(where: {$0 == i})
//                    delete the notificaiton from Firebase
                    dbStore.collection("userNotification").document(user!).updateData(["chatNotificationEventIDs" : FieldValue.delete(), "eventNotificationiDs" : FieldValue.delete()]){ err in
                            if let err = err {
                            print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                }}
                    
                    
                    print("something went wrong checkNotificationStatusListener - \(snapshot.value)")
                    
                return
                    }
//                        print("checkNotificationStatusListener - chats dictionary \(dictionary)")
//                    we need to loop through each of the messages and sabve them into CoreData
//                    1. retrieve all chat messages for that event
                    let predicate = NSPredicate(format: "eventID == %@", argumentArray: [i])
                    let eventChats = CoreDataCode().serialiseChatMessages(predicate: predicate, usePredicate: true)

                for message in dictionary{
//                    we loop through each message and check if it is already in the database
//                    unpack the message data itself
                    let dict = Message(dictionary: message.value as! [String : Any])
                    
                    if eventChats.contains(where: {$0.messageID == message.key}){
                      print("checkNotificationStatusListener - the message is already in the DB, we do nothing message.key \(message.key)")
                    }
                    else{
                        self.commitSingleChatDB(fromId: dict.fromId!, text: dict.text!, fromName: dict.fromName!, timestamp: dict.timestamp as! Int64, toId: "", eventID: i, messageID: message.key)
                    }
                }
                    print("checkNotificationStatusListener - .notificationsReloaded posted")
                    NotificationCenter.default.post(name: .newChatDataLoaded, object: nil)
                    
//                once we have pulled down the new notification eventID data we need to remove the field
                    dbStore.collection("userNotification").document(user!).updateData(["chatNotificationEventIDs" : FieldValue.delete(), "eventNotificationiDs" : FieldValue.delete()]){ err in
                            if let err = err {
                            print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                }}
                }, withCancel: nil)
//                            we need to remove the observer to ensure we dont keep listening for changes
            }
        }
//        save the chat notifications into the user defaults
//                    UserDefaults.standard.setValue(chatNotificationiDs, forKey: "chatNotificationEventIDs")
                    
                    print("checkNotificationStatusListener - .notificationsReloaded posted")
                    NotificationCenter.default.post(name: .notificationsReloaded, object: nil)
                    
//                    set to true so we dont keep engaging the listener
                    notificationListenerEnagaged = true
                    }}
                }
            }
        }
        
    
//    fucntion to update the  notificaiton for pending events
    func updatePendingNotificationStatus(eventBool: Bool, eventID: String, eventNewNotification: Bool){
        print("running func updatePendingNotificationStatus")
        
//        reset the front page notifications
       chatNotificationPending = false
    eventNotificationPending = false
        
        if user == nil{
        }
        else{
        
//        check to see if the event has been up
        if eventNewNotification == true{
           eventNotificationiDs.removeAll{$0 == eventID}
            print("eventNotificationiDs - \(eventNotificationiDs)")
            
//                once we have pulled down the new notification eventID data we need to remove the field
            dbStore.collection("userNotification").document(user!).updateData(["eventNotificationiDs" : FieldValue.delete()]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                }}
        }
        
//        used for removing the notifications of a specific event - i.e. when the user clicks on a chat notification
        if eventBool == true{
            chatNotificationiDs.removeAll{$0 == eventID}
            print("chatNotificationiDs - \(chatNotificationiDs)")
            
//                once we have pulled down the new notification eventID data we need to remove the field
            dbStore.collection("userNotification").document(user!).updateData(["chatNotificationEventIDs" : FieldValue.delete()]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                }}
            }}
        
        if user == nil{
        }
        else{
            let docRef = dbStore.collection("userNotification").document(user!)
        
      docRef.setData(["chatNotificationPending" : false], merge: true)
    docRef.setData(["eventNotificationPending" : false], merge: true)
        }
    }
    
    func updateDateChosenNotificationStatus(eventBool: Bool, eventID: String){
        print("running func updateDateChosenNotificationStatus")
        
        chatNotificationDateChosen = false
        
        if eventBool == true{
        chatNotificationiDs.removeAll{$0 == eventID}
        print("chatNotificationiDs - \(chatNotificationiDs)")
            
//                once we have pulled down the new notification eventID data we need to remove the field
            dbStore.collection("userNotification").document(user!).updateData(["chatNotificationEventIDs" : FieldValue.delete()]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                }}
        }
        
        if user == nil{
        }
        else{
        
            let docRef = dbStore.collection("userNotification").document(user!)
        
      docRef.setData(["chatNotificationDateChosen" : false], merge: true)
        }
    }
    
//    gather the users availability and send to firebase
    func sendUserAvailability(eventID: String){
        
        if checkCalendarStatus2() == false{
            print("sendUserAvailability - checkCalendarStatus2 = false")
        }
        
        print("running sendUserAvailability with inputs - eventID: \(eventID)")
        
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).whereField("uid", isEqualTo: user).getDocuments() { (querySnapshot, err) in
            
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
            
            print("getUserPushTokenGlobal - querySnapshot \(String(describing: querySnapshot))")
            
            if error != nil {
                print("getUserPushTokenGlobal - there was an error")
            }
            else {
                for document in querySnapshot!.documents {
                    
                    print("getUserPushTokenGlobal - no error")
                 
                    let documentID = document.documentID
                    let name = document.get("name")
                    UserDefaults.standard.set(name, forKey: "name")
                    // Reference for the realtime database
                    let ref = Database.database().reference()
                    
//                    delete the data then re-
                    
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
        
        getUserName{ (usersName) in
        
        print("running func checkForPhoneNumberInvited, inputs: phoneNumber: \(phoneNumber) usersName \(usersName)")
        dbStore.collection("temporaryUserEventStore").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("checkForPhoneNumberInvited Error getting documents: \(error!)")
                completion()
            }
            else {
                print("checkForPhoneNumberInvited there was data count\(querySnapshot!.documents.count)")
//          if nothing has been returned we complete the check
                if querySnapshot!.documents.count == 0{
                  completion()
                }
                for document in querySnapshot!.documents {
                    let eventID = document.get("eventID") as! String
                    print("checkForPhoneNumberInvited aanlysing event: eventID \(eventID)")
//                    pull down the users name as it is shown in the temporaryUserEventStore, we need to remove this from the details list
                    let userCreatedName = document.get("name") as! String
                    let uid = Auth.auth().currentUser?.uid
                    //                    add the required info to the userEventStore
                    fireStoreRef = dbStore.collection("userEventStore").addDocument(data: ["eventID": eventID, "uid": uid!, "userName": usersName]){
                        error in
                        if let error = error {
                            print("checkForPhoneNumberInvited Error adding document: \(error) eventID \(eventID)")
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
                            currentUsersNames.append(usersName)
                            
//                            get the nonUserNames and remove the current users name
                            var nonUserNames = document.get("nonUserNames") as! [String]
                            if let index = nonUserNames.index(of: userCreatedName){
                                nonUserNames.remove(at: index)
                            }
//                            update the userIDs array
                            dbStore.collection("eventRequests").document(eventID).updateData(["users" : FieldValue.arrayUnion([uid!])])
                            print("checkForPhoneNumberInvited adding data to the DB eventID \(eventID) uid! \(uid!) currentUsersNames \(currentUsersNames) newnonUserNames \(nonUserNames)")
//                            update the current user names array
                            dbStore.collection("eventRequests").document(eventID).updateData(["currentUserNames" : FieldValue.arrayUnion(currentUsersNames)])
//                            update the nonUsersName array names array
                            dbStore.collection("eventRequests").document(eventID).updateData(["nonUserNames" : nonUserNames])
                            
//                    we also update the event users in the real time database
                            let rRef = Database.database().reference()
                            rRef.child("events/\(eventID)/invitedUsers").setValue(userIDs)
                            
//                          notify the users that the information has been updated
                            self.eventAmendedNotification(userIDs: userIDs, eventID: eventID, amendWithAvailability: false)
                            self.availabilityAmendedNotification(userIDs: userIDs, availabilityDocumentID: availabilityID)
                        } else {
                            print("Document does not exist")
                        }}}}
                }
                print("checkForPhoneNumberInvited completing")
              completion()
            }
        }}
    }
    
    
    func checkForPhoneNumberInvitedArray(phoneNumber: String, completion: @escaping () -> Void){
        
        var fireStoreRef: DocumentReference? = nil
        
        
        getUserName{ (usersName) in
        
        print("running func checkForPhoneNumberInvitedArray, inputs: phoneNumber: \(phoneNumber)")
        dbStore.collection("temporaryUserEventStore").whereField("phoneNumberList", arrayContains: phoneNumber).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
                    if querySnapshot!.documents.count == 0{
                      completion()
                    }
                    let eventID = document.get("eventID") as! String
//                    pull down the users name as it is shown in the temporaryUserEventStore, we need to remove this from the details list
                    let userCreatedName = document.get("name") as! String
                    let uid = Auth.auth().currentUser?.uid
                    //                    add the required info to the userEventStore
                    fireStoreRef = dbStore.collection("userEventStore").addDocument(data: ["eventID": eventID, "uid": uid!, "userName": usersName]){
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
                            currentUsersNames.append(usersName)
                            
//                            get the nonUserNames and remove the current users name
                            var nonUserNames = document.get("nonUserNames") as! [String]
                            if let index = nonUserNames.index(of: userCreatedName){
                                nonUserNames.remove(at: index)
                            }
//                            update the userIDs array
                            dbStore.collection("eventRequests").document(eventID).updateData(["users" : FieldValue.arrayUnion([uid!])])
//                            update the current user names array
                            dbStore.collection("eventRequests").document(eventID).updateData(["currentUserNames" : FieldValue.arrayUnion(currentUsersNames)])
//                            update the nonUsersName array names array
                            dbStore.collection("eventRequests").document(eventID).updateData(["nonUserNames" : nonUserNames])
                            
//                    we also update the event users in the real time database
                            let rRef = Database.database().reference()
                            rRef.child("events/\(eventID)/invitedUsers").setValue(userIDs)
                            
//                          notify the users that the information has been updated
                            self.eventAmendedNotification(userIDs: userIDs, eventID: eventID, amendWithAvailability: false)
                            self.availabilityAmendedNotification(userIDs: userIDs, availabilityDocumentID: availabilityID)
                        } else {
                            print("Document does not exist")
                        }
                    }
                    }
                                
                    }
                }
                print("checkForPhoneNumberInvited completing")
                completion()
            }
            
        }}
    }
    
    //    deletes the entry for the phone number into the temporaryUserEventStore
    func deletePhoneNumberInvited(phoneNumber: String, completion: @escaping () -> Void){
        
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
                }}}
        completion()
    }
    
    //    deletes the entry for the phone number into the temporaryUserEventStore
    func deletePhoneNumberInvitedArray(phoneNumber: String, completion: @escaping () -> Void){
        
        print("running func deletePhoneNumberInvitedArray, inputs: phoneNumber \(phoneNumber)")
        
        let docRefUserEventStore = dbStore.collection("temporaryUserEventStore")
        
        docRefUserEventStore.whereField("phoneNumberList", arrayContains: phoneNumber).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    print("deleted temporary document")
                    
                    let documentID = document.documentID
                    
//                    FOR Testing REMOVE!!
//                    docRefUserEventStore.document(documentID).updateData(["phoneNumber" : "", "phoneNumberList": ""])
                    
                    
                    docRefUserEventStore.document(documentID).delete()
                }}}
        completion()
    }
    
    
//    this function creates a listener for each node of the realTime database the user has a chat at
//    func createChatListeners(){
//        print("createChatListeners running")
////       we loop through each of the users events
//        
//        
//        
//        for event in CDEevents{
//            let eventID = event.eventID
//            userMessagesRef = Database.database().reference().child("messages").child(eventID!)
//            
////            create the listener to the node in the databse, we only listen for children added, we do not want to listen for anything else - we may need to add deleted etc at a later date
//            userMessagesRef.observe(.childAdded, with: { (snapshot) in
//            print("chatMessageListener triggered chatListenerInt \(chatListenerInt)")
//                     guard let dictionary = snapshot.value as? [String: AnyObject] else {
//                         return
//                     }
//            let message = Message(dictionary: dictionary)
////             serialise the message
//                let CDNewMessage = CoreDataChatMessages(context: context)
//                CDNewMessage.eventID = eventID
//                CDNewMessage.fromId = message.fromId
//                CDNewMessage.timestamp = message.timestamp as! Int64
//                CDNewMessage.text = message.text
//                CDNewMessage.fromName = message.fromName
//                
////        before we save the message we delete any message that is the same
//            if let index = CDMessages.index(where: {$0.eventID == currentUserSelectedEvent.eventID && $0.fromId == message.fromId && $0.text == message.text && $0.timestamp == message.timestamp as! Int64}){
//                context.delete(CDMessages[index])
//                CDMessages.remove(at: index)
//                self.CDSaveData()
//                        }
////        save the new message
//                CDMessages.append(CDNewMessage)
////        print("CDMessages \(CDMessages)")
//                self.CDSaveData()
//                
//                
//            }, withCancel: nil)
//    }
//    }
    
    //    end of the code
}

//set notification names
extension Notification.Name {
     static let notificationsReloaded = Notification.Name("notificationsReloaded")
}
