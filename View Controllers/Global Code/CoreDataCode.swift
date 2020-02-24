//
//  CoreDataCode.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 30/01/2020.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Firebase
import MBProgressHUD

//variable to hold all events during core data processes
var CDEevents = [CoreDataEvent]()

//variable to hold all user availability events during core data processes
var CDAvailability = [CoreDataAvailability]()

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class CoreDataCode: UIViewController {
   
}

var eventListenerEngaged = Bool()
var availabilityListenerEngaged = Bool()

extension UIViewController{
    
    
// MARK: prepare for results pages
    func prepareForEventDetailsPageCD(segueName: String, isSummaryView: Bool, performSegue: Bool, userAvailability: [AvailabilityStruct], completion: @escaping () -> Void){
        
        print("running func prepareForEventDetailsPageCD inputs - segueName: \(segueName), isSummaryView: \(isSummaryView), performSegue: \(performSegue), userAvailability: \(userAvailability)")
            
//        globally selected current event
        let userSelectedEvent = currentUserSelectedEvent
        
            summaryView = isSummaryView
        
//       get the non users availability array
        let nonUserArray = self.noResultArrayCompletion2(numberOfDatesInArray: userSelectedEvent.startDateArray.count + 1).nonUserArray
        
            
//        set whether the user can edit the event
        if userSelectedEvent.eventOwnerID == user!{
            selectEventToggle = 1
            }
            else{
                selectEventToggle = 0
            }
            
            
//        1. create the results summary array
        var resultsInputArray = [[Any]]()
//        1.1 create a date array
        var workingArray = userSelectedEvent.startDatesDisplay
        workingArray.insert("", at: 0)
        resultsInputArray.append(workingArray)
//        1.2 add the current users availability to the results array
        let userAvailabilityArray = createArrayForResults(availabilityArray: userAvailability)
//        each item in the userAvailability array must be added individually
        for i in userAvailabilityArray{
          resultsInputArray.append(i)
        }
//        1.3 add the array for non user
        let nonUserAvailabilityArray = createArrayForResultsNonUser(nonUserNames: userSelectedEvent.nonUserNames, nonUserAvailability: nonUserArray)
        for i in nonUserAvailabilityArray{
          resultsInputArray.append(i)
        }
//        1.4 get the result summary
//         used for displaying the fraction of invitees available
        let resultsSummaryCount = resultsSummary(resultsArray: resultsInputArray).countedResults
//        used for calculating which section of the collectionView the event should be addded to
        let resultsSummaryFraction = resultsSummary(resultsArray: resultsInputArray).fractionResults
                
        resultsInputArray.insert(resultsSummaryCount[0], at: 1)
        arrayForEventResultsPageFinal = resultsInputArray
        print("resultsInputArray \(resultsInputArray)")

                    if performSegue{
                        NotificationCenter.default.post(name: .availabilityUpdated, object: nil)
                       self.performSegue(withIdentifier: segueName, sender: self)
                        completion()
                    }
                    else{
                        NotificationCenter.default.post(name: .availabilityUpdated, object: nil)
                        completion()

                    }
}


    
    
//    MARK: function to prepare core data when the app opens
    
//    first function we call when the app opens, this itterates through all other functions
    func CDAppHasLoaded(completion: @escaping () -> Void){
//        fetch the core data currently saved, returns true if we didn't recieve an error
        if CDFetchEventDataFromDB() == true{
            print("we contacted CoreData")
         
            if CDEevents.count == 0{
                print("there were no events in CoreData")
//            if there were no event returned from CoreData then we must pull down all events
                CDRetrieveAllEventsFB(){
//                we collect the availability for these events throught the competion block
                    self.removeTheEventNotifications()
                completion()
                }
            }
            else{
                print("there were events in CoreData")
//             if events were returned, we only want to retrieve the events for which we have a notification
                CDRetrieveUpdatedEventCheck{(eventIDs) in
                    
                    self.CDRetrieveUpdatedEvents(eventIDs: eventIDs)
                    completion()
                    }}}
        else{
            print("there was an issue contacting core data")
            completion()
        }
    }
    
    
//    first function we call when the app opens, this itterates through all other functions
        func CDAppHasLoadedAvailability(){
//        fetch the core data saved for availability
            
            
            var eventIDs = [String]()
            var eventNumberOfDates = [Int]()
//            get array of all eventIDs and number of dates
            for i in CDEevents{
                eventIDs.append(i.eventID!)
                eventNumberOfDates.append(i.startDates!.count)
            }
        
        if CDFetchAvailabilityDataFromDB() == true{
         print("we contacted CoreDataAvailability")
            
            if CDAvailability.count == 0{
            print("there was no availability in CoreData")
//            if there were no event returned from CoreData then we must pull down all events
                CDRetrieveAllAvailabilityFB(eventIDs: eventIDs, eventNumberOfDates: eventNumberOfDates){
                    
                    self.nonRespondedEvents()
                    
                }
                        }
                        else{
                            print("there were events in CoreData")
//             if availability was returned, we only want to retrieve the events for which we have a notification
                CDRetrieveUpdatedAvailabilityCheck{(availabilityIDs) in
                                
                    self.CDRetrieveUpdatedAvailability(availabilityID: availabilityIDs)
            }}
        }
        else{
            
          print("there was an issue contacting CoreDataAvailability")
        }
    }
    
    

//    check for events with updated flags in the userEventsUpdate table
    func CDRetrieveUpdatedEventCheck(completion: @escaping (_ eventIDString: [String:Any]) -> Void){
        
        print("running func CDRetrieveUpdatedEventCheck")
        
        var eventIDString = [String: Any]()
        
//        we unwrap user, hence we must confirm it is has a value
        if user == nil{
        }
        else{
        dbStore.collection("userEventUpdates").document(user!).getDocument{ (querySnapshot, error) in
                if error != nil {
                    print("Error getting documents: \(error!)")
                    completion(eventIDString)
                }
                else {
                    if querySnapshot!.exists == false{
                      
        //                the user doesn't have any  event data to retrieve
                        print("user has no new event notifications")
                        completion(eventIDString)}
                    else{
                        print("user has new event notifications")
                        
                        let documentData: [String: Any]  = (querySnapshot?.data())!
                        
                        eventIDString = documentData
                        
                        print("CDRetrieveUpdatedEventCheck documentData \(documentData)")
                        completion(eventIDString)
                    }}}}}
    
        
//    check for availability with updated flags in the userEventsUpdate table
        func CDRetrieveUpdatedAvailabilityCheck(completion: @escaping (_ availabilityID: [String:Any]) -> Void){
            
            print("running func CDRetrieveUpdatedAvailabilityCheck")
            
            var availabilityID = [String: Any]()
            
            //        we unwrap user, hence we must confirm it is has a value
            if user == nil{
                
            }
            else{
            
            dbStore.collection("userAvailabilityUpdates").document(user!).getDocument{ (querySnapshot, error) in
                    if error != nil {
                        print("Error getting documents: \(error!)")
                        completion(availabilityID)
                    }
                    else {
                        
                        if querySnapshot!.exists == false{
                          
            //                the user doesn't have any  event data to retrieve
                            print("user has no new event notifications")
                            completion(availabilityID)}
                        else{
                            print("user has new event notifications")
                            
                            let documentData: [String: Any]  = (querySnapshot?.data())!
                            
                            availabilityID = documentData
                            
                            print("documentData \(documentData)")
                            completion(availabilityID)
                        }}}}}
    
    
//    adds, deletes and amends events based on the userEventNotifications table in FireStore
    func CDRetrieveUpdatedEvents(eventIDs: [String: Any]){
     
        print("running func CDRetrieveUpdatedEvents inputs - eventIDs: \(eventIDs)")
        
//        loop thorugh the eventIDs and determine the action for each notification
        for i in eventIDs{
            let notification = i.value as! String
            
            if notification == "delete" || notification == "Delete"{
                print("CDRetrieveUpdatedEvents - deleting event \(i.key)")
//                event has been deleted, we remove it from our array of events
                if let index = CDEevents.index(where: {$0.eventID == i.key}){
                    context.delete(CDEevents[index])
                    CDEevents.remove(at: index)
                    print("index: \(index)")
                    self.CDSaveData()
//                    remove the event notification from the event notification table
                    self.removeSignleEventNotifications(eventID: i.key)
                }
            }
            else if notification == "amend" || notification == "Amend"{
                print("CDRetrieveUpdatedEvents - amending event \(i.key)")
//                event has been updated, delete the event from our array of events and repalce it
                if let index = CDEevents.index(where: {$0.eventID == i.key}){
                    context.delete(CDEevents[index])
                    CDEevents.remove(at: index)
                    print("index: \(index)")
                    self.CDSaveData()
                }
                CDRetrieveSinglEventsFB(eventID: i.key){(numberOfDates) in
//                    remove the event notification from the event notification table
                    self.nonRespondedEvents()
                    self.removeSignleEventNotifications(eventID: i.key)
                }
            }
            else if notification == "new" || notification == "New"{
                print("CDRetrieveUpdatedEvents - new event \(i.key)")
                if let index = CDEevents.index(where: {$0.eventID == i.key}){
                    context.delete(CDEevents[index])
                    CDEevents.remove(at: index)
                    print("index: \(index)")
                    self.CDSaveData()
                }
                CDRetrieveSinglEventsFB(eventID: i.key){ (numberOfDates) in
//                if the event is new, we also need to retrieve any availabilty data
                    self.CDRetrieveAllAvailabilityFB(eventIDs: [i.key], eventNumberOfDates: numberOfDates){
//                        add the users availability to the user eventStore
                        self.uploadCurrentUsersAvailability(eventID: i.key)
//                    remove the event notification from the event notification table
                        self.removeSignleEventNotifications(eventID: i.key)
                    }
                }
            }
            else if notification == "DateChosen" || notification == "dateChosen"{
             print("CDRetrieveUpdatedEvents - dateChosen event \(i.key)")
                if let index = CDEevents.index(where: {$0.eventID == i.key}){
                    context.delete(CDEevents[index])
                    CDEevents.remove(at: index)
                    print("index: \(index)")
                    self.CDSaveData()
                }
                CDRetrieveSinglEventsFB(eventID: i.key){(numberOfDates) in
                //                    remove the event notification from the event notification table
                                    self.removeSignleEventNotifications(eventID: i.key)
//                    notify the user there has been an date chosen and present them the notification
                    self.dateChosenNotification(eventID: i.key)
                    
                    
                    
                }
    
            }
            
        }
    }
    
    
    
//    adds, deletes and amends availability based on the userAvailabilityNotifications table in FireStore
        func CDRetrieveUpdatedAvailability(availabilityID: [String: Any]){
         
            print("running func CDRetrieveUpdatedAvailability inputs - availabilityID: \(availabilityID)")
            
    //        loop thorugh the availabilityID and determine the action for each notification
            for i in availabilityID{
                let notification = i.value as! String
                
                if notification == "delete" || notification == "Delete"{
                    print("CDRetrieveUpdatedAvailability - deleting availability \(i.key)")
    //                event has been deleted, we remove it from our array of events
                    if let index = CDAvailability.index(where: {$0.documentID == i.key}){
                        context.delete(CDAvailability[index])
                        CDAvailability.remove(at: index)
                        print("index: \(index)")
                        self.CDSaveData()
//                        remove the notificaiton from the notification table
                        removeSingleAvailabilityNotifications(documentID: i.key)
                    }
                }
                else if notification == "amend" || notification == "Amend"{
                    print("CDRetrieveUpdatedAvailability - amending availability \(i.key)")
    //                event has been updated, delete the event from our array of events and repalce it
                    if let index = CDAvailability.index(where: {$0.documentID == i.key}){
                        context.delete(CDAvailability[index])
                        CDAvailability.remove(at: index)
                        print("index: \(index)")
                        self.CDSaveData()
                    }
                    CDRetrieveSingleAvailabilityFB(availabilityID: i.key){
//                        remove the specific notificaiton for that availability
                        self.nonRespondedEvents()
                        self.removeSingleAvailabilityNotifications(documentID: i.key)
                    }
                }
                else if notification == "new" || notification == "New"{
                    print("CDRetrieveUpdatedAvailability - new availability \(i.key)")
                    if let index = CDAvailability.index(where: {$0.documentID == i.key}){
                        context.delete(CDAvailability[index])
                        CDAvailability.remove(at: index)
                        print("index: \(index)")
                        self.CDSaveData()
                    }
                    CDRetrieveSingleAvailabilityFB(availabilityID: i.key){
//                        remove the specific notificaiton for that availability
                        self.removeSingleAvailabilityNotifications(documentID: i.key)
                    }
                }}
        }
    
    
    //    function to retrieve single event from Firebase
    func CDRetrieveSinglEventsFB(eventID: String, completion: @escaping (_ numberOfDates: [Int]) -> Void){

            print("running func CDRetrieveSinglEventsFB input - eventID: \(eventID)")
        dbStore.collection("eventRequests").document(eventID).getDocument{ (documentEventData, error) in
                if error != nil {
                    print("Error getting documents: \(error!)")
                }
                else {
                    if documentEventData!.exists == false{
                      
        //                the user doesn't have any  event data to retrieve
                        print("the event is no longer available")
                    }
                    else{
                        
                        if let index = CDEevents.index(where: {$0.eventID == documentEventData!.documentID}){
                            context.delete(CDEevents[index])
                            CDEevents.remove(at: index)
                            print("index: \(index)")
                            self.CDSaveData()
                        }
                         
                         let CDNewEvent = CoreDataEvent(context: context)
                         
                        CDNewEvent.chosenDate = documentEventData!.get("chosenDate") as? String ?? ""
                         CDNewEvent.chosenDateDay = Int64(documentEventData!.get("chosenDateDay") as? Int ?? 999)
                         CDNewEvent.chosenDateMonth = Int64(documentEventData!.get("chosenDateMonth") as? Int ?? 999)
                         CDNewEvent.chosenDatePosition = Int64(documentEventData!.get("chosenDatePosition") as? Int ?? 999)
                         CDNewEvent.chosenDateYear = Int64(documentEventData!.get("chosenDateYear") as? Int ?? 999)
                         CDNewEvent.daysOfTheWeek = documentEventData!.get("daysOfTheWeek") as? [Int]
                         CDNewEvent.endDateInput = documentEventData!.get("endDateInput") as? String
                         CDNewEvent.endDates = documentEventData!.get("endDates") as? [String]
                         CDNewEvent.endTimeInput = documentEventData!.get("endTimeInput") as? String
                         CDNewEvent.eventDescription = documentEventData!.get("eventDescription") as? String ?? ""
                         CDNewEvent.eventID = documentEventData!.documentID
                         CDNewEvent.eventOwner = documentEventData!.get("eventOwner") as? String ?? ""
                         CDNewEvent.eventOwnerName = documentEventData!.get("eventOwnerName") as? String ?? ""
                         CDNewEvent.isAllDay = documentEventData!.get("isAllDay") as? String ?? ""
                         CDNewEvent.location = documentEventData!.get("location") as? String ?? ""
                         CDNewEvent.locationLatitue = documentEventData!.get("locationLatitude") as? Double ?? 0.0
                         CDNewEvent.locationLongitude = documentEventData!.get("locationLongitude") as? Double ?? 0.0
                         CDNewEvent.secondsFromGMT = Int64(documentEventData!.get("secondsFromGMT") as? Int ?? 999)
                         CDNewEvent.startDates = documentEventData!.get("startDates") as? [String]
                         CDNewEvent.startDateInput = documentEventData!.get("startDateInput") as? String
                         CDNewEvent.startTimeInput = documentEventData!.get("startTimeInput") as? String
                        CDNewEvent.currentUserNames = documentEventData!.get("currentUserNames") as? [String]
                        CDNewEvent.nonUserNames = documentEventData!.get("nonUserNames") as? [String]
                        CDNewEvent.users = documentEventData!.get("users") as? [String]
                        CDNewEvent.startDatesDisplay = self.dateArrayToDisplayDates(dates: documentEventData!.get("startDates") as! [String])
 //                        append the new event onto CDNewEvent
                         CDEevents.append(CDNewEvent)
                        self.CDSaveData()
                        completion([CDNewEvent.startDates!.count])
                    }
//                    print("CDEevents \(CDEevents)")
                    
            }
        }}
    
    
//    comit a sinlge event into the Database
    
