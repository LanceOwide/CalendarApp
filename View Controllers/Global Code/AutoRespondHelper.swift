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
import BackgroundTasks
import CoreData
import ContactsUI




class AutoRespondHelper {
    
    
   static func sendUserAvailabilityAuto(eventID: String, completion: @escaping()-> Void){
    print("running func sendUserAvailabilityAuto")
    
    if checkCalendarStatusAuto() == false{
        print("sendUserAvailabilityAuto - checkCalendarStatusAuto = false")
    }
    else{
            
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
                                                
//                                            commit the users availability into CD
                                                commitUserAvailabilityDataCD(userEventStoreID: userEventStoreID, finalAvailabilityArray2: finalAvailabilityArray, eventID: eventID, calendarEventID: "sendUserAvailabilityAuto"){
                                            
                                            availabilityCreatedNotificationAuto(userIDs: users, availabilityDocumentID: userEventStoreID)
                                            
                                            completion()
                                                }
                                            }
                                        }
                                    }
                            
                        }}}}}}
    
    
    
    //    function used to pull down the information of the event stored in the Firebase database
   static func getEventInformation3Auto(  eventID:String, userEventStoreID: String, completion: @escaping (_ userEventStoreID: String, _ eventSecondsFromGMT: Int, _ startDates: [String], _ endDates: [String],_ userIDs: [String]) -> Void) {
        
        print("running func getEventInformation3Auto inputs - eventID: \(eventID)")
        
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
           
           
           print("running func getCalendarData3Auto inputs - startDate: \(startDate) endDate: \(endDate)")
           
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
               
//               print("dates of the events \(datesOfTheEvents)")
//               print("start dates of the events \(startDatesOfTheEvents)")
//               print("end dates of the events \(endDatesOfTheEvents)")
               
           }
           
           completion(datesOfTheEvents, startDatesOfTheEvents, endDatesOfTheEvents)
           
           
       }
    
   
    static func compareTheEventTimmings3Auto(datesBetweenChosenDatesStart: [String], datesBetweenChosenDatesEnd: [String], startDatesOfTheEvents: Array<Date>, endDatesOfTheEvents: Array<Date>, completion: @escaping (_ finalAvailabilityArray: Array<Int>)-> Void){
//            print("running func compareTheEventTimmings3Auto inputs - datesBetweenChosenDatesStart:\(datesBetweenChosenDatesStart) datesBetweenChosenDatesEnd: \(datesBetweenChosenDatesEnd) startDatesOfTheEvents:\(startDatesOfTheEvents) endDatesOfTheEvents: \(endDatesOfTheEvents)")
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
//                    print("y \(y)")
                    finalAvailabilityArray.append(1)
                    y = y + 1
                }
  
            }
                
            else{
                datesLoop: while y <= numeberOfDatesToCheck {
//                    print("y \(y)")
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
//                            print("within the dates to test")
                            finalAvailabilityArray.append(0)
                            print(finalAvailabilityArray)
                            n = 0
                            if y == numeberOfDatesToCheck{
                                
//                                print("break point y checks complete: \(y) numeberOfDatesToCheck \(numeberOfDatesToCheck)")
                                
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
//                                print(finalAvailabilityArray)
//                                print("Outside dates to test and end of the list of event dates and dates to test")
                                break datesLoop
                                
                            }
                            else if n == numberOfEventDatesToCheck{
//                                print("Outside dates to test and end of the list of dates to test, going to next event date")
                                finalAvailabilityArray.append(1)
//                                print(finalAvailabilityArray)
                                y = y + 1
                                n = 0
                            }
                            else{
//                                print("Outside dates to test")
                                n = n + 1
                            }
                        }
                        
                    }
                    n = n + 1
                    
                }}
//            print(finalAvailabilityArray)
             completion(finalAvailabilityArray)
        }
    
    //    commits the user availability data to the userEventStore and also adds the notifications to the availabilityNotificationStore
        static func commitUserAvailbilityDataAuto(userEventStoreID: String, finalAvailabilityArray2: [Int], eventID: String, completion: @escaping () -> Void){
        print("running func commitUserAvailbilityDataAuto inputs - userEventStoreID: \(userEventStoreID) finalAvailabilityArray2: \(finalAvailabilityArray2) eventID: \(eventID)")
        let dbStoreInd = Firestore.firestore()
    
            dbStoreInd.collection("userEventStore").document(userEventStoreID).setData(["userAvailability" : finalAvailabilityArray2,"userResponded": true], merge: true)
//              post a notification that we responded
            userRespondedNotification(eventID: eventID)
            
            completion()
    }
    
    
