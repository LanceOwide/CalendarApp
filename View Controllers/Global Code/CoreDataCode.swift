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
        dbStore.collection("eventRequests").document(eventID).getDocument{ (querySnapshot, error) in
                if error != nil {
                    print("Error getting documents: \(error!)")
                }
                else {
                    if querySnapshot!.exists == false{
                      
        //                the user doesn't have any  event data to retrieve
                        print("the event is no longer available")
                    }
                    else{
                         let eventID = querySnapshot!.documentID
                         let startTimeString = querySnapshot!.get("startTimeInput") as! String
                         let startDateString = querySnapshot!.get("startDateInput") as! String
                         let allStartDates = querySnapshot!.get("startDates") as! [String]
                         let endTimeString = querySnapshot!.get("endTimeInput") as! String
                         let allEndDates = querySnapshot!.get("endDates") as! [String]
                         let endDateString = querySnapshot!.get("endDateInput") as! String
                         let daysOfTheWeek = querySnapshot!.get("daysOfTheWeek") as! [Int]
                         let chosenDatePosition = querySnapshot!.get("chosenDatePosition") as? Int ?? 999
                         let chosenDateCD = querySnapshot!.get("chosenDate") as? String ?? ""
                         let chosenDateDay = querySnapshot!.get("chosenDateDay") as? Int ?? 999
                         let secondsFromGMT = querySnapshot!.get("secondsFromGMT") as? Int ?? 999
                         let chosenDateMonth = querySnapshot!.get("chosenDateMonth") as? Int ?? 999
                         let chosenDateYear = querySnapshot!.get("chosenDateYear") as? Int ?? 999
                         let eventCreatorName = querySnapshot!.get("eventOwnerName") as? String ?? ""
                         let eventCreatorID = querySnapshot!.get("eventOwner") as? String ?? ""
                         let eventLocation = querySnapshot!.get("location") as? String ?? ""
                         let isAllDay = querySnapshot!.get("isAllDay") as? String ?? ""
                         let eventDescription = querySnapshot!.get("eventDescription") as? String ?? ""
                         let locationLongitude = querySnapshot!.get("locationLongitude") as? Double ?? 0.0
                         let locationLatitude = querySnapshot!.get("locationLatitude") as? Double ?? 0.0
                         
                         let CDNewEvent = CoreDataEvent(context: context)
                         
                         CDNewEvent.chosenDate = chosenDateCD
                         CDNewEvent.chosenDateDay = Int32(chosenDateDay)
                         CDNewEvent.chosenDateMonth = Int32(chosenDateMonth)
                         CDNewEvent.chosenDatePosition = Int32(chosenDatePosition)
                         CDNewEvent.chosenDateYear = Int32(chosenDateYear)
                         CDNewEvent.daysOfTheWeek = daysOfTheWeek
                         CDNewEvent.endDateInput = endDateString
                         CDNewEvent.endDates = allEndDates
                         CDNewEvent.endTimeInput = endTimeString
                         CDNewEvent.eventDescription = eventDescription
                         CDNewEvent.eventID = eventID
                         CDNewEvent.eventOwner = eventCreatorID
                         CDNewEvent.eventOwnerName = eventCreatorName
                         CDNewEvent.isAllDay = isAllDay
                         CDNewEvent.location = eventLocation
                         CDNewEvent.locationLatitue = locationLatitude
                         CDNewEvent.locationLongitude = locationLongitude
                         CDNewEvent.secondsFromGMT = Int32(secondsFromGMT)
                         CDNewEvent.startDates = allStartDates
                         CDNewEvent.startDateInput = startDateString
                         CDNewEvent.startTimeInput = startTimeString
                         
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
                     
                        let eventID = documentEventData.documentID
                        let startTimeString = documentEventData.get("startTimeInput") as! String
                        let startDateString = documentEventData.get("startDateInput") as! String
                        let allStartDates = documentEventData.get("startDates") as! [String]
                        let endTimeString = documentEventData.get("endTimeInput") as! String
                        let allEndDates = documentEventData.get("endDates") as! [String]
                        let endDateString = documentEventData.get("endDateInput") as! String
                        let daysOfTheWeek = documentEventData.get("daysOfTheWeek") as! [Int]
                        let chosenDatePosition = documentEventData.get("chosenDatePosition") as? Int ?? 999
                        let chosenDateCD = documentEventData.get("chosenDate") as? String ?? ""
                        let chosenDateDay = documentEventData.get("chosenDateDay") as? Int ?? 999
                        let secondsFromGMT = documentEventData.get("secondsFromGMT") as? Int ?? 999
                        let chosenDateMonth = documentEventData.get("chosenDateMonth") as? Int ?? 999
                        let chosenDateYear = documentEventData.get("chosenDateYear") as? Int ?? 999
                        let eventCreatorName = documentEventData.get("eventOwnerName") as? String ?? ""
                        let eventCreatorID = documentEventData.get("eventOwner") as? String ?? ""
                        let eventLocation = documentEventData.get("location") as? String ?? ""
                        let isAllDay = documentEventData.get("isAllDay") as? String ?? ""
                        let eventDescription = documentEventData.get("eventDescription") as? String ?? ""
                        let locationLongitude = documentEventData.get("locationLongitude") as? Double ?? 0.0
                        let locationLatitude = documentEventData.get("locationLatitude") as? Double ?? 0.0
                        
                        let CDNewEvent = CoreDataEvent(context: context)
                        
                        CDNewEvent.chosenDate = chosenDateCD
                        CDNewEvent.chosenDateDay = Int32(chosenDateDay)
                        CDNewEvent.chosenDateMonth = Int32(chosenDateMonth)
                        CDNewEvent.chosenDatePosition = Int32(chosenDatePosition)
                        CDNewEvent.chosenDateYear = Int32(chosenDateYear)
                        CDNewEvent.daysOfTheWeek = daysOfTheWeek
                        CDNewEvent.endDateInput = endDateString
                        CDNewEvent.endDates = allEndDates
                        CDNewEvent.endTimeInput = endTimeString
                        CDNewEvent.eventDescription = eventDescription
                        CDNewEvent.eventID = eventID
                        CDNewEvent.eventOwner = eventCreatorID
                        CDNewEvent.eventOwnerName = eventCreatorName
                        CDNewEvent.isAllDay = isAllDay
                        CDNewEvent.location = eventLocation
                        CDNewEvent.locationLatitue = locationLatitude
                        CDNewEvent.locationLongitude = locationLongitude
                        CDNewEvent.secondsFromGMT = Int32(secondsFromGMT)
                        CDNewEvent.startDates = allStartDates
                        CDNewEvent.startDateInput = startDateString
                        CDNewEvent.startTimeInput = startTimeString
                        
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
    
    
//retrieve the user created events
    
    func getUserCreatedEventPending() -> [CoreDataEvent]{
     
        let userCreatedEventsPending = [CoreDataEvent]()
        
        
        
        
     return userCreatedEventsPending
    }
    

    
}