    func commitSingleEventDB(chosenDate: String, chosenDateDay: Int, chosenDateMonth: Int, chosenDatePosition: Int, chosenDateYear: Int, daysOfTheWeek: [Int], endDates: [String], endTimeInput: String, endDateInput: String, eventDescription: String, eventID: String, eventOwner: String, eventOwnerName: String, isAllDay: String, location: String, locationLatitue: Double, locationLongitude: Double, startDates: [String], startDateInput: String, startTimeInput: String, currentUserNames: [String], nonUserNames: [String], users: [String]){
        
        print("running func commitSingleEventDB")
        
        let CDNewEvent = CoreDataEvent(context: context)
                                
        CDNewEvent.chosenDate = chosenDate
        CDNewEvent.chosenDateDay = Int64(chosenDateDay)
        CDNewEvent.chosenDateMonth = Int64(chosenDateMonth)
        CDNewEvent.chosenDatePosition = Int64(chosenDatePosition)
        CDNewEvent.chosenDateYear = Int64(chosenDateYear)
        CDNewEvent.daysOfTheWeek = daysOfTheWeek
        CDNewEvent.endDateInput = endDateInput
        CDNewEvent.endDates = endDates
        CDNewEvent.endTimeInput = endTimeInput
        CDNewEvent.eventDescription = eventDescription
        CDNewEvent.eventID = eventID
        CDNewEvent.eventOwner = eventOwner
        CDNewEvent.eventOwnerName = eventOwnerName
        CDNewEvent.isAllDay = isAllDay
        CDNewEvent.location = location
        CDNewEvent.locationLatitue = locationLatitue
        CDNewEvent.locationLongitude = locationLongitude
        CDNewEvent.secondsFromGMT = Int64(secondsFromGMT)
        CDNewEvent.startDates = startDates
        CDNewEvent.startDateInput = startDateInput
        CDNewEvent.startTimeInput = startTimeInput
        CDNewEvent.currentUserNames = currentUserNames
        CDNewEvent.nonUserNames = nonUserNames
        CDNewEvent.users = users
        CDNewEvent.startDatesDisplay = self.dateArrayToDisplayDates(dates: startDates)
        //                        append the new event onto CDNewEvent
        CDEevents.append(CDNewEvent)
        self.CDSaveData()
    }
    
    
//    function to retrieve all the events from Firebase the user has been invited to, this should only be used if the coredata is currently empty
    func CDRetrieveAllEventsFB(completion: @escaping () -> Void){
        
        print("running func CDRetrieveAllEvents")
        
        //        we unwrap user, hence we must confirm it is has a value
        if user == nil{
            
        }
        else{
        
       dbStore.collection("eventRequests").whereField("users", arrayContains: user!).getDocuments { (querySnapshot, error) in
               if error != nil {
                   print("Error getting documents: \(error!)")
               }
               else {
                   
                   if querySnapshot!.isEmpty == true{
                     
       //                the user doesn't have any  event data to retrieve
                       print("no event data to retrieve")
                       
                   }
                   else{
                    
                    for documentEventData in querySnapshot!.documents{
                        let CDNewEvent = CoreDataEvent(context: context)
                        
                        CDNewEvent.chosenDate = documentEventData.get("chosenDate") as? String ?? ""
                        CDNewEvent.chosenDateDay = Int64(documentEventData.get("chosenDateDay") as? Int ?? 999)
                        CDNewEvent.chosenDateMonth = Int64(documentEventData.get("chosenDateMonth") as? Int ?? 999)
                        CDNewEvent.chosenDatePosition = Int64(documentEventData.get("chosenDatePosition") as? Int ?? 999)
                        CDNewEvent.chosenDateYear = Int64(documentEventData.get("chosenDateYear") as? Int ?? 999)
                        CDNewEvent.daysOfTheWeek = documentEventData.get("daysOfTheWeek") as? [Int]
                        CDNewEvent.endDateInput = documentEventData.get("endDateInput") as? String
                        CDNewEvent.endDates = documentEventData.get("endDates") as? [String]
                        CDNewEvent.endTimeInput = documentEventData.get("endTimeInput") as? String
                        CDNewEvent.eventDescription = documentEventData.get("eventDescription") as? String ?? ""
                        CDNewEvent.eventID = documentEventData.documentID
                        CDNewEvent.eventOwner = documentEventData.get("eventOwner") as? String ?? ""
                        CDNewEvent.eventOwnerName = documentEventData.get("eventOwnerName") as? String ?? ""
                        CDNewEvent.isAllDay = documentEventData.get("isAllDay") as? String ?? ""
                        CDNewEvent.location = documentEventData.get("location") as? String ?? ""
                        CDNewEvent.locationLatitue = documentEventData.get("locationLatitude") as? Double ?? 0.0
                        CDNewEvent.locationLongitude = documentEventData.get("locationLongitude") as? Double ?? 0.0
                        CDNewEvent.secondsFromGMT = Int64(documentEventData.get("secondsFromGMT") as? Int ?? 999)
                        CDNewEvent.startDates = documentEventData.get("startDates") as? [String]
                        CDNewEvent.startDateInput = documentEventData.get("startDateInput") as? String
                        CDNewEvent.startTimeInput = documentEventData.get("startTimeInput") as? String
                        CDNewEvent.currentUserNames = documentEventData.get("currentUserNames") as? [String]
                        CDNewEvent.nonUserNames = documentEventData.get("nonUserNames") as? [String]
                        CDNewEvent.users = documentEventData.get("users") as? [String]
                        CDNewEvent.startDatesDisplay = self.dateArrayToDisplayDates(dates: documentEventData.get("startDates") as! [String])
                        
//                        append the new event onto CDNewEvent
                        CDEevents.append(CDNewEvent)

                    }
                    
//                    print("CDEevents \(CDEevents)")
                    self.CDSaveData()
                    completion()
                }
        }}}}
    
    
    
//    function to retrieve all the availability from Firebase, this should only be used if the coredata is currently empty
    func CDRetrieveAllAvailabilityFB(eventIDs: [String], eventNumberOfDates: [Int], completion: @escaping () -> Void ){
            print("running func CDRetrieveAllAvailabilityFB inputs - eventIDs: \(eventIDs) eventNumberOfDates: \(eventNumberOfDates)")
        
        if eventIDs.count == 0{
            
        }
        else{
        
        for n in 0...eventIDs.count - 1{
            
            let currentEventID = eventIDs[n]
            let currentAvailabilty = eventNumberOfDates[n]
            
//            generate not responded array
            let notRespondedArray = noResultArrayCompletion2(numberOfDatesInArray: currentAvailabilty).noResultsArray
            
           dbStore.collection("userEventStore").whereField("eventID", isEqualTo: currentEventID).getDocuments { (querySnapshot, error) in
                   if error != nil {
                       print("Error getting documents: \(error!)")
                    completion()
                   }
                   else {
                       
                       if querySnapshot!.isEmpty == true{
           //                the user doesn't have any  event data to retrieve
                           print("no event data to retrieve")
                        completion()
                       }
                       else{
                        
                        for documentEventData in querySnapshot!.documents{
                            
//                            before we commit anything to the DB we should check if it alredy exists and remove it if it does
                            if let index = CDAvailability.index(where: {$0.documentID == documentEventData.documentID}){
                                                    context.delete(CDAvailability[index])
                                                    CDAvailability.remove(at: index)
                                                    print("index: \(index)")
                                self.CDSaveData()
                            }
                            
                            let CDNewAvailability = CoreDataAvailability(context: context)
                            
                            CDNewAvailability.documentID = documentEventData.documentID
                            CDNewAvailability.eventID = documentEventData.get("eventID") as? String
                            CDNewAvailability.uid = documentEventData.get("uid") as? String
                            CDNewAvailability.userName = documentEventData.get("userName") as? String
                            CDNewAvailability.userAvailability = documentEventData.get("userAvailability") as? [Int] ?? notRespondedArray

    //                        append the new event onto CDAvailability
                            CDAvailability.append(CDNewAvailability)
//                            print("CDNewAvailability \(CDNewAvailability)")
                            self.CDSaveData()
                        }
                        completion()
                    }}}}
        }}
    
//    commit a single Availability into CoreData
    func commitSinlgeAvailabilityToCD(documentID: String, eventID: String, uid: String, userName: String, userAvailability: [Int]){
        
        print("running func commitSinlgeAvailabilityToCD wiht inputs - documentID: \(documentID) eventID: \(eventID), uid: \(uid), userName: \(userName), userAvailability \(userAvailability)")
        
       let CDNewAvailability = CoreDataAvailability(context: context)
        
        //                            before we commit anything to the DB we should check if it alredy exists and remove it if it does
        if let index = CDAvailability.index(where: {$0.documentID == documentID}){
                                context.delete(CDAvailability[index])
                                CDAvailability.remove(at: index)
                                print("index: \(index)")
            self.CDSaveData()
        }

                                   
        CDNewAvailability.documentID = documentID
        CDNewAvailability.eventID = eventID
        CDNewAvailability.uid = uid
        CDNewAvailability.userName = userName
        CDNewAvailability.userAvailability = userAvailability

//                        append the new event onto CDAvailability
        CDAvailability.append(CDNewAvailability)
//                            print("CDNewAvailability \(CDNewAvailability)")
        self.CDSaveData()
        
    }
    
    
//    function to update the availability of the user in CoreData once they manually update thier availability
    
