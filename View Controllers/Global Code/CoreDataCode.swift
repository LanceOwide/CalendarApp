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

var CDEevents = [CoreDataEvent]()
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class CoreDataCode: UIViewController {
   
}

extension UIViewController{
    
//    first function we call when the app opens, this itterates through all other functions
    func CDAppHasLoaded(){
//        fetch the core data currently saved, returns true if we didn't recieve an error
        if CDFetchEventDataFromDB() == true{
            print("we contacted CoreData")
         
            if CDEevents.count == 0{
                print("there were no events in CoreData")
//            if there were no event returned from CoreData then we must pull down all events
              CDRetrieveAllEventsFB()
            }
            else{
                print("there were events in CoreData")
//             if events were returned, we only want to retrieve the events for which we have a notification
                CDRetrieveUpdatedEventCheck{(eventIDs) in
                    
                    self.CDRetrieveUpdatedEvents(eventIDs: eventIDs)
                    
                    }}}
        else{
            print("there was an issue contacting core data")
        }}
    
    
//    MARK: - this should be converted to a snaphot listener to detect any new event notifications and update accordingly
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
                        CDNewEvent.usersNames = documentEventData!.get("usersNames") as? [String]
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
                        CDNewEvent.usersNames = documentEventData.get("usersNames") as? [String]
                        CDNewEvent.startDatesDisplay = self.dateArrayToDisplayDates(dates: documentEventData.get("startDates") as! [String])
                        
//                        append the new event onto CDNewEvent
                        CDEevents.append(CDNewEvent)

                    }
//                    print("CDEevents \(CDEevents)")
                    self.CDSaveData()
                }
                   }}}
    
    
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
    
//    function for retrieveing data from DB with any request
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
            n.usersNames = CDNewEvent.usersNames ?? [""]
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