//    commits the user availability data to the users CD, this means they don't have to pull it down from the DB
    static func commitUserAvailabilityDataCD(userEventStoreID: String, finalAvailabilityArray2: [Int], eventID: String, calendarEventID: String, completion: @escaping () -> Void){
        
        //                            before we commit anything to the DB we should check if it alredy exists and remove it if it does
        if let index = CDAvailability.index(where: {$0.documentID == userEventStoreID}){
                                context.delete(CDAvailability[index])
                                CDAvailability.remove(at: index)
                                print("index: \(index)")
            self.CDSaveDataAuto()
        }
        
        let CDNewAvailability = CoreDataAvailability(context: context)
        let userName = UserDefaults.standard.string(forKey: "name") ?? ""
                                
            CDNewAvailability.documentID = userEventStoreID
            CDNewAvailability.uid = user!
            CDNewAvailability.eventID = eventID
            CDNewAvailability.userName = userName
            CDNewAvailability.userAvailability = finalAvailabilityArray2
            CDNewAvailability.calendarEventID = calendarEventID
//                        append the new event onto CDAvailability
            CDAvailability.append(CDNewAvailability)
            self.CDSaveDataAuto()
            print("commitUserAvailabilityDataCD - update complete")
            completion()
    }
    
    
    
    //    notification function for new availability
       static func availabilityCreatedNotificationAuto(userIDs: [String], availabilityDocumentID: String){
          print("running func availabilityCreatedNotification- adding notificaitons to userAvailabilityUpdates - inputs - userIDs \(userIDs) availabilityString \(availabilityDocumentID)")
            
            for i in userIDs{
//                we do not want to post a notification for the current use as they have already commited their availability to the CD
                if i == user!{
                    
                }
                else{
                
    //            add the eventID and an updated notification to the userAvailabilityUpdates tbales
                dbStore.collection("userAvailabilityUpdates").document(i).setData([availabilityDocumentID: "New"])
                    
                }
            }
        }
    
    
    //    check for events with updated flags in the userEventsUpdate table
        static func CDRetrieveUpdatedEventCheckAuto(completion: @escaping (_ eventIDString: [String:Any]) -> Void){
            print("running func CDRetrieveUpdatedEventCheckAuto")
            
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
                            
                            print("CDRetrieveUpdatedEventCheckAuto documentData \(documentData)")
                            completion(documentData)
                        }}}}}
    
    
    //    adds, deletes and amends events based on the userEventNotifications table in FireStore
        static func CDRetrieveUpdatedEventsAuto(eventIDs: [String: Any], completion: @escaping () -> Void){
            print("running func CDRetrieveUpdatedEventsAuto inputs - eventIDs: \(eventIDs)")
            Crashlytics.crashlytics().log("running func CDRetrieveUpdatedEventsAuto inputs - eventIDs: \(eventIDs)")
//            testing using dispatch to ensure all actions are run asynchronously
            let myGroup = DispatchGroup()
            
//            we add the list of events and the type of notification to the user defaults, this is used to populate the notifications tab
            UserDefaults.standard.set(eventIDs, forKey: "eventNotifications")
            
            let numberOfEvents = eventIDs.count
            var n = 0
    //        loop thorugh the eventIDs and determine the action for each notification
            for i in eventIDs{
//                start the tracking of the tasks
                myGroup.enter()
                Crashlytics.crashlytics().log("running func CDRetrieveUpdatedEventsAuto inputs - my group enter \(n)")
                let notification = i.value as! String
                n = n + 1
                print("CDRetrieveUpdatedEventsAuto - event number \(n)")
                
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
                    self.removeSignleEventNotificationsAuto(eventID: i.key){
                        NotificationCenter.default.post(name: .newDataLoaded, object: nil)
//                        once the notification has been removed, we tell the loop to go onto the next
                        Crashlytics.crashlytics().log("running func CDRetrieveUpdatedEventsAuto inputs - my group leave \(n)")
                        myGroup.leave()
  
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

//                        remove the event notification from the event notification table
                        self.removeSignleEventNotificationsAuto(eventID: i.key){
                            NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                            
//                        once the notification has been removed, we tell the loop to go onto the next
                            Crashlytics.crashlytics().log("running func CDRetrieveUpdatedEventsAuto inputs - my group leave \(n)")
                            myGroup.leave()
                            
                            }
                        }}
                }
                else if notification == "amendAvailability" || notification == "AmendAvailability"{
                                            print("amendAvailability - amending event \(i.key)")
//                event has been updated, delete the event from our array of events and repalce it
                                            if let index = CDEevents.index(where: {$0.eventID == i.key}){
                                                context.delete(CDEevents[index])
                                                CDEevents.remove(at: index)
                                                print("index: \(index)")
                                                self.CDSaveDataAuto()
                                            }
                                            CDRetrieveSinglEventsFBAuto(eventID: i.key){(numberOfDates) in
//                    remove the event notification from the event notification table
//                                upload availability for this specific event
                                                self.sendUserAvailabilityAuto(eventID: i.key){
                                                    
                                                    self.removeSignleEventNotificationsAuto(eventID: i.key){
                        NotificationCenter.default.post(name: .newDataLoaded, object: nil)
//                        once the notification has been removed, we tell the loop to go onto the next
                        Crashlytics.crashlytics().log("running func CDRetrieveUpdatedEventsAuto inputs - my group leave \(n)")
                            myGroup.leave()
                                                        
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
                                self.removeSignleEventNotificationsAuto(eventID: i.key){
                            NotificationCenter.default.post(name: .newDataLoaded, object: nil)
//                        once the notification has been removed, we tell the loop to go onto the next
                        Crashlytics.crashlytics().log("running func CDRetrieveUpdatedEventsAuto inputs - my group leave \(n)")
                                    myGroup.leave()
                                    
                                }
                            }
                        }
                    }

                }
                else if notification == "DateChosen" || notification == "dateChosen"{
                 print("CDRetrieveUpdatedEvents - dateChosen event \(i.key)")
                    
//                    we do not want to do anything with a dateChosen notification for now
//                    DEV - maybe we could show a notificiton, although APN would be better
                    
//                    we still need to leave the group, even if nothing happens
                    Crashlytics.crashlytics().log("running func CDRetrieveUpdatedEventsAuto inputs - my group leave \(n)")
                    myGroup.leave()
                    
                }
                
            }