    func updateUsersAvailability(documentID: String, eventID: String, uid: String, userAvailability: [Int]){
        
        let fetchRequest : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "documentID == %@", documentID)
        
        var CDNewAvailability = CoreDataAvailability(context: context)
        
        CDNewAvailability = CDFetchFilteredAvailabilityDataFromDB(with: fetchRequest)[0]
        CDNewAvailability.userAvailability = userAvailability
        self.CDSaveData()
    }
    
    
    
  //    function to retrieve all the availability from Firebase, this should only be used if the coredata is currently empty
    func CDRetrieveSingleAvailabilityFB(availabilityID: String, completion: @escaping () -> Void ){
            
            print("running func CDRetrieveSingleAvailabilityFB inputs - availabilityID: \(availabilityID)")
            
        dbStore.collection("userEventStore").document(availabilityID).getDocument{ (querySnapshot, error) in
                   if error != nil {
                       print("Error getting documents: \(error!)")
                   }
                   else {
                       
                    if querySnapshot!.exists == false{
                         
           //                the user doesn't have any  event data to retrieve
                           print("no availability data to retrieve")}
                       else{
                        
                        //                            before we commit anything to the DB we should check if it alredy exists and remove it if it does
                        if let index = CDAvailability.index(where: {$0.documentID == querySnapshot!.documentID}){
                                                context.delete(CDAvailability[index])
                                                CDAvailability.remove(at: index)
                                                print("index: \(index)")
                            self.CDSaveData()
                        }
                        
                            let CDNewAvailability = CoreDataAvailability(context: context)
                            
                            CDNewAvailability.documentID = querySnapshot!.documentID
                            CDNewAvailability.uid = querySnapshot!.get("uid") as? String
                            CDNewAvailability.eventID = querySnapshot!.get("eventID") as? String
                            CDNewAvailability.userName = querySnapshot!.get("userName") as? String
                            CDNewAvailability.userAvailability = querySnapshot!.get("userAvailability") as? [Int] ?? [99]
                            CDNewAvailability.calendarEventID = querySnapshot!.get("calendarEventID") as? String ?? ""
    //                        append the new event onto CDAvailability
                            CDAvailability.append(CDNewAvailability)
                        self.CDSaveData()
                        completion()
                        
                        }}}
            
        }
    
    
    
