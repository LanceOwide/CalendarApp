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

extension UIViewController{
    
    
// MARK: prepare for results pages
    func prepareForEventDetailsPageCD(eventID: String, isEventOwnerID : String, segueName: String, isSummaryView: Bool, performSegue: Bool, completion: @escaping () -> Void){
            
//        globally selected current event
        let userSelectedEvent = currentUserSelectedEvent
        
            summaryView = isSummaryView
            var resultsArray = [eventResults]()
            var currentEventAvailability = [AvailabilityStruct]()
            
//        1. get the current events availability for current users
            currentEventAvailability = serialiseAvailability(eventID: eventID)
//        2. get the non responders availability array
        let noResultsArrayGlobal = self.noResultArrayCompletion2(numberOfDatesInArray: userSelectedEvent.startDateArray.count).noResultsArray
//        3.  get the non users availability array
        let nonUserArray = self.noResultArrayCompletion2(numberOfDatesInArray: userSelectedEvent.startDateArray.count).nonUserArray
            
//        set whether the user can edit the event
        if userSelectedEvent.eventOwnerID == user!{
            selectEventToggle = 1
            }
            else{
                selectEventToggle = 0
            }
            
//        initiate the loading notification whislt the event information is loaded
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Loading"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
            loadingNotification.mode = MBProgressHUDMode.customView
            
//        1. add the dates to the results array with an empty in the first column
            
            
//        add all the required data to display results to the eventResultsStruct
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

    
    
//    MARK: function to prepare core data when the app opens
    
//    first function we call when the app opens, this itterates through all other functions
    func CDAppHasLoaded(completion: @escaping () -> Void){
//        fetch the core data currently saved, returns true if we didn't recieve an error
        if CDFetchEventDataFromDB() == true{
            print("we contacted CoreData")
         
            if CDEevents.count == 0{
                print("there were no events in CoreData")
//            if there were no event returned from CoreData then we must pull down all events
              CDRetrieveAllEventsFB()
            removeTheEventNotifications()
                completion()
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
//            get array of all eventIDs
            
            for i in CDEevents{
                eventIDs.append(i.eventID!)
            }
        
        if CDFetchAvailabilityDataFromDB() == true{
         print("we contacted CoreDataAvailability")
            
            if CDAvailability.count == 0{
            print("there was no availability in CoreData")
//            if there were no event returned from CoreData then we must pull down all events
//                MARK: need to get the eventID array, easy way from the CoreDataEvent array?
                          CDRetrieveAllAvailabilityFB(eventIDs: eventIDs)
                        }
                        else{
                            print("there were events in CoreData")
//             if events were returned, we only want to retrieve the events for which we have a notification
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
                        
                        print("documentData \(documentData)")
                        completion(eventIDString)
                }}}}
    
        
//    MARK: - this should be converted to a snaphot listener to detect any new event notifications and update accordingly
//    check for availability with updated flags in the userEventsUpdate table
        func CDRetrieveUpdatedAvailabilityCheck(completion: @escaping (_ availabilityID: [String:Any]) -> Void){
            
            print("running func CDRetrieveUpdatedAvailabilityCheck")
            
            var availabilityID = [String: Any]()
            
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
                    }}}}
    
    
//    adds, deletes and amends events based on the userEventNotifications table in FireStore
    func CDRetrieveUpdatedEvents(eventIDs: [String: Any]){
     
        print("running func CDRetrieveUpdatedEvents inputs - eventIDs: \(eventIDs)")
        
//        loop thorugh the eventIDs and determine the action for each notification
        for i in eventIDs{
            let notification = i.value as! String
            
            if notification == "delete"{
                print("CDRetrieveUpdatedEvents - deleting event \(i.key)")
//                event has been deleted, we remove it from our array of events
                if let index = CDEevents.index(where: {$0.eventID == i.key}){
                    context.delete(CDEevents[index])
                    CDEevents.remove(at: index)
                    print("index: \(index)")
                    self.CDSaveData()
                }
            }
            else if notification == "amend"{
                print("CDRetrieveUpdatedEvents - amending event \(i.key)")
//                event has been updated, delete the event from our array of events and repalce it
                if let index = CDEevents.index(where: {$0.eventID == i.key}){
                    context.delete(CDEevents[index])
                    CDEevents.remove(at: index)
                    print("index: \(index)")
                    self.CDSaveData()
                }
                CDRetrieveSinglEventsFB(eventID: i.key)
            }
            else if notification == "new"{
                print("CDRetrieveUpdatedEvents - new event \(i.key)")
                if let index = CDEevents.index(where: {$0.eventID == i.key}){
                    context.delete(CDEevents[index])
                    CDEevents.remove(at: index)
                    print("index: \(index)")
                    self.CDSaveData()
                }
                CDRetrieveSinglEventsFB(eventID: i.key)
            }}
//        once all notifications have been looped through, they are deleted from Firebase
        removeTheEventNotifications()
    }
    
    
    