//            complete the for loop and mark as complete
            myGroup.notify(queue: .main) {
                print("Finished all requests.")
                Crashlytics.crashlytics().log("running func CDRetrieveUpdatedEventsAuto inputs - Finished all requests")
                completion()
            }
        }
    
    
    // function to remove a single event from the notification tbale
    static func removeSignleEventNotificationsAuto(eventID: String, completion: @escaping () -> Void){
        print("running func - removeSignleEventNotificationsAuto inputs eventID \(eventID)")
        Crashlytics.crashlytics().log("running func - removeSignleEventNotificationsAuto inputs eventID \(eventID)")
        if user == nil{
            completion()
            Crashlytics.crashlytics().log("removeSignleEventNotificationsAuto - user = nil")
        }
        else{
            dbStore.collection("userEventUpdates").document(user!).updateData([eventID : FieldValue.delete()]) { err in
            if let err = err {
                print("Error removing document: \(err)")
                Crashlytics.crashlytics().log("removeSignleEventNotificationsAuto - Error removing document: \(err)")
                completion()
            } else {
                print("Document successfully removed!")
                Crashlytics.crashlytics().log("removeSignleEventNotificationsAuto - Document successfully removed!")
                completion()
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
        print("running func CDSaveDataAuto")
        
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
                print(" CDFetchFilteredAvailabilityDataFromDBAuto - filteredAvailabilityResults - availability count: \(filteredAvailabilityResults.count) filteredAvailabilityResults \(filteredAvailabilityResults)")
                
                return filteredAvailabilityResults
                
            } catch{
                print("error fetching the data from core data \(error)")
                
                return filteredAvailabilityResults
            }
        }
    
    
    //    fetch availability for a specific event and serialise the data
    static func serialiseAvailabilityAuto(eventID: String) -> [AvailabilityStruct]{
     print("running func serialiseAvailabilityAuto inputs - eventID \(eventID)")
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
//            print("nextAvailability \(nextAvailability)")
            serialisedAvailability.append(nextAvailability)
        }
        return serialisedAvailability
    }
    
    
    
    
    //    func to serialise data from CDStore to eventSearch class for any or specific events
        static func serialiseEventsAuto(predicate: NSPredicate, usePredicate: Bool) -> [eventSearch]{
            print("runing func serialiseEventsAuto inputs - usePredicate: \(usePredicate)")
            
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
                let lastDate = n.endDateArray.last!
                let lateDateYYYMMDD = lastDate[0...9]
                let finalSearchDate = dateFormatterSimple.date(from: String(lateDateYYYMMDD))
                n.finalSearchDate = finalSearchDate!.addingTimeInterval(TimeInterval(secondsFromGMT))
                
    //            changing the event owner name to be you for those events the user is hosting
                
                if CDNewEvent.eventOwnerName! == user{
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
    
    
    //    Ask the user for permission to show them notificaitons
   static func registerForPushNotificationsAuto() {
    print("running func - registerForPushNotificationsAuto")
    
    let badgeBool = UserDefaults.standard.bool(forKey: "notificationBadge")
    let bannerBool = UserDefaults.standard.bool(forKey: "notificationBanners")
    print("badgeBool \(badgeBool) bannerBool \(bannerBool)")
    
    var options = UNAuthorizationOptions()
    
    if badgeBool == true && bannerBool == true{
        options = [.alert, .sound, .badge]
    }
    if badgeBool == true && bannerBool == false{
        options = [.sound, .badge]
    }
    if badgeBool == false && bannerBool == true{
        options = [.alert, .sound]
    }
    if badgeBool == false && bannerBool == false{
        options = [.alert, .sound, .badge]
    }
    
      UNUserNotificationCenter.current() // 1
        .requestAuthorization(options: options) { // 2
          granted, error in
          print("Permission granted: \(granted)") // 3
            guard granted else {
                
                print("user didnt give us access to their notifications")
                return }
            
            // 1 set the action we would like to perform
            let respondAction = UNNotificationAction(
              identifier: "respondAction", title: "Auto Respond",
              options: [])
            
            let viewAction = UNNotificationAction(
            identifier: "viewAction", title: "View Event",
            options: [.foreground])

            // 2
            let newsCategory = UNNotificationCategory(
              identifier: "newEventCategory", actions: [respondAction, viewAction],
              intentIdentifiers: [], options: [])

            // 3
            UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
            self.getNotificationSettings()
            self.getUserPushToken()
      }
    }
    
    
    //    Returns the user notification settings the user gave us access to
   static func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    static func getUserPushToken(){
    InstanceID.instanceID().instanceID { (result, error) in
    if let error = error {
    print("Error fetching remote instance ID: \(error)")
    } else if let result = result {
    print("Remote instance ID token: \(result.token)")
//    check to see if the user token has chnaged, if it hasnt we don't need to write the token to the database
        
//        let userNotificationToken = UserDefaults.standard.string(forKey: "userNotificationToken") ?? ""
        
//        if userNotificationToken == result.token{
//         print("getUserPushToken - user token hasn't changed")
//        }
//        else{
        
        if user == nil{
            print("getUserPushToken - user hasn't signed-in yet")
        }
        else{
//            set the default for the push token
            UserDefaults.standard.set(result.token, forKey: "userNotificationToken")
            
        dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments { (querySnapshot, error) in
            
            print("getUserPushToken - querySnapshot \(String(describing: querySnapshot))")
            
            if error != nil {
                print("getUserPushToken - there was an error")
            }
            else {
                for document in querySnapshot!.documents {
                    
                    print("getUserPushToken - there was no issue")
                 
                    let documentID = document.documentID
                    let name = document.get("name")
                    UserDefaults.standard.set(name, forKey: "name")
                    // Reference for the realtime database
                    let ref = Database.database().reference()
                    
                    dbStore.collection("users").document(documentID).setData(["tokenID" : result.token], merge: true)
                    
//                    we remove all previous device tokens
                    ref.child("users").child(user!).removeValue()
                    
//                    save down the new device tokens and the users name
                    ref.child("users/\(user!)/\(result.token)").setValue(result.token)
                    ref.child("users/\(user!)/name").setValue(name)
//                }
                
            }}}}}}}
    
    
    static func checkCalendarStatusAuto() -> Bool{
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            requestAccessToCalendar2Auto()
            return false
        case EKAuthorizationStatus.authorized:
            print("We got access")
            return true
        case EKAuthorizationStatus.denied:
//            requestAccessToCalendar2Auto()
            print("No access")
            return false
        case .restricted:
            print("Access denied")
            return false
        }
        
    }
    
//        request access to the users calendar
    static func requestAccessToCalendar2Auto() {
        print("running func requestAccessToCalendar2Auto")
        
        let calendarAccessReask = UserDefaults.standard.integer(forKey: "calendarAccessReask") ?? 0
        
        if calendarAccessReask == 0{
        
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                //                print("we got access")
                self.loadCalendars2Auto()
//                since we were just granted access to the calendar we should respond to any events
                AutoRespondHelper.nonRespondedEventsAuto()

            }
            else{
//                we do not want to show the user this message more than once, so we track it
                UserDefaults.standard.set(1, forKey: "calendarAccessReask")
                print("no access to the calendar")
            }
            
        })}
        else{
//            we already asked the user for access and they said no
        }
    }
    
