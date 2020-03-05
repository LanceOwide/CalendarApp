//
//  AutoRespondHelper.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 25/02/2020.
//  Copyright © 2020 Lance Owide. All rights reserved.
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
import CoreData


class AutoRespondHelper {
    
    
   static func sendUserAvailabilityAuto(eventID: String, completion: @escaping()-> Void){
            
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
                    

                        getEventInformation3Auto(eventID: eventID, userEventStoreID: documentID) { (userEventStoreID, eventSecondsFromGMT, startDates, endDates, users) in
                                    
                                    print("Succes getting the event data")
                                    
                                    print("startDates: \(startDates), endDates: \(endDates)")
                                    
                                    
                                    let numberOfDates = endDates.count - 1
                            
                                    let dateFormatterTZ = DateFormatter()
                                    dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
                                    dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
                                    
                                    let startDateDate = dateFormatterTZ.date(from: startDates[0])
                                    let endDateDate = dateFormatterTZ.date(from: endDates[numberOfDates])

                                    getCalendarData3Auto(startDate: startDateDate!, endDate: endDateDate!){ (datesOfTheEvents, startDatesOfTheEvents, endDatesOfTheEvents) in
                                        
                                        compareTheEventTimmings3Auto(datesBetweenChosenDatesStart: startDates, datesBetweenChosenDatesEnd: endDates, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents){
                                            (finalAvailabilityArray) in
                                            
                                            commitUserAvailbilityDataAuto(userEventStoreID: userEventStoreID, finalAvailabilityArray2: finalAvailabilityArray, eventID: eventID){
                                            
                                            availabilityCreatedNotificationAuto(userIDs: users, availabilityDocumentID: userEventStoreID)
                                            
                                            completion()
                                            }
                                        }
                                    }
                            
                                    }}}}}
    
    
    
    //    function used to pull down the information of the event stored in the Firebase database
   static func getEventInformation3Auto(  eventID:String, userEventStoreID: String, completion: @escaping (_ userEventStoreID: String, _ eventSecondsFromGMT: Int, _ startDates: [String], _ endDates: [String],_ userIDs: [String]) -> Void) {
        
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
                    let users = document!.get("users") as! [String]
                    daysOfTheWeek = document!.get("daysOfTheWeek") as! [Int]
       
                        completion( userEventStoreID, eventSecondsFromGMT, startDates, endDates, users)
                    }
                
        })}
    
    
    static func getCalendarData3Auto(startDate: Date, endDate: Date, completion: @escaping (_ datesOfTheEvents: Array<Date>, _ startDatesOfTheEvents: Array<Date>,_ endDatesOfTheEvents: Array<Date>)-> Void){
           
           
           print("running func getCalendarData3 inputs - startDate: \(startDate) endDate: \(endDate)")
           
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
           
           completion(datesOfTheEvents, startDatesOfTheEvents, endDatesOfTheEvents)
           
           
       }
    
   
    static func compareTheEventTimmings3Auto(datesBetweenChosenDatesStart: [String], datesBetweenChosenDatesEnd: [String], startDatesOfTheEvents: Array<Date>, endDatesOfTheEvents: Array<Date>, completion: @escaping (_ finalAvailabilityArray: Array<Int>)-> Void){
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
                
                print("User doesn't have events in thier calendar for this period")
            
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
             completion(finalAvailabilityArray)
        }
    
    //    commits the user availability data to the userEventStore and also adds the notifications to the availabilityNotificationStore
        static func commitUserAvailbilityDataAuto(userEventStoreID: String, finalAvailabilityArray2: [Int], eventID: String, completion: @escaping () -> Void){
        print("running func commitUserAvailbilityData inputs - userEventStoreID: \(userEventStoreID) finalAvailabilityArray2: \(finalAvailabilityArray2) eventID: \(eventID)")
        let dbStoreInd = Firestore.firestore()
    
            dbStoreInd.collection("userEventStore").document(userEventStoreID).setData(["userAvailability" : finalAvailabilityArray2,"userResponded": true], merge: true)
            completion()
    }
    
    
    
    //    notification function for new availability
       static func availabilityCreatedNotificationAuto(userIDs: [String], availabilityDocumentID: String){
          print("running func availabilityCreatedNotification- adding notificaitons to userAvailabilityUpdates - inputs - userIDs \(userIDs) availabilityString \(availabilityDocumentID)")
            
            for i in userIDs{
    //            add the eventID and an updated notification to the userEventUpdates tbales
                dbStore.collection("userAvailabilityUpdates").document(i).setData([availabilityDocumentID: "New"])
            }
        }
    
    
    //    check for events with updated flags in the userEventsUpdate table
        static func CDRetrieveUpdatedEventCheckAuto(completion: @escaping (_ eventIDString: [String:Any]) -> Void){
            
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
    
    
    //    adds, deletes and amends events based on the userEventNotifications table in FireStore
        static func CDRetrieveUpdatedEventsAuto(eventIDs: [String: Any], completion: @escaping () -> Void){
            
//            MARK: we need this function to tell us when it is complete!!!!!!! DEV!!!!!!
            print("running func CDRetrieveUpdatedEvents inputs - eventIDs: \(eventIDs)")
            
            let numberOfEvents = eventIDs.count
            var n = 0
    //        loop thorugh the eventIDs and determine the action for each notification
            for i in eventIDs{
                let notification = i.value as! String
                n = n + 1
                
                if notification == "delete" || notification == "Delete"{
                    print("CDRetrieveUpdatedEvents - deleting event \(i.key)")
    //                event has been deleted, we remove it from our array of events
                    if let index = CDEevents.index(where: {$0.eventID == i.key}){
                        context.delete(CDEevents[index])
                        CDEevents.remove(at: index)
                        print("index: \(index)")
                        self.CDSaveDataAuto()
                    }
    //                    remove the event notification from the event notification table
                    self.removeSignleEventNotificationsAuto(eventID: i.key)
                    
//                  mark complete if we are on the final event
                    if n == numberOfEvents{
                        completion()
                    }
                }
                else if notification == "amend" || notification == "Amend"{
                    print("CDRetrieveUpdatedEvents - amending event \(i.key)")
    //                event has been updated, delete the event from our array of events and repalce it
                    if let index = CDEevents.index(where: {$0.eventID == i.key}){
                        context.delete(CDEevents[index])
                        CDEevents.remove(at: index)
                        print("index: \(index)")
                        self.CDSaveDataAuto()
                    }
                    CDRetrieveSinglEventsFBAuto(eventID: i.key){(numberOfDates) in
                        
//                        we should also send new availability for the event
                        self.sendUserAvailabilityAuto(eventID: i.key){

//                            remove the event notification from the event notification table
                            self.removeSignleEventNotificationsAuto(eventID: i.key)
                            
                            //                  mark complete if we are on the final event
                            if n == numberOfEvents{
                                completion()
                            }

                        }}
                }
                else if notification == "new" || notification == "New"{
                    print("CDRetrieveUpdatedEvents - new event \(i.key)")
                    if let index = CDEevents.index(where: {$0.eventID == i.key}){
                        context.delete(CDEevents[index])
                        CDEevents.remove(at: index)
                        print("index: \(index)")
                        self.CDSaveDataAuto()
                    }
                    CDRetrieveSinglEventsFBAuto(eventID: i.key){ (numberOfDates) in
//                if the event is new, we also need to retrieve any availabilty data
                        self.CDRetrieveAllAvailabilityFBAuto(eventIDs: [i.key], eventNumberOfDates: numberOfDates){
//                        add the users availability to the user eventStore
                            self.sendUserAvailabilityAuto(eventID: i.key){
//                    remove the event notification from the event notification table
                                self.removeSignleEventNotificationsAuto(eventID: i.key)
                                
                                //                  mark complete if we are on the final event
                                if n == numberOfEvents{
                                    completion()
                                }
                            }
                        }
                    }

                }
                else if notification == "DateChosen" || notification == "dateChosen"{
                 print("CDRetrieveUpdatedEvents - dateChosen event \(i.key)")
                    
//                    we do not want to do anything with a dateChosen notification for now
//                    DEV - maybe we could show a notificiton, although APN would be better
                    
                    //                  mark complete if we are on the final event
                    if n == numberOfEvents{
                        completion()
                    }
                }
                
            }
        }
    
    
    // function to remove a single event from the notification tbale
    static func removeSignleEventNotificationsAuto(eventID: String){
        
        print("running func - removeTheEventNotifications")
        
        if user == nil{
        }
        else{
        
        dbStore.collection("userEventUpdates").document(user!).updateData([eventID : FieldValue.delete()]) { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
            }
        }
    }
    
        //    function to retrieve single event from Firebase
        static func CDRetrieveSinglEventsFBAuto(eventID: String, completion: @escaping (_ numberOfDates: [Int]) -> Void){

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
                                self.CDSaveDataAuto()
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
                            CDNewEvent.startDatesDisplay = self.dateArrayToDisplayDatesAuto(dates: documentEventData!.get("startDates") as! [String])
     //                        append the new event onto CDNewEvent
                             CDEevents.append(CDNewEvent)
                            self.CDSaveDataAuto()
                            completion([CDNewEvent.startDates!.count])
                        }
    //                    print("CDEevents \(CDEevents)")
                        
                }
            }}
    
    
    
    //    function save down the core data
    static func CDSaveDataAuto(){
        print("running func CDSaveData")
        
        do{
        try context.save()
        }
        catch{
            print("error saving data to core data with error \(error)")
        }
        
    }
    
    
    //    function for retrieveing availability from DB with any request
    static func CDFetchFilteredAvailabilityDataFromDBAuto(with request: NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()) -> [CoreDataAvailability]{
        
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
    
    
    //    fetch availability for a specific event and serialise the data
    static func serialiseAvailabilityAuto(eventID: String) -> [AvailabilityStruct]{
     print("running func serialiseAvailability inputs - eventID \(eventID)")
        var filteredAvailability = [CoreDataAvailability]()
        var serialisedAvailability = [AvailabilityStruct]()
    
        let request : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@", eventID)
        filteredAvailability = CDFetchFilteredAvailabilityDataFromDBAuto(with: request)
        
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
    
    
    
    
    //    func to serialise data from CDStore to eventSearch class for any or specific events
        static func serialiseEventsAuto(predicate: NSPredicate, usePredicate: Bool) -> [eventSearch]{
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
            
            
          let retrievedResults = CDFetchFilteredEventDataFromDBAuto(with: request)
        
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
    
    
    
    
    //    function to retrieve all the availability from Firebase, this should only be used if the coredata is currently empty
        static func CDRetrieveAllAvailabilityFBAuto(eventIDs: [String], eventNumberOfDates: [Int], completion: @escaping () -> Void ){
                print("running func CDRetrieveAllAvailabilityFB inputs - eventIDs: \(eventIDs) eventNumberOfDates: \(eventNumberOfDates)")
            
            if eventIDs.count == 0{
                
            }
            else{
            
            for n in 0...eventIDs.count - 1{
                
                let currentEventID = eventIDs[n]
                let currentAvailabilty = eventNumberOfDates[n]
                
    //            generate not responded array
                let notRespondedArray = noResultArrayCompletion2Auto(numberOfDatesInArray: currentAvailabilty).noResultsArray
                
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
                                    self.CDSaveDataAuto()
                                }
                                
                                let CDNewAvailability = CoreDataAvailability(context: context)
                                
                                CDNewAvailability.documentID = documentEventData.documentID
                                CDNewAvailability.eventID = documentEventData.get("eventID") as? String
                                CDNewAvailability.uid = documentEventData.get("uid") as? String
                                CDNewAvailability.userName = documentEventData.get("userName") as? String
                                CDNewAvailability.userAvailability = documentEventData.get("userAvailability") as? [Int] ?? [99]

        //                        append the new event onto CDAvailability
                                CDAvailability.append(CDNewAvailability)
    //                            print("CDNewAvailability \(CDNewAvailability)")
                                self.CDSaveDataAuto()
                            }
                            completion()
                        }}}}
            }}
    
    
    //    function for retrieveing events from DB with any request
  static  func CDFetchFilteredEventDataFromDBAuto(with request: NSFetchRequest<CoreDataEvent> = CoreDataEvent.fetchRequest()) -> [CoreDataEvent]{
        
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
    
    
    //    creates an array of both 10 and 11 for use in the user availability arrays, this denotes the not responded and those who have not signed up as users
    static func noResultArrayCompletion2Auto(numberOfDatesInArray: Int) -> (noResultsArray: [Int],nonUserArray: [Int]){
    
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
    
    
    //    convert date array into display format inputs yyyy-mm-dd HH:mm z output E d MMM
    static func dateArrayToDisplayDatesAuto(dates: [String]) -> [String]{
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