//    function to fetch event from core data
    func CDFetchEventDataFromDB() -> Bool{
        let request : NSFetchRequest<CoreDataEvent> = CoreDataEvent.fetchRequest()
        
        do{
        CDEevents = try context.fetch(request)
            print("CDFetchEventData - event count: \(CDEevents.count)")
//            print("CDEevents: \(CDEevents)")
            
            return true
            
        } catch{
            print("error fetching the data from core data \(error)")
            
            return false
        }
    }
    
    
//    function to fetch user availability from core data
    func CDFetchAvailabilityDataFromDB() -> Bool{
            let request : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
            
            do{
            CDAvailability = try context.fetch(request)
                print("CDFetchAvailabilityDataFromDB - CDAvailability count: \(CDAvailability.count)")
    //            print("CDEevents: \(CDEevents)")
                
                return true
                
            } catch{
                print("error fetching the data from core data \(error)")
                
                return false
            }
        }
    
    
//    function save down the core data
    func CDSaveData(){
        print("running func CDSaveData")
        
        do{
        try context.save()
        }
        catch{
            print("error saving data to core data with error \(error)")
        }
        
    }
    
    
func removeTheEventNotifications(){
        
        print("running func - removeTheEventNotifications")
        
        dbStore.collection("userEventUpdates").document(user!).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    

// function to remove a single event from the notification tbale
    func removeSignleEventNotifications(eventID: String){
        
        print("running func - removeTheEventNotifications")
        
        dbStore.collection("userEventUpdates").document(user!).updateData([eventID : FieldValue.delete()]) { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    
// delete all the availability notifications for that user
func removeTheAvailabilityNotifications(){
        
        print("running func - removeTheAvailabilityNotifications")
        
        dbStore.collection("userAvailabilityUpdates").document(user!).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    
    func removeSingleAvailabilityNotifications(documentID: String){
        
        print("running func - removeSingleAvailabilityNotifications")
        
        dbStore.collection("userAvailabilityUpdates").document(user!).updateData([documentID : FieldValue.delete()]) { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    
    
//    function for retrieveing events from DB with any request
    func CDFetchFilteredEventDataFromDB(with request: NSFetchRequest<CoreDataEvent> = CoreDataEvent.fetchRequest()) -> [CoreDataEvent]{
        
        var filteredEventResults = [CoreDataEvent]()
        
        do{
            filteredEventResults = try context.fetch(request)
                print("filteredEventResults - event count: \(filteredEventResults.count)")
                
                return filteredEventResults
                
            } catch{
                print("error fetching the data from core data \(error)")
                
                return filteredEventResults
            }
        }
    
    
//    function for retrieveing availability from DB with any request
    func CDFetchFilteredAvailabilityDataFromDB(with request: NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()) -> [CoreDataAvailability]{
        
        var filteredAvailabilityResults = [CoreDataAvailability]()
        
        do{
            filteredAvailabilityResults = try context.fetch(request)
                print("filteredAvailabilityResults - availability count: \(filteredAvailabilityResults.count)")
                
                return filteredAvailabilityResults
                
            } catch{
                print("error fetching the data from core data \(error)")
                
                return filteredAvailabilityResults
            }
        }
    
    
//    MARK: serialising and filteting data
    
//    func to serialise data from CDStore to eventSearch class for any or specific events
    func serialiseEvents(predicate: NSPredicate, usePredicate: Bool) -> [eventSearch]{
        print("runing func serialiseEvents inputs - usePredicate: \(usePredicate)")
        
        let dateFormatterSimple = DateFormatter()
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterSimple.locale = Locale(identifier: "en_US_POSIX")
        let request : NSFetchRequest<CoreDataEvent> = CoreDataEvent.fetchRequest()
        
        var serialisedEvents = [eventSearch]()
       
//        if usePredicate set then use the passed in predicate
        if usePredicate == true{
            request.predicate = predicate
        }
        
        
      let retrievedResults = CDFetchFilteredEventDataFromDB(with: request)
    
        for CDNewEvent in retrievedResults{
            
            var n = eventSearch()
            
            n.chosenDate = CDNewEvent.chosenDate ?? ""
            n.chosenDateDay = Int(CDNewEvent.chosenDateDay)
            n.chosenDateMonth = Int(CDNewEvent.chosenDateMonth)
            n.chosenDatePosition = Int(CDNewEvent.chosenDatePosition)
            n.chosenDateYear = Int(CDNewEvent.chosenDateYear)
            n.daysOfTheWeekArray = CDNewEvent.daysOfTheWeek!
            n.eventEndDate = CDNewEvent.endDateInput!
            n.endDateArray = CDNewEvent.endDates!
            n.eventEndTime = CDNewEvent.endTimeInput!
            n.eventDescription = CDNewEvent.eventDescription!
            n.eventID = CDNewEvent.eventID!
            n.eventOwnerID = CDNewEvent.eventOwner!
            n.isAllDay = CDNewEvent.isAllDay!
            n.eventLocation = CDNewEvent.location!
            n.locationLatitue = CDNewEvent.locationLatitue
            n.locationLongitude = CDNewEvent.locationLongitude
            n.secondsFromGMT = Int(CDNewEvent.secondsFromGMT)
            n.startDateArray = CDNewEvent.startDates!
            n.eventStartDate = CDNewEvent.startDateInput!
            n.eventStartTime = CDNewEvent.startTimeInput!
            n.currentUserNames = CDNewEvent.currentUserNames ?? [""]
            n.nonUserNames = CDNewEvent.nonUserNames ?? [""]
            n.startDatesDisplay = CDNewEvent.startDatesDisplay!
            n.users = CDNewEvent.users ?? [""]
            
//            adding the final date in the search array
            let finalSearchDate = dateFormatterSimple.date(from: CDNewEvent.endDateInput!)
            n.finalSearchDate = finalSearchDate!.addingTimeInterval(TimeInterval(secondsFromGMT))
            
//            changing the event owner name to be you for those events the user is hosting
            
            if CDNewEvent.eventOwnerName! == user!{
                n.eventOwnerName = "You"
            }
            else{
               n.eventOwnerName = CDNewEvent.eventOwnerName!
            }
            
            serialisedEvents.append(n)
        }
//        print("serialisedEvents: \(serialisedEvents)")
        return serialisedEvents
    }
    
    
//    fetch availability for a specific event and serialise the data
    func serialiseAvailability(eventID: String) -> [AvailabilityStruct]{
     print("running func serialiseAvailability inputs - eventID \(eventID)")
        var filteredAvailability = [CoreDataAvailability]()
        var serialisedAvailability = [AvailabilityStruct]()
    
        let request : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@", eventID)
        filteredAvailability = CDFetchFilteredAvailabilityDataFromDB(with: request)
        
        for i in filteredAvailability{
            var nextAvailability = AvailabilityStruct()
            nextAvailability.documentID = i.documentID ?? ""
            nextAvailability.eventID = i.eventID ?? ""
            nextAvailability.uid = i.uid ?? ""
            nextAvailability.userAvailability = i.userAvailability ?? [99]
            nextAvailability.userName = i.userName ?? ""
            nextAvailability.calendarEventID = i.calendarEventID ?? ""
            print("nextAvailability \(nextAvailability)")
            serialisedAvailability.append(nextAvailability)
        }
        return serialisedAvailability
    }
    
//    create availability array for current users of the app
    func createArrayForResults(availabilityArray: [AvailabilityStruct]) -> [[Any]]{
    
        print("running func createArrayForResults inputs - AvailabilityStruct: \(availabilityArray)")
        
    var availabilityArrayOutput = [[Any]]()
    //            generate not responded array
    let notRespondedArray = noResultArrayCompletion2(numberOfDatesInArray: currentUserSelectedEvent.startDateArray.count + 1).noResultsArray
        
     for i in availabilityArray{
        var nextArray = [Any]()
//        catch to ensure we give any empty availability arrays the not responded array, i.userAvailability.count != startDateArray.count to ensure that if one of the users arrays doesnt have the correct number of ints in it, we replace it with the not responded array
        if i.userAvailability == [99] || i.userAvailability == [] || i.userAvailability.count != currentUserSelectedEvent.startDateArray.count{
            nextArray = notRespondedArray
            nextArray.insert(i.userName, at: 0)
            availabilityArrayOutput.append(nextArray)
        }
        else{
            nextArray = i.userAvailability
            nextArray.insert(i.userName, at: 0)
            availabilityArrayOutput.append(nextArray)
        }
        }
       return availabilityArrayOutput
    }
    
    
//    create availability array for current users of the app
    func createArrayForResultsNonUser(nonUserNames: [String], nonUserAvailability: [Int]) -> [[Any]]{
        var availabilityArrayOutput = [[Any]]()
        var nextArray = [Any]()
        
     for i in nonUserNames{
            nextArray = nonUserAvailability
            nextArray.insert(i, at: 0)
            availabilityArrayOutput.append(nextArray)
        }
       return availabilityArrayOutput
    }
    
   
//   filter events for the required in each section of the tableView controller, set createdByUser false when filtering for past events
    func filteringEventsForDisplay(pending: Bool, createdByUser: Bool, pastEvents: Bool, serialisedEvents: [eventSearch]) -> [eventSearch]{
        
        print("running func getEventsFromCD inputs - pending: \(pending) createdByUser \(createdByUser) pastEvents: \(pastEvents)")
        
//        date for comparison to determine whether the event is occuring today.
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        let newDate = date.addingTimeInterval(TimeInterval(secondsFromGMT))
        let dateComponents = DateComponents(year: Calendar.current.component(.year, from: newDate), month: Calendar.current.component(.month, from: newDate), day: Calendar.current.component(.day, from: newDate), hour: 0, minute: 0, second: 0)
        let dateFromComponents = calendar.date(from: dateComponents)!.addingTimeInterval(TimeInterval(secondsFromGMT))
               
        if createdByUser == true && pending == true && pastEvents == false{
            let events = serialisedEvents.filter(){ $0.eventOwnerID == user! && $0.chosenDate == "" && $0.finalSearchDate > dateFromComponents}
                print("events \(events)")
            return events
        }
        else if createdByUser == false && pending == true && pastEvents == false{
                let events = serialisedEvents.filter(){ $0.eventOwnerID != user! && $0.chosenDate == "" && $0.finalSearchDate > dateFromComponents}
            print("events \(events)")
            return events
        }
        else if createdByUser == false && pending == true && pastEvents == true{
                    let events = serialisedEvents.filter(){ $0.eventOwnerID != user! && $0.chosenDate == "" && $0.finalSearchDate < dateFromComponents}
                print("events \(events)")
            return events
            }
        else if createdByUser == true && pending == false && pastEvents == false{
                let events = serialisedEvents.filter(){ $0.eventOwnerID == user! && $0.chosenDate != "" && $0.finalSearchDate > dateFromComponents}
            print("events \(events)")
            return events
        }
        else if createdByUser == false && pending == false && pastEvents == false{
                let events = serialisedEvents.filter(){ $0.eventOwnerID != user! && $0.chosenDate != "" && $0.finalSearchDate > dateFromComponents}
            print("events \(events)")
            return events
        }
        else if createdByUser == false && pending == false && pastEvents == true{
                let events = serialisedEvents.filter(){ $0.eventOwnerID != user! && $0.chosenDate != "" && $0.finalSearchDate < dateFromComponents}
            print("events \(events)")
            return events
        }
        else{
            
            let emptyEvents = [eventSearch]()
            
            return emptyEvents
        }
    }
    
    

     
    
//    MARK: Notification functions, creating notifications within the database
    
//    notification function for newly created events
    func eventCreatedNotification(userIDs: [String], eventID: String){
      print("running func eventCreatedNotification- adding notificaitons to userEventUpdates - inputs - userIDs \(userIDs)")
        
        for i in userIDs{
       
//            add the eventID and an updated notification to the userEventUpdates tbales
            dbStore.collection("userEventUpdates").document(i).setData([eventID: "New"], merge: true)
            
        }
    
    }
    
//    notification function for amended events
        func eventAmendedNotification(userIDs: [String], eventID: String){
          print("running func eventCreatedNotification- adding notificaitons to userEventUpdates - inputs - userIDs \(userIDs)")
            
            for i in userIDs{
           
    //            add the eventID and an updated notification to the userEventUpdates tbales
                dbStore.collection("userEventUpdates").document(i).setData([eventID: "amend"], merge: true)
                
            }
        
        }
    
    
//    notification function for new availability
        func availabilityCreatedNotification(userIDs: [String], availabilityDocumentID: String){
          print("running func availabilityCreatedNotification- adding notificaitons to userAvailabilityUpdates - inputs - userIDs \(userIDs) availabilityString \(availabilityDocumentID)")
            
            for i in userIDs{
    //            add the eventID and an updated notification to the userEventUpdates tbales
                dbStore.collection("userAvailabilityUpdates").document(i).setData([availabilityDocumentID: "New"], merge: true)
            }
        }
    
    
//    notification function for amended availability
        func availabilityAmendedNotification(userIDs: [String], availabilityDocumentID: String){
          print("running func availabilityCreatedNotification- adding notificaitons to userAvailabilityUpdates - inputs - userIDs \(userIDs) availabilityString \(availabilityDocumentID)")
            
            for i in userIDs{
    //            add the eventID and an updated notification to the userEventUpdates tbales
                dbStore.collection("userAvailabilityUpdates").document(i).setData([availabilityDocumentID: "amend"], merge: true)
            }
        }
    
    
//    notification function for new availability
        func availabilityDeletedNotification(userIDs: [String], availabilityDocumentID: String){
          print("running func availabilityDeletedNotification- adding notificaitons to userAvailabilityUpdates - inputs - userIDs \(userIDs) availabilityString \(availabilityDocumentID)")
            
            for i in userIDs{
    //            add the eventID and an updated notification to the userEventUpdates tbales
                dbStore.collection("userAvailabilityUpdates").document(i).setData([availabilityDocumentID: "Delete"], merge: true)
            }
        }
    
    
//    notification function for deleted events
        func eventDeletedNotification(userIDs: [String], eventID: String){
          print("running func eventDeletedNotification- adding notificaitons to userEventUpdates - inputs - userIDs \(userIDs)")
            
            for i in userIDs{
           
    //            add the eventID and an updated notification to the userEventUpdates tbales
                dbStore.collection("userEventUpdates").document(i).setData([eventID: "delete"], merge: true)
                
            }
        
        }
    
//    MARK: snapshot listener section
//    fuction for turning on and off the snapshot listener on the eventNotification table
    func eventChangeListener(){
        
        if eventListenerEngaged == true{
            print("eventChangeListener already engaged, not re-engaging")
            
        }
        else{
            eventListenerEngaged = true
        
        print("engaging eventChangeListener")
            dbStore.collection("userEventUpdates").document(user!).addSnapshotListener(){ querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                let source = snapshot.metadata.hasPendingWrites ? "Local" : "Server"
                if source == "local"{
                    print("This is the local trigger, we don't do anything with this")
                }
                else{
                    if snapshot.data()?.isEmpty == true || snapshot.data() == nil{

                    print("eventChangeListener triggered")
                     print("there was no data in the snapshot event listener")
                    }
                    else{
                    print("eventChangeListener triggered")
                    print("eventChangeListener document changed and there was data to retrieve")
                        let documentData: [String: Any] = (snapshot.data()!)
                 
                        self.CDRetrieveUpdatedEvents(eventIDs: documentData)
                }}}
        }}
    
    
    //    check for availability with updated flags in the userEventsUpdate table
    func availabilityChangeListener(){
        
        if availabilityListenerEngaged == true{
            print("availabilityChangeListener already engaged, not re-engaging")
                   
               }
               else{
                availabilityListenerEngaged = true
        
        print("engaging availabilityChangeListener")

        dbStore.collection("userAvailabilityUpdates").document(user!).addSnapshotListener(){ (querySnapshot, error) in
                if error != nil {
                    print("Error getting documents: \(error!)")
                }
                else {
                    let source = querySnapshot!.metadata.hasPendingWrites ? "Local" : "Server"
                    
                    if source == "local"{
                        print("This is the local trigger, we don't do anything with this")
                    }
                    else{
                    
                    if querySnapshot!.data()?.isEmpty == true || querySnapshot!.data() == nil{
        //                the user doesn't have any  event data to retrieve
                        print("availabilityChangeListener triggered but user has no new availability notifications")}
                    else{
                        
                        let documentData: [String: Any] = (querySnapshot!.data()!)
                        
                        print("availabilityChangeListener triggered - there is data in the document \(documentData.keys) \(documentData.values)")
                        
                        self.CDRetrieveUpdatedAvailability(availabilityID: documentData)
                        
                        }}}}}}
    
    
//    MARK: Misc functions
    
    
    func uploadCurrentUsersAvailability(eventID: String){
        
        print("running func uploadCurrentUsersAvailability inputs - eventID: \(eventID)")
        
        var dateFormatterTZ = DateFormatter()
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        
//        1. retrieve the event data, eventSearch
        let predicate = NSPredicate(format: "eventID = %@", eventID)
        let predicateReturned = serialiseEvents(predicate: predicate, usePredicate: true)
        if predicateReturned.count == 0{
         print("something went wrong")
        }
        else{
            let eventData = predicateReturned[0]
        print("uploadCurrentUsersAvailability documentID: \(eventData)")
        
//        2. retrieve the documentID for the users eventStore ID
        let availabilityData = serialiseAvailability(eventID: eventID)
        let filteredAvailabilityData = availabilityData.filter { $0.uid == user!}
        let documentID = filteredAvailabilityData[0].documentID
        print("uploadCurrentUsersAvailability documentID: \(documentID)")
        
//        3. calcaulte the users availability
        
        let numberOfDates = eventData.endDateArray.count - 1

        let startDateDate = dateFormatterTZ.date(from: eventData.startDateArray[0])
        let endDateDate = dateFormatterTZ.date(from: eventData.endDateArray[numberOfDates])

        let endDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).endDatesOfTheEvents
        let startDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).startDatesOfTheEvents

        let finalAvailabilityArray2 = self.compareTheEventTimmings3(datesBetweenChosenDatesStart: eventData.startDateArray, datesBetweenChosenDatesEnd: eventData.endDateArray, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents)
        print("uploadCurrentUsersAvailability finalAvailabilityArray2: \(finalAvailabilityArray2)")

//                        add the finalAvailabilityArray to the userEventStore

        commitUserAvailbilityData(userEventStoreID: documentID, finalAvailabilityArray2: finalAvailabilityArray2, eventID: eventID)
        }
    }
    
    
//    function to location events we haven't responded to and respond, this should run each time we open the app and maybe when we open the events page
    func nonRespondedEvents(){
//        find events where the availability for our user ID = [99]
        print("running func nonRespondedEvents")
        
        if user! == ""{
            
        }
        else{
        
        let request : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@ && (userAvailability == %@ || userAvailability == %@)", argumentArray:[user!, [99], []])
        let filteredAvailability = CDFetchFilteredAvailabilityDataFromDB(with: request)
        print("nonRespondedEvents filteredAvailability \(filteredAvailability)")
//            filter through each empty availability and respond
            for i in filteredAvailability{
                uploadCurrentUsersAvailability(eventID: i.eventID!)
   
            }
        }
        
    }
    
    
//    show the user the datechosen  notificaton and let them add it to their calendar
    func dateChosenNotification(eventID: String){
        
        print("running func dateChosenNotification - eventID: \(eventID)")
        
//        1. retrieve the event data, eventSearch
        let predicate = NSPredicate(format: "eventID = %@", eventID)
        let predicateReturned = serialiseEvents(predicate: predicate, usePredicate: true)
        let request : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@ && eventID == %@", argumentArray:[user!, eventID])
        let filteredAvailability = CDFetchFilteredAvailabilityDataFromDB(with: request)
        
        
        if predicateReturned.count == 0 || filteredAvailability.count == 0{
            print("dateChosenNotification - we dont have the event data eventCount \(predicateReturned.count) availabilityCount \(filteredAvailability.count) - something went wrong")
        }
        else{
            let eventData = predicateReturned[0]
            let availabilityData = filteredAvailability[0]
            
            let chosenDatePosition = eventData.chosenDatePosition
            let calendarEventIDInput = availabilityData.calendarEventID ?? ""
            
            //                    Adds the event to the users calendar
            self.addEventToCalendar(title: eventData.eventDescription, description: eventData.eventDescription, startDate: eventData.startDateArray[chosenDatePosition], endDate: eventData.endDateArray[chosenDatePosition], location: eventData.eventLocation, eventOwner: eventData.eventOwnerName, startDateDisplay: eventData.startDatesDisplay[chosenDatePosition], eventOwnerID: eventData.eventOwnerID, locationLongitude: eventData.locationLongitude, locationLatitude: eventData.locationLatitue, userEventStoreID: availabilityData.documentID!, calendarEventIDInput: calendarEventIDInput)
        }
        
    }
    
    
//    save an item to the availability CD
    func saveItemAvailabilty(userEventStoreID: String, key: String, value: Any){
        
     let request : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
            request.predicate = NSPredicate(format: "documentID == %@", argumentArray:[userEventStoreID])
        let filteredAvailability = CDFetchFilteredAvailabilityDataFromDB(with: request)
        
        if filteredAvailability.count == 0{
            print("saveItemAvailabilty something went wrong no availability data")
        }
        else{
            var object = filteredAvailability[0]
            object.setValue(value, forKey: key)
            
            do{
            try context.save()
            }
            catch{
                print("error saving data to core data with error \(error)")
            }
            
        }
        
    }
    
//    function to handle any errors with the data for an event
    func somethingWentWrongResetEvent(eventID: String, eventInfo: Bool, availabilityInfo: Bool){
        
//        trigger to set the funtion to delete any current data for the event and then download the new data
        if eventInfo == true{
            
        }
        if availabilityInfo == true{
            
            
            
        }
        
        
    }
    
    }