//    function for loading the calendars into the structs
    static func loadCalendars2Auto(){

//        we only want this function to run once and not multiple times, as doing this can cause a crash. so we set a property to notify when the function is already being called
        if loadCalendars2AutoIsRunning == true{
//            we dont run the function
        }
        else{
            loadCalendars2AutoIsRunning = true
        
        print("running func loadCalendars2")
        var calendars: [EKCalendar]!
            calendars = eventStore.calendars(for: EKEntityType.event)
            
    //        If the calendar array hasnt been created previously then then the function creates a new array, or if there are no selected calendars, we repopulate. we also check if this fucntion is already running
        if SelectedCalendarsStruct.calendarsStruct.count == 0 || SelectedCalendarsStruct.selectedCalendarArray.count == 0 {
                
                SelectedCalendarsStruct.calendarsStruct = calendars!
            
//            we set the variable to true so that we do not run the function more than once
            loadCalendars2AutoIsRunning = true
            
//            we loop through the calendars and add them to the selected calendar array
            for calendar in calendars{
                SelectedCalendarsStruct.selectedCalendarArray.append(1)
            }
                
//                BUG: we loop through the list of calendars we don't want to use - this should be made a struct, we also remove them from the list of selected calendars
                if let index = SelectedCalendarsStruct.calendarsStruct.index(where: {$0.title == "US Holidays"}){
                    SelectedCalendarsStruct.calendarsStruct.remove(at: index)
                }
                if let index1 = SelectedCalendarsStruct.calendarsStruct.index(where: {$0.title == "UK Holidays"}){
                    SelectedCalendarsStruct.calendarsStruct.remove(at: index1)
                }
                if let index2 = SelectedCalendarsStruct.calendarsStruct.index(where: {$0.title == "Birthdays"}){
                    SelectedCalendarsStruct.calendarsStruct.remove(at: index2)
                }
                if let index3 = SelectedCalendarsStruct.calendarsStruct.index(where: {$0.title == "South Korean Holidays"}){
                    SelectedCalendarsStruct.calendarsStruct.remove(at: index3)
                }
                if let index4 = SelectedCalendarsStruct.calendarsStruct.index(where: {$0.title == "Hong Kong Holidays"}){
                    SelectedCalendarsStruct.calendarsStruct.remove(at: index4)
                }
                if let index5 = SelectedCalendarsStruct.calendarsStruct.index(where: {$0.title == "Holidays in United Kingdom"}){
                    SelectedCalendarsStruct.calendarsStruct.remove(at: index5)
                }
                
                print("SelectedCalendarsStruct: \(SelectedCalendarsStruct.calendarsStruct)")
            loadCalendars2AutoIsRunning = false
   
            }
                else{
                    
                    
                }
        }
            }
    
    