//    adds, deletes and amends availability based on the userAvailabilityNotifications table in FireStore
        func CDRetrieveUpdatedAvailability(availabilityID: [String: Any]){
         
            print("running func CDRetrieveUpdatedAvailability inputs - availabilityID: \(availabilityID)")
            
    //        loop thorugh the availabilityID and determine the action for each notification
            for i in availabilityID{
                let notification = i.value as! String
                
                if notification == "delete"{
                    print("CDRetrieveUpdatedAvailability - deleting availability \(i.key)")
    //                event has been deleted, we remove it from our array of events
                    if let index = CDAvailability.index(where: {$0.eventID == i.key}){
                        context.delete(CDAvailability[index])
                        CDAvailability.remove(at: index)
                        print("index: \(index)")
                        self.CDSaveData()
                    }
                }
                else if notification == "amend"{
                    print("CDRetrieveUpdatedAvailability - amending availability \(i.key)")
    //                event has been updated, delete the event from our array of events and repalce it
                    if let index = CDAvailability.index(where: {$0.eventID == i.key}){
                        context.delete(CDAvailability[index])
                        CDAvailability.remove(at: index)
                        print("index: \(index)")
                        self.CDSaveData()
                    }
                    CDRetrieveSingleAvailabilityFB(availabilityID: i.key)
                }
                else if notification == "new"{
                    print("CDRetrieveUpdatedAvailability - new availability \(i.key)")
                    if let index = CDAvailability.index(where: {$0.eventID == i.key}){
                        context.delete(CDAvailability[index])
                        CDAvailability.remove(at: index)
                        print("index: \(index)")
                        self.CDSaveData()
                    }
                    CDRetrieveSingleAvailabilityFB(availabilityID: i.key)
                }}
    //        once all notifications have been looped through, they are deleted from Firebase
            removeTheAvailabilityNotifications()
        }
    
    
    //    function to retrieve single event from Firebase
    func CDRetrieveSinglEventsFB(eventID: String){
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
                        CDNewEvent.startDatesDisplay = self.dateArrayToDisplayDates(dates: documentEventData!.get("startDates") as! [String])
 //                        append the new event onto CDNewEvent
                         CDEevents.append(CDNewEvent)
                        self.CDSaveData()
                    }
//                    print("CDEevents \(CDEevents)")
                    
            }
        }}
    
    
//    function to retrieve all the events from Firebase the user has been invited to, this should only be used if the coredata is currently empty
    func CDRetrieveAllEventsFB(){
        
        print("running func CDRetrieveAllEvents")
        
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
                        CDNewEvent.startDatesDisplay = self.dateArrayToDisplayDates(dates: documentEventData.get("startDates") as! [String])
                        
//                        append the new event onto CDNewEvent
                        CDEevents.append(CDNewEvent)

                    }
//                    print("CDEevents \(CDEevents)")
                    self.CDSaveData()
                }
                   }}}
    
    
    
//    function to retrieve all the availability from Firebase, this should only be used if the coredata is currently empty
    func CDRetrieveAllAvailabilityFB(eventIDs: [String]){
            print("running func CDRetrieveAllAvailabilityFB inputs - eventIDs \(eventIDs)")
        for event in eventIDs{
            
           dbStore.collection("userEventStore").whereField("eventID", isEqualTo: event).getDocuments { (querySnapshot, error) in
                   if error != nil {
                       print("Error getting documents: \(error!)")
                   }
                   else {
                       
                       if querySnapshot!.isEmpty == true{
           //                the user doesn't have any  event data to retrieve
                           print("no event data to retrieve")}
                       else{
                        
                        for documentEventData in querySnapshot!.documents{
                            let CDNewAvailability = CoreDataAvailability(context: context)
                            
                            CDNewAvailability.documentID = documentEventData.documentID
                            CDNewAvailability.uid = documentEventData.get("uid") as? String
                            CDNewAvailability.userName = documentEventData.get("userName") as? String
                            CDNewAvailability.userAvailability = documentEventData.get("userAvailability") as? [Int] ?? [99]

    //                        append the new event onto CDAvailability
                            CDAvailability.append(CDNewAvailability)
                            self.CDSaveData()
                        }}}}
            
        }}
    
    
  //    function to retrieve all the availability from Firebase, this should only be used if the coredata is currently empty
    func CDRetrieveSingleAvailabilityFB(availabilityID: String){
            
            print("running func CDRetrieveSingleAvailabilityFB")
            
        dbStore.collection("userEventStore").document(availabilityID).getDocument{ (querySnapshot, error) in
                   if error != nil {
                       print("Error getting documents: \(error!)")
                   }
                   else {
                       
                    if querySnapshot!.exists == false{
                         
           //                the user doesn't have any  event data to retrieve
                           print("no availability data to retrieve")}
                       else{
                        
                            let CDNewAvailability = CoreDataAvailability(context: context)
                            
                            CDNewAvailability.documentID = querySnapshot!.documentID
                            CDNewAvailability.uid = querySnapshot!.get("uid") as? String
                            CDNewAvailability.eventID = querySnapshot!.get("eventID") as? String
                            CDNewAvailability.userName = querySnapshot!.get("userName") as? String
                            CDNewAvailability.userAvailability = querySnapshot!.get("userAvailability") as? [Int] ?? [99]

    //                        append the new event onto CDAvailability
                            CDAvailability.append(CDNewAvailability)

                        }}}
            self.CDSaveData()
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
        
        var filteredEventResults = [CoreDataAvailability]()
        
        do{
            filteredEventResults = try context.fetch(request)
                print("filteredEventResults - event count: \(filteredEventResults.count)")
                
                return filteredEventResults
                
            } catch{
                print("error fetching the data from core data \(error)")
                
                return filteredEventResults
            }
        }
    
    
