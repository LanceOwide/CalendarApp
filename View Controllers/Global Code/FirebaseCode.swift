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

var chatNotificationPending = Bool()
var chatNotificationDateChosen = Bool()


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
    
    func checkNotificationStatus(completion: @escaping () -> Void){
        
        print("running func checkNotificationStatus")
        
     let docRefEventRequest = dbStore.collection("userNotification").document(user ?? "")
        docRefEventRequest.getDocument { (document, error) in
            if let document = document, document.exists {
             
                 chatNotificationPending = document.get("chatNotificationPending") as? Bool ?? false
                 chatNotificationDateChosen = document.get("chatNotificationDateChosen") as? Bool ?? false
                
                completion()
                
            }
        }
   
    }
    
    func updatePendingNotificationStatus(){
        
       chatNotificationPending = false
        
     let docRef = dbStore.collection("userNotification").document(user!)
        
      docRef.setData(["chatNotificationPending" : false], merge: true)
        
    }
    
    func updateDateChosenNotificationStatus(){
        
        chatNotificationDateChosen = false
        
     let docRef = dbStore.collection("userNotification").document(user!)
        
      docRef.setData(["chatNotificationDateChosen" : false], merge: true)
        
    }
    
    
    func sendUserAvailability(eventID: String){
        
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).whereField("uid", isEqualTo: user!).getDocuments() { (querySnapshot, err) in
            
            print("querySnapshot: \(String(describing: querySnapshot))")
            print("is querySnapshot empty \(String(describing: querySnapshot?.isEmpty))")
            
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                
                for document in querySnapshot!.documents{
                    
                let documentID = document.documentID
                

                    self.getEventInformation3(eventID: eventID, userEventStoreID: documentID) { (userEventStoreID, eventSecondsFromGMT, startDates, endDates) in
                                
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
    
    
    //    MARK: section get any events the user has already been invited to, moved them from temporary and adds them to permanant, it then deletes the temporary entries
    
    func checkForPhoneNumberInvited(phoneNumber: String, completion: @escaping () -> Void){
        
        print("running func checkForPhoneNumberInvited, inputs: phoneNumber: \(phoneNumber)")
        dbStore.collection("temporaryUserEventStore").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
                    
                    let eventID = document.get("eventID") as! String
                    let uid = Auth.auth().currentUser?.uid
                    
                    //                    add the required info to the userEventStore
                    
                    dbStore.collection("userEventStore").addDocument(data: ["eventID": eventID, "uid": uid!, "userName": registeredName])
                    
                    //                    adds the uid to the eventRequests
                    
                    let docRef = dbStore.collection("eventRequests").document(eventID)
                    
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            
                            dbStore.collection("eventRequests").document(eventID).updateData(["users" : FieldValue.arrayUnion([uid!])])
                            
                        } else {
                            print("Document does not exist")
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