//    function used to saved save a notificaiton that the user has responded to the database, this is used to trigger a notification to the event owner and the responder, we set the vaule being written to now, such that it is always updated
    static func userRespondedNotification(eventID: String){
//        we use the userdefault to ensure a new number is always written to the database, if the same value is written nothing is actually written and the listener will not be tirggered
        let notificationNumber = UserDefaults.standard.integer(forKey: "notificationNumber")
        let notificationNumberNew = notificationNumber + 1
        
        print(" running func userRespondedNotification - eventID: \(eventID)")
        let ref = Database.database().reference().child("userResponded")
        let fromId = user!
        ref.child(eventID).child(fromId).setValue(notificationNumberNew)
        UserDefaults.standard.set(notificationNumberNew, forKey: "notificationNumber")
        
    }
    
//    fucntion to check for the availability
    static func availabilityChangeListenerAuto(){
        
        if availabilityListenerEngaged == true{
            print("availabilityChangeListener already engaged, not re-engaging")
               }
               else{
                availabilityListenerEngaged = true
        
        print("engaging availabilityChangeListener")
            
            if user == nil{
            }
            else{

        availabilityListenerRegistration = dbStore.collection("userAvailabilityUpdates").document(user!).addSnapshotListener(){ (querySnapshot, error) in
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
                        
                        self.CDRetrieveUpdatedAvailabilityAuto(availabilityID: documentData)
                        
                        }}}}}

        }}
    
    //    adds, deletes and amends availability based on the userAvailabilityNotifications table in FireStore
           static func CDRetrieveUpdatedAvailabilityAuto(availabilityID: [String: Any]){
             
                print("running func CDRetrieveUpdatedAvailability inputs - availabilityID: \(availabilityID)")
                

//            we add the list of availabilities and the type of notification to the user defaults, this is used to populate the notifications tab
            UserDefaults.standard.set(availabilityID, forKey: "availabilityNotifications")
            
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
                            self.CDSaveDataAuto()

                        }
    //                        remove the notificaiton from the notification table
                        removeSingleAvailabilityNotificationsAuto(documentID: i.key)
                    }
                    else if notification == "amend" || notification == "Amend"{
                        print("CDRetrieveUpdatedAvailability - amending availability \(i.key)")
        //                event has been updated, delete the event from our array of events and repalce it
                        if let index = CDAvailability.index(where: {$0.documentID == i.key}){
                            context.delete(CDAvailability[index])
                            CDAvailability.remove(at: index)
                            print("index: \(index)")
                            self.CDSaveDataAuto()
                        }
                        CDRetrieveSingleAvailabilityFBAuto(availabilityID: i.key){
                            print("CDRetrieveUpdatedAvailability - CDRetrieveSingleAvailabilityFB: complete")
    //                        remove the specific notificaiton for that availability
                            self.nonRespondedEventsAuto()
                            NotificationCenter.default.post(name: .availabilityUpdated, object: nil)
                        }
                        self.removeSingleAvailabilityNotificationsAuto(documentID: i.key)
                    }
                    else if notification == "new" || notification == "New"{
                        print("CDRetrieveUpdatedAvailability - new availability \(i.key)")
                        if let index = CDAvailability.index(where: {$0.documentID == i.key}){
                            context.delete(CDAvailability[index])
                            CDAvailability.remove(at: index)
                            print("index: \(index)")
                            self.CDSaveDataAuto()
                        }
                        CDRetrieveSingleAvailabilityFBAuto(availabilityID: i.key){
                            print("CDRetrieveUpdatedAvailability - CDRetrieveSingleAvailabilityFB: complete")
                            NotificationCenter.default.post(name: .availabilityUpdated, object: nil)

                        }
    //                        remove the specific notificaiton for that availability
                        self.removeSingleAvailabilityNotificationsAuto(documentID: i.key)
                    }

                }
            }
    
    
    //    function to retrieve all the availability from Firebase, this should only be used if the coredata is currently empty
    static func CDRetrieveSingleAvailabilityFBAuto(availabilityID: String, completion: @escaping () -> Void ){
            
            print("running func CDRetrieveSingleAvailabilityFB inputs - availabilityID: \(availabilityID)")
            
        dbStore.collection("userEventStore").document(availabilityID).getDocument{ (querySnapshot, error) in
                   if error != nil {
                       print("Error getting documents: \(error!)")
                    completion()
                   }
                   else {
                       
                    if querySnapshot!.exists == false{
                         
           //                the user doesn't have any  event data to retrieve
                           print("no availability data to retrieve")
                        completion()
                    }
                       else{
                        
                        //                            before we commit anything to the DB we should check if it alredy exists and remove it if it does
                        if let index = CDAvailability.index(where: {$0.documentID == querySnapshot!.documentID}){
                                                context.delete(CDAvailability[index])
                                                CDAvailability.remove(at: index)
                                                print("index: \(index)")
                            self.CDSaveDataAuto()
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
                        self.CDSaveDataAuto()
                        print("CDRetrieveSingleAvailabilityFB - update complete")
                        completion()
                        
                        }}}
            
        }
    
   static func removeSingleAvailabilityNotificationsAuto(documentID: String){
        
        print("running func - removeSingleAvailabilityNotifications")
        if user == nil{
        }
        else{
        
        dbStore.collection("userAvailabilityUpdates").document(user!).updateData([documentID : FieldValue.delete()]) { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }}
        }
    }
    
    //    function to location events we haven't responded to and respond, this should run each time we open the app and maybe when we open the events page
        static func nonRespondedEventsAuto(){
    //        find events where the availability for our user ID = [99]
            print("running func nonRespondedEvents")
            
            if user == nil{
            }
            else{
            let request : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@ && (userAvailability == %@ || userAvailability == %@ || userAvailability == %@)", argumentArray:[user ?? "", [99], [11], []])
            let filteredAvailability = CDFetchFilteredAvailabilityDataFromDBAuto(with: request)
            print("nonRespondedEvents filteredAvailability \(filteredAvailability)")
                
    //            adding a catch in case nothing is returned from the request
                if filteredAvailability.count == 0{
                    
                }
                else{
    //            filter through each empty availability and respond
                for i in filteredAvailability{
                    uploadCurrentUsersAvailabilityAuto(eventID: i.eventID!)
                }
                }
            }
        }
    
    static func uploadCurrentUsersAvailabilityAuto(eventID: String){
            print("running func uploadCurrentUsersAvailabilityAuto inputs - eventID: \(eventID)")
    //        if we don't have access to the calendar we stop
            if checkCalendarStatusAuto() == false{
                   print("uploadCurrentUsersAvailability - checkCalendarStatusAuto = false")
                
                
                
               }
            else{
            
            var dateFormatterTZ = DateFormatter()
            dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
            dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
            
    //        1. retrieve the event data, eventSearch
            let predicate = NSPredicate(format: "eventID = %@", eventID)
            let predicateReturned = serialiseEventsAuto(predicate: predicate, usePredicate: true)
            if predicateReturned.count == 0{
             print("something went wrong")
            }
            else{
                let eventData = predicateReturned[0]
            print("uploadCurrentUsersAvailability documentID: \(eventData)")
            
    //        2. retrieve the documentID for the users eventStore ID
            let availabilityData = serialiseAvailabilityAuto(eventID: eventID)
            let filteredAvailabilityData = availabilityData.filter { $0.uid == user!}
                if filteredAvailabilityData.count == 0{
                    print("something went wrong")
                }
                else{
            let documentID = filteredAvailabilityData[0].documentID
            let calendarID = filteredAvailabilityData[0].calendarEventID
            print("uploadCurrentUsersAvailability documentID: \(documentID)")
            
    //        3. calcaulte the users availability
            
            let numberOfDates = eventData.endDateArray.count - 1
            
    //        check that we have start or end dates and abort if we dont
            if eventData.startDateArray.count == 0 || eventData.endDateArray.count == 0{
                 print("something went wrong")
    //            WE SHOULD ADD A FIX HERE
            }
            else{

            let startDateDate = dateFormatterTZ.date(from: eventData.startDateArray[0])
            let endDateDate = dateFormatterTZ.date(from: eventData.endDateArray[numberOfDates])
                let users = eventData.users
                
            getCalendarData3Auto(startDate: startDateDate!, endDate: endDateDate!){ (datesOfTheEvents, startDatesOfTheEvents, endDatesOfTheEvents) in


                compareTheEventTimmings3Auto(datesBetweenChosenDatesStart: eventData.startDateArray, datesBetweenChosenDatesEnd: eventData.endDateArray, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents){
            (finalAvailabilityArray) in
            print("uploadCurrentUsersAvailability finalAvailabilityArray: \(finalAvailabilityArray)")

    //                        add the finalAvailabilityArray to the userEventStore
                    commitUserAvailbilityDataAuto(userEventStoreID: documentID, finalAvailabilityArray2: finalAvailabilityArray, eventID: eventID){
                        
                        //                                            commit the users availability into CD
                        commitUserAvailabilityDataCD(userEventStoreID: documentID, finalAvailabilityArray2: finalAvailabilityArray, eventID: eventID, calendarEventID: calendarID){
                        
                        availabilityCreatedNotificationAuto(userIDs: users, availabilityDocumentID: documentID)
                        NotificationCenter.default.post(name: .availabilityUpdated, object: nil)
                        }}
                }}}}}}
        }
 
    