//    MARK: serialising and filteting data
    
//    func to serialise data from CDStore to eventSearch class
    func serialiseEvents() -> [eventSearch]{
        
        let dateFormatterSimple = DateFormatter()
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterSimple.locale = Locale(identifier: "en_US_POSIX")
     
      var serialisedEvents = [eventSearch]()
      let retrievedResults = CDFetchFilteredEventDataFromDB()
    
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
        request.predicate = NSPredicate(format: "eventID = %@", eventID)
        filteredAvailability = CDFetchFilteredAvailabilityDataFromDB(with: request)
        
        for i in filteredAvailability{
            var nextAvailability = AvailabilityStruct()
            nextAvailability.documentID = i.documentID ?? ""
            nextAvailability.eventID = i.eventID ?? ""
            nextAvailability.uid = i.uid ?? ""
            nextAvailability.userAvailability = i.userAvailability ?? [100]
            nextAvailability.userName = i.userName ?? ""
            serialisedAvailability.append(nextAvailability)
        }
        return serialisedAvailability
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
    
   
    
//    MARK: snapshot listener section
        
//    fuction for turning on and off the snapshot listener on the eventNotification table
    func eventChangeListener(){
        print("engaging eventChangeListener")
            dbStore.collection("userEventUpdates").document(user!).addSnapshotListener(){ querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                print("eventChangeListener triggered")
                let source = snapshot.metadata.hasPendingWrites ? "Local" : "Server"
                if source == "local"{
                    print("This is the local trigger, we don't do anything with this")
                }
                else{
                    if snapshot.data()?.isEmpty == true || snapshot.exists == false{
                     print("there was no data in the snapshot event listener")
                    }
                    else{
                    print("eventChangeListener document changed and there was data to retrieve")
                        let documentData: [String: Any] = (snapshot.data()!)
                 
                        self.CDRetrieveUpdatedEvents(eventIDs: documentData)
                    
                }}}
            }
    
    
//    MARK: Misc functions
    
    //    convert date array into display format
    func dateArrayToDisplayDates(dates: [String]) -> [String]{
        let dateFormatterTz = DateFormatter()
        dateFormatterTz.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTz.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterForResults = DateFormatter()
        dateFormatterForResults.dateFormat = "E d MMM"
        dateFormatterForResults.locale = Locale(identifier: "en_US_POSIX")
        var formattedDates = [String]()
        for date in dates{
            let dateDate = dateFormatterTz.date(from: date)
            let dateString = dateFormatterForResults.string(from: dateDate!)
            formattedDates.append(dateString)
        }
        return formattedDates
    }
    
    
    }

//Extra code not being used

////MARK: not being used: retrieve specific sorted events from the CoreData
//    func getEventsFromCD(pending: Bool, createdByUser: Bool, pastEvents: Bool) -> [CoreDataEvent]{
//
//        print("running func getEventsFromCD inputs - pending: \(pending) createdByUser \(createdByUser) pastEvents: \(pastEvents)")
//
//        var filteredUserEvents = [CoreDataEvent]()
//
//        if createdByUser == true && pending == true{
////            get events where the current user created the event and they are pending
//            let request : NSFetchRequest<CoreDataEvent> = CoreDataEvent.fetchRequest()
//            request.predicate = NSPredicate(format: "eventOwner = %@ AND chosenDate = %@", user!,"")
//            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
//            filteredUserEvents = CDFetchFilteredEventDataFromDB(with: request)
//
//            return filteredUserEvents
//        }
//                    if createdByUser == false && pending == true{
//            //            get events where the current user created the event and they are pending
//                        let request : NSFetchRequest<CoreDataEvent> = CoreDataEvent.fetchRequest()
//                        request.predicate = NSPredicate(format: "eventOwner == %@ AND chosenDate == %@", user!,"")
//                        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
//                        filteredUserEvents = CDFetchFilteredEventDataFromDB(with: request)
//
//                        return filteredUserEvents
//                    }
//        else{
//            return filteredUserEvents
//
//        }
//
//
//
//    }