//    static func for checking if the event has its date chosen and updating the event information, the input is the eventID
    
    static func checkValidityOfCalendareevnt(eventID: String){
        print("running func checkValidityOfCalendareevnt eventID: \(eventID)")
        
     //        1. retrieve the event data, eventSearch
        let predicate = NSPredicate(format: "eventID = %@", eventID)
        let predicateReturned = serialiseEventsAuto(predicate: predicate, usePredicate: true)
        if predicateReturned.count == 0{
            print("soemthing we wrong, we end the function")
        }
        else{
         let eventToCheck = predicateReturned[0]
//        2. get the users availability to check if they have a calendar event
          let availabilityData = serialiseAvailabilityAuto(eventID: eventID)
            let filteredAvailabilityData = availabilityData.filter {$0.uid == user!}
                if filteredAvailabilityData.count == 0{
                    print("checkValidityOfCalendareevnt - something went wrong")
                }
                else{
                    print("checkValidityOfCalendareevnt - filteredAvailabilityData \(filteredAvailabilityData)")
                    let usersAvailability = filteredAvailabilityData[0]
                    let eventCalendarID = usersAvailability.calendarEventID
                    print("eventCalendarID \(eventCalendarID)")
                    
//                    3. check to see if the user has saved the event into their calendar
                    
                    let defaultCalendarToSave = UserDefaults.standard.string(forKey: "saveToCalendar") ?? ""
                    let eventStore = EKEventStore()
                    
                    eventStore.requestAccess(to: .event, completion: { (granted, error) in
                    if (granted) && (error == nil) {
                    if eventCalendarID == "" || eventStore.event(withIdentifier: eventCalendarID) == nil{
                        print("user hasnt saved the event into thier calendar or we couldn't find the event, we should do some clean up here if that is the case eventCalendarID \(eventCalendarID) eventStore.event(withIdentifier: eventCalendarID) \(String(describing: eventStore.event(withIdentifier: eventCalendarID)))")
//                        we clean up the data by removing any event that has been saved down
     
                    }
//                        if the event chosen date has been removed, but the event is still in the users calendar we remove it
                    else if eventToCheck.chosenDate == "" && eventCalendarID != "" && eventStore.event(withIdentifier: eventCalendarID) != nil{
                        
                        let event = eventStore.event(withIdentifier: eventCalendarID)
                        do{
//                            remove the event from the calendar
                            try eventStore.remove(event!, span: .thisEvent)
                            
//                            set the ID for the event in CD to ""
                        }
                        catch{
                            
                        }
                    }
                    else{
//                       4. update the information in the users calendar
                        let event = eventStore.event(withIdentifier: eventCalendarID)!
                        let dateFormatterTZCreate = DateFormatter()
                        dateFormatterTZCreate.dateFormat = "yyyy-MM-dd HH:mm z"
                        dateFormatterTZCreate.locale = Locale(identifier: "en_US_POSIX")
                        //                    let event = EKEvent(eventStore: eventStore)
                        event.title = eventToCheck.eventDescription
                            print("Event being saved: Title \(String(describing: event.title))")
                        event.startDate = dateFormatterTZCreate.date(from: eventToCheck.startDateArray[eventToCheck.chosenDatePosition])
                            print("Event being saved: startDate \(String(describing: event.startDate))")
                        event.endDate = dateFormatterTZCreate.date(from: eventToCheck.endDateArray[eventToCheck.chosenDatePosition])
                            print("Event being saved: endDate \(String(describing: event.endDate))")
                        event.notes = eventToCheck.eventDescription
                            print("Event being saved: description \(String(describing: event.description))")
                            
                        if eventToCheck.locationLongitude == 0.0{
                                
                            event.location = eventToCheck.eventLocation
                                print("Event being saved: Location \(String(describing: event.location))")
                                
                            }
                            else{
                                
                            let geoLocation = CLLocation(latitude: eventToCheck.locationLatitue, longitude: eventToCheck.locationLongitude)
                            let structuredLocation = EKStructuredLocation(title: eventToCheck.eventLocation)
                                
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
//                                completion?(false, e)
                                return
                            }
                        }}
                        else {
//                            completion?(false, error as NSError?)
                            print(error ?? "no error message")
                            print("error saving event")
                        }
                    })
            }
        }
    }
    
    
    static func setupNotificatonPage(){
//     let eventNotifications = UserDefaults.standard(forKey: "eventNotifications")
        
        
    }
    
    static func getUserContacts(completion: @escaping () -> Void){
             print("Attempting to fetch the contacts")
             
             contacts.removeAll()

             let store = CNContactStore()
             
             store.requestAccess(for: .contacts) { (granted, error) in
                 if let error = error {
                     print("Failed to get access",error)
                     
                     print("Access Denied")
                     
                     let alert = UIAlertController(title: "Acess to Contacts Denied", message: "Please go to setting to enable Planr access", preferredStyle: UIAlertController.Style.alert)
                     
                     // add the actions (buttons)
                     alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { action in
                         
                         print("User selected OK")
                         
                     }))
                     
                     alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                         
                         guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                             return
                         }
                         
                         if UIApplication.shared.canOpenURL(settingsUrl) {
                         UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                             print("Settings opened: \(success)") // Prints true
                         })}
                         
                         
                         print("User selected Settings")
                         
                     }))
                     
                     // show the alert
                     NL_AddInvitees().present(alert, animated: true, completion: nil)

                 }
                 if granted{
                     print("Acccess Granted")
                     
                     //                Need to request access to both the given name and the family name and the phone number, each has its own key
                     let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]
                     let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                     
                     do{
                         
                         try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopPointerEnumerating) in
                             //                        print(contact.givenName)
                             
                             contacts.append(contactList(name: contact.givenName + " " + contact.familyName, phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "", selectedContact: false))

                         })
                         
                         contactsSorted = contacts.sorted(by: { $0.name < $1.name })
                         
                         contactsSorted.removeAll {$0.name == ""}
                         contactsSorted.removeAll {$0.name == " "}
                         contactsSorted.removeAll {$0.name == "  "}
                         contactsSorted.removeAll {$0.name == "   "}
                         contactsSorted.removeAll {$0.name == "    "}
                         contactsSorted.removeAll {$0.name == "     "}
                         contactsSorted.removeAll {$0.name == "      "}
                         contactsSorted.removeAll {$0.name == "       "}
                         contactsSorted.removeAll {$0.phoneNumber == ""}
                         contactsSorted.removeAll {$0.phoneNumber == " "}
                         contactsSorted.removeAll {$0.phoneNumber == "  "}
                         contactsSorted.removeAll {$0.phoneNumber == "   "}
                         contactsSorted.removeAll {$0.phoneNumber == "    "}
                         contactsSorted.removeAll {$0.phoneNumber == "     "}
                         contactsSorted.removeAll {$0.phoneNumber == "      "}
                         contactsSorted.removeAll {$0.phoneNumber == "       "}
                             
                         
                         completion()
                         
                     } catch let error{
                         print("Failed to enumerate contacts:",error)
                     }
                 }
                 else{
                     print("Access Denied")
                     
                     let alert = UIAlertController(title: "Acess to Contacts Denied", message: "Please go to setting to enable Planr access", preferredStyle: UIAlertController.Style.alert)
                     
                     // add the actions (buttons)
                     alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { action in
                         
                         print("User selected OK")
                         
                     }))
                     
                     alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                         
                         guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                             return
                         }
                         
                         if UIApplication.shared.canOpenURL(settingsUrl) {
                         UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                             print("Settings opened: \(success)") // Prints true
                         })}
                         
                         
                         print("User selected Settings")
                         
                     }))
                     
                     // show the alert
                    NL_AddInvitees().present(alert, animated: true, completion: nil)
        
                 }
             }
         }
    
    
    static func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    
    
    //    MARK: Functions for deleting a created event
    
    //    section for deleting the realtime database entries
        static func deleteRealTimeDatabaseEventInfo(eventID: String){
        let ref = Database.database().reference()
            
            ref.child("events/\(eventID)").removeValue()
       
        }
        
    //    function to delete the new event notification
    static   func deleteRealTimeDatabaseUserEventLink(eventID: String){
            let ref = Database.database().reference()
            ref.child("userEventLink/\(user!)/newEvent/\(eventID)").removeValue()
        }
    
    
        
   static func deleteEventRequest(eventID: String){
            let docRefEventRequest = dbStore.collection("eventRequests")
            
            docRefEventRequest.document(eventID).delete()
        }
        
    //    fucntion to delete the eventStore
        static func deleteEventStore(eventID: String){
            
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
        
        static func deleteTemporaryUserEventStore(eventID: String){
            
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
        static func deleteEventStoreAvailability(eventID: String){
            
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
    
    
    //        function to reminder the user to respond, we post to both the notifications in Firestore and to realtime databse to send a message
         static   func sendTheUserAReminder(eventID: String, userID: String){
                let rRef = Database.database().reference()
                
    //            post to Firestore
                dbStore.collection("userEventUpdates").document(userID).setData([eventID : "new"], merge: true)
                
    //            set the realtime database
                rRef.child("userEventLink/\(userID)/eventReminder/\(eventID)").setValue(eventID)
                
            }

    
//    helper end
}


