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
import BackgroundTasks

//variable to hold all events during core data processes
var CDEevents = [CoreDataEvent]()

//variable to hold all user availability events during core data processes
var CDAvailability = [CoreDataAvailability]()

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class CoreDataCode: UIViewController {
   
}

//variables to track whether the listeners are engaged ro not
var eventListenerEngaged = Bool()
var availabilityListenerEngaged = Bool()

extension UIViewController{
    
    
// MARK: prepare for results pages
    func prepareForEventDetailsPageCD(segueName: String, isSummaryView: Bool, performSegue: Bool, userAvailability: [AvailabilityStruct], triggerNotification: Bool, completion: @escaping () -> Void){
        
        
        print("running func prepareForEventDetailsPageCD inputs - segueName: \(segueName), isSummaryView: \(isSummaryView), performSegue: \(performSegue), userAvailability: \(userAvailability)")
            
//        globally selected current event
        let userSelectedEvent = currentUserSelectedEvent
        
//        we only want to update the is summary view when it is set to false, otherwise we will let the already set value persist
        if isSummaryView == false{
          summaryView = isSummaryView
        }
            summaryView = isSummaryView
        
//       get the non users availability array
        let nonUserArray = self.noResultArrayCompletion2(numberOfDatesInArray: userSelectedEvent.startDateArray.count + 1).nonUserArray
        
//        set whether the user can edit the event
        if userSelectedEvent.eventOwnerID == user{
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
                        if triggerNotification == true{NotificationCenter.default.post(name: .availabilityUpdated, object: nil)}
                       self.performSegue(withIdentifier: segueName, sender: self)
                        print("prepareForEventDetailsPageCD complete")
                        completion()
                    }
                    else{
                        if triggerNotification == true{NotificationCenter.default.post(name: .availabilityUpdated, object: nil)}
                        print("prepareForEventDetailsPageCD complete")
                        completion()
                    }
}


    
    
//    MARK: function to prepare core data when the app opens
//    first function we call when the app opens, this itterates through all other functions
//    we check if there were events in CoreData, if there weren't we pull them down, if not, then we just check for updated data
    func CDAppHasLoaded(completion: @escaping () -> Void){
//        fetch the core data currently saved, returns true if we didn't recieve an error
        if CDFetchEventDataFromDB() == true{
            print("CDAppHasLoaded: we contacted CoreData")
         
            if CDEevents.count == 0{
                print("CDAppHasLoaded: there were no events in CoreData")
//            if there were no event returned from CoreData then we must pull down all events, add a check to ensure we the user has been set
                
                if user == nil {
//                    delay the running of the function by 60 seconds
                    print("CDAppHasLoaded user == nil, delaying CDRetrieveAllEventsFB")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 60) { // Change `2.0` to the desired number of seconds.
                        self.CDRetrieveAllEventsFB(){
                       //                we collect the availability for these events throught the competion block
                                           self.removeTheEventNotifications()
                                       completion()
                                           }}}
                else{
                    print("CDAppHasLoaded user != nil, delaying CDRetrieveAllEventsFB")
                CDRetrieveAllEventsFB(){
//                we collect the availability for these events throught the competion block
                    self.removeTheEventNotifications()
                completion()
                    }}
            }
            else{
                print("CDAppHasLoaded: there were events in CoreData")
//             if events were returned, we only want to retrieve the events for which we have a notification
                CDRetrieveUpdatedEventCheck{(eventIDs) in
                    
                    self.CDRetrieveUpdatedEvents(eventIDs: eventIDs)
                    completion()
                    }}}
        else{
            print("CDAppHasLoaded: there was an issue contacting core data")
            completion()
        }
    }
    
    
//    first function we call when the app opens, this itterates through all other functions
        func CDAppHasLoadedAvailability(completion: @escaping () -> Void){
            print("running func CDAppHasLoadedAvailability")
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
                    
                    AutoRespondHelper.nonRespondedEventsAuto()
                    completion()
                    
                }
                        }
                        else{
                            print("there were events in CoreData")
//             if availability was returned, we only want to retrieve the events for which we have a notification
                CDRetrieveUpdatedAvailabilityCheck{(availabilityIDs) in
                                
                    self.CDRetrieveUpdatedAvailability(availabilityID: availabilityIDs)
                    completion()
            }}
        }
        else{
            
          print("there was an issue contacting CoreDataAvailability")
            completion()
        }
    }
    
    func CDAppHasLoadedChats(){
        print("running func CDAppHasLoadedChats")
        
//        we received the data from core data
        if CDFetchChatDataFromDB() == true{
            print("CDAppHasLoadedChats = true")
//            we check to see if there were any chats in the database
            if CDMessages.count == 0{
                print("CDAppHasLoadedChats CDMessages = 0 ")
//                we need to pull down the chat messages, we loop through each event in CDEvents and pass it into the chat funcion
                for event in CDEevents{
                    CDRetrieveAllChatsFB(eventID: event.eventID!){
                    }
                }
            }
        }
    }
    
//    function to pull down a chat for a specific event
    func CDRetrieveAllChatsFB(eventID: String, completion: @escaping () -> Void){
        print("running func CDRetrieveAllChatsFB - eventID \(eventID)")
    userMessagesRef = Database.database().reference().child("messages").child(eventID)
//            create the listener to the node in the databse, we only listen for children added, we do not want to listen for anything else - we may need to add deleted etc at a later date
    userMessagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
    guard let dictionary = snapshot.value as? [String: AnyObject] else {
    return
        }
        print("checkNotificationStatusListener - chats dictionary.count \(dictionary.count)")
//                    we need to loop through each of the messages and sabve them into CoreData

        for message in dictionary{
//            print("message \(message.key)")
            let messageID = message.key
            let dict = Message(dictionary: message.value as! [String : Any])
//                    do start we delete the messages already in the index
            if let index = CDMessages.index(where: {$0.messageID == eventID}){
            context.delete(CDMessages[index])
            CDMessages.remove(at: index)
//            print("index: \(index)")
            self.CDSaveData()
        }
//        print("CDMessages \(CDMessages)")
    
//             serialise the message
            let CDNewMessage = CoreDataChatMessages(context: context)
            CDNewMessage.eventID = eventID
            CDNewMessage.fromId = dict.fromId
            CDNewMessage.timestamp = dict.timestamp as! Int64
            CDNewMessage.text = dict.text
            CDNewMessage.fromName = dict.fromName
            CDNewMessage.messageID = messageID
//            print("CDNewMessage.messageID = messageID \(messageID)")
//              save the new message
            CDMessages.append(CDNewMessage)
            self.CDSaveData()
        }
    }, withCancel: nil)
        completion()
}
    
    
//    function for serialising chats
    func serialiseChatMessages(predicate: NSPredicate, usePredicate: Bool) -> [CDMessage]{
        print("running func serialiseChatMessages with usePredicate \(usePredicate)")
        var serialisedChats = [CDMessage]()
        let request : NSFetchRequest<CoreDataChatMessages> = CoreDataChatMessages.fetchRequest()
       
//        if usePredicate set then use the passed in predicate
        if usePredicate == true{
            request.predicate = predicate
        }
        
      let retrievedResults = CDFetchFilteredchatDataFromDB(with: request)
        
        for chat in retrievedResults{
            var n = CDMessage()
            n.eventID = chat.eventID
            n.fromId = chat.fromId
            n.timestamp = chat.timestamp
            n.text = chat.text
            n.fromName = chat.fromName
            n.messageID = chat.messageID
            serialisedChats.append(n)
        }
        return serialisedChats
    }
    
    
    //    function for retrieveing events from DB with any request
        func CDFetchFilteredchatDataFromDB(with request: NSFetchRequest<CoreDataChatMessages> = CoreDataChatMessages.fetchRequest()) -> [CoreDataChatMessages]{
            
            var filteredEventResults = [CoreDataChatMessages]()
            
            do{
                filteredEventResults = try context.fetch(request)
                    print("filteredEventResults - event count: \(filteredEventResults.count)")
                    
                    return filteredEventResults
                    
                } catch{
                    print("error fetching the data from core data \(error)")
                    
                    return filteredEventResults
                }
            }
    
    
    func commitSingleChatDB(fromId: String, text: String, fromName: String, timestamp: Int64, toId: String, eventID: String, messageID: String){
        print("running func commitSingleEventDB fromId: \(fromId), text: \(text), fromName: \(fromName), timestamp: \(timestamp), toId: \(toId), eventID: \(eventID), messageID: \(messageID)")
        
        let CDNewChat = CoreDataChatMessages(context: context)
        CDNewChat.eventID = eventID
        CDNewChat.fromId = fromId
        CDNewChat.timestamp = timestamp
        CDNewChat.text = text
        CDNewChat.fromName = fromName
        CDNewChat.messageID = messageID
        
//                        append the new event onto CDNewChat
        CDMessages.append(CDNewChat)
        self.CDSaveData()
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
        
//            we add the list of events and the type of notification to the user defaults, this is used to populate the notifications tab
    UserDefaults.standard.set(eventIDs, forKey: "eventNotifications")
        
        let dictionary = UserDefaults.standard.object(forKey: "eventNotifications")
        print("CDRetrieveUpdatedEvents dictionary \(dictionary!) dictionary \(dictionary!)")
        
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
                }
//                    remove the event notification from the event notification table
                self.removeSignleEventNotifications(eventID: i.key)
                NotificationCenter.default.post(name: .newDataLoaded, object: nil)
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
                    AutoRespondHelper.nonRespondedEventsAuto()
                    
                    
                    AutoRespondHelper.checkValidityOfCalendareevnt(eventID: i.key)
                    
                  NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                }
                self.removeSignleEventNotifications(eventID: i.key)
            }
            else if notification == "amendAvailability" || notification == "AmendAvailability"{
                            print("amendAvailability - amending event \(i.key)")
//                event has been updated, delete the event from our array of events and repalce it
                            if let index = CDEevents.index(where: {$0.eventID == i.key}){
                                context.delete(CDEevents[index])
                                CDEevents.remove(at: index)
                                print("index: \(index)")
                                self.CDSaveData()
                            }
                            CDRetrieveSinglEventsFB(eventID: i.key){(numberOfDates) in
//                    remove the event notification from the event notification table
//                                upload availability for this specific event
                                AutoRespondHelper.uploadCurrentUsersAvailabilityAuto(eventID: i.key)
                                AutoRespondHelper.checkValidityOfCalendareevnt(eventID: i.key)
                                
                              NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                            }
                            self.removeSignleEventNotifications(eventID: i.key)
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
                        AutoRespondHelper.uploadCurrentUsersAvailabilityAuto(eventID: i.key)
                        NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                    }
                }
//                    remove the event notification from the event notification table
                self.removeSignleEventNotifications(eventID: i.key)
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
                    NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                }
            }
        }
    }
    
    
//    adds, deletes and amends events based on the userEventNotifications table in FireStore - with completion
        func CDRetrieveUpdatedEventsCompletion(eventIDs: [String: Any], completion: @escaping () -> Void){
         
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
                    }
    //                    remove the event notification from the event notification table
                    self.removeSignleEventNotifications(eventID: i.key)
                    NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                    completion()
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
                        AutoRespondHelper.nonRespondedEventsAuto()
                        self.removeSignleEventNotifications(eventID: i.key)
                        NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                        completion()
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
                            AutoRespondHelper.uploadCurrentUsersAvailabilityAuto(eventID: i.key)
    //                    remove the event notification from the event notification table
                        self.removeSignleEventNotifications(eventID: i.key)
                            NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                        completion()
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
                        NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                        completion()
       
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

                    }
//                        remove the notificaiton from the notification table
                    removeSingleAvailabilityNotifications(documentID: i.key)
                    NotificationCenter.default.post(name: .availabilityUpdated, object: nil)
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
                        print("CDRetrieveUpdatedAvailability - CDRetrieveSingleAvailabilityFB: complete")
//                        remove the specific notificaiton for that availability
                        AutoRespondHelper.nonRespondedEventsAuto()
                        NotificationCenter.default.post(name: .availabilityUpdated, object: nil)
                    }
                    self.removeSingleAvailabilityNotifications(documentID: i.key)
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
                        print("CDRetrieveUpdatedAvailability - CDRetrieveSingleAvailabilityFB: complete")
                        NotificationCenter.default.post(name: .availabilityUpdated, object: nil)

                    }
//                        remove the specific notificaiton for that availability
                    self.removeSingleAvailabilityNotifications(documentID: i.key)
                }

            }
        }
    
    
    //    function to retrieve single event from Firebase
    func CDRetrieveSinglEventsFB(eventID: String, completion: @escaping (_ numberOfDates: [Int]) -> Void){

        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
        
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
                        CDNewEvent.eventType = documentEventData!.get("eventType") as? String ?? ""
                        CDNewEvent.startDatesDisplay = self.dateArrayToDisplayDates(dates: documentEventData!.get("startDates") as! [String])
 //                        append the new event onto CDNewEvent
                        print("CDRetrieveSinglEventsFB CDEvent \(CDNewEvent)")
                         CDEevents.append(CDNewEvent)
                        self.CDSaveData()
                        completion([CDNewEvent.startDates!.count])
                    }
//                    print("CDEevents \(CDEevents)")
                    
            }}
        }}
    
    
//    comit a sinlge event into the Database
    
    func commitSingleEventDB(chosenDate: String, chosenDateDay: Int, chosenDateMonth: Int, chosenDatePosition: Int, chosenDateYear: Int, daysOfTheWeek: [Int], endDates: [String], endTimeInput: String, endDateInput: String, eventDescription: String, eventID: String, eventOwner: String, eventOwnerName: String, isAllDay: String, location: String, locationLatitue: Double, locationLongitude: Double, startDates: [String], startDateInput: String, startTimeInput: String, currentUserNames: [String], nonUserNames: [String], users: [String], eventType: String){
        
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
        CDNewEvent.eventType = eventType
        CDNewEvent.startDatesDisplay = self.dateArrayToDisplayDates(dates: startDates)
//                        append the new event onto CDNewEvent
        CDEevents.append(CDNewEvent)
        self.CDSaveData()
    }
    
    
//    function to retrieve all the events from Firebase the user has been invited to, this should only be used if the coredata is currently empty
    func CDRetrieveAllEventsFB(completion: @escaping () -> Void){
        
        print("running func CDRetrieveAllEventsFB with user: \(user ?? "")")
        
        //        we unwrap user, hence we must confirm it is has a value
        if user == nil{
            print("CDRetrieveAllEventsFB: user is equal to nil")
        }
        else{
       dbStore.collection("eventRequests").whereField("users", arrayContains: user!).getDocuments { (querySnapshot, error) in
               if error != nil {
                   print("CDRetrieveAllEventsFB: Error getting documents: \(error!)")
                completion()
               }
               else {
                   
                   if querySnapshot!.isEmpty == true{
                     
       //                the user doesn't have any  event data to retrieve
                       print("CDRetrieveAllEventsFB: no event data to retrieve")
                       completion()
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
                        CDNewEvent.eventType = documentEventData.get("eventType") as? String ?? ""
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
        
//        check if there are any events in the list to retrieve
        if eventIDs.count == 0{
            
            completion()
            
        }
        else{
        
//            loop through each event in the event list
        for n in 0...eventIDs.count - 1{
            
            let currentEventID = eventIDs[n]
            let currentAvailabilty = eventNumberOfDates[n]
            
//            generate not responded array
            let notRespondedArray = noResultArrayCompletion2(numberOfDatesInArray: currentAvailabilty).noResultsArray
            
//            retrieve all user responses for the event in the user event store
           dbStore.collection("userEventStore").whereField("eventID", isEqualTo: currentEventID).getDocuments { (querySnapshot, error) in
                   if error != nil {
                       print("Error getting documents: \(error!)")
                    completion()
                   }
                   else {
                       if querySnapshot!.isEmpty == true{
           //                the user doesn't have any  event data to retrieve
                           print("no availability data to retrieve")
                        completion()
                       }
                       else{
//                        loop through each response for the event
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
                            CDNewAvailability.userAvailability = documentEventData.get("userAvailability") as? [Int] ?? [99]
                            CDNewAvailability.responded = documentEventData.get("responded") as? String ?? "nr"

    //                        append the new event onto CDAvailability
                            CDAvailability.append(CDNewAvailability)
//                            print("CDNewAvailability \(CDNewAvailability)")
                            self.CDSaveData()
                        }
                        completion()
                    }}}}
        }}
    
//    commit a single Availability into CoreData
    func commitSinlgeAvailabilityToCD(documentID: String, eventID: String, uid: String, userName: String, userAvailability: [Int], responded: String){
        
        print("running func commitSinlgeAvailabilityToCD wiht inputs - documentID: \(documentID) eventID: \(eventID), uid: \(uid), userName: \(userName), userAvailability \(userAvailability) responded \(responded)")
        
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
        CDNewAvailability.responded = responded

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
                        CDNewAvailability.responded = querySnapshot!.get("responded") as? String ?? "nr"
                            CDAvailability.append(CDNewAvailability)
                        self.CDSaveData()
                        print("CDRetrieveSingleAvailabilityFB - update complete")
                        completion()
                        
                        }}}
            
        }
    
    
    
//    function to fetch event from core data
    func CDFetchEventDataFromDB() -> Bool{
        let request : NSFetchRequest<CoreDataEvent> = CoreDataEvent.fetchRequest()
        
        do{
        CDEevents = try context.fetch(request)
            print("CDFetchEventData - event count: \(CDEevents.count)")
            
            return true
            
        } catch{
            print("CDFetchEventDataFromDB error fetching the data from core data \(error)")
            
            return false
        }
    }
    
    
    //    function to fetch the chats from core data
    func CDFetchChatDataFromDB() -> Bool{
        let request : NSFetchRequest<CoreDataChatMessages> = CoreDataChatMessages.fetchRequest()
        
        do{
        CDMessages = try context.fetch(request)
            print("CDFetchChatDataFromDB - event count: \(CDMessages.count)")
            
            return true
            
        } catch{
            print("CDFetchChatDataFromDB error fetching the data from core data \(error)")
            
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
            NotificationCenter.default.post(name: .newDataLoaded, object: nil)
        }
        catch{
            print("error saving data to core data with error \(error)")
        }
        
    }
    
    
func removeTheEventNotifications(){
        
        print("running func - removeTheEventNotifications")
    
    if user == nil{
    }
    else{
        
        dbStore.collection("userEventUpdates").document(user!).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }}
    }
    

// function to remove a single event from the notification tbale
    func removeSignleEventNotifications(eventID: String){
        
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
    
    
// delete all the availability notifications for that user
func removeTheAvailabilityNotifications(){
        
        print("running func - removeTheAvailabilityNotifications")
    
    if user == nil{
    }
    else{
    
        dbStore.collection("userAvailabilityUpdates").document(user!).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }}
        }
    }
    
    
    func removeSingleAvailabilityNotifications(documentID: String){
        
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
                print(" CDFetchFilteredAvailabilityDataFromDB - filteredAvailabilityResults - availability count: \(filteredAvailabilityResults.count)")
                
                return filteredAvailabilityResults
                
            } catch{
                print("error fetching the data from core data \(error)")
                
                return filteredAvailabilityResults
            }
        }
    
    //    function for retrieveing availability from DB with any request
    func CDFetchFilteredChatDataFromDB(with request: NSFetchRequest<CoreDataChatMessages> = CoreDataChatMessages.fetchRequest()) -> [CoreDataChatMessages]{
        
        var filteredAvailabilityResults = [CoreDataChatMessages]()
        
        do{
            filteredAvailabilityResults = try context.fetch(request)
                print(" CDFetchFilteredChatDataFromDB - filteredChatResults - availability count: \(filteredAvailabilityResults.count)")
                
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
//            print("CDNewEvent \(CDNewEvent)")
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
            n.eventType = CDNewEvent.eventType ?? ""
            
//            adding the final date in the search array
            let lastDate = n.endDateArray.last!
            let lateDateYYYMMDD = lastDate[0...9]
            let finalSearchDate = dateFormatterSimple.date(from: String(lateDateYYYMMDD))
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
            nextAvailability.responded = i.responded ?? "nr"
//            print("nextAvailability \(nextAvailability)")
            serialisedAvailability.append(nextAvailability)
        }
        return serialisedAvailability
    }
    
    //    fetch availability for a specific event and serialise the data
    func serialiseAvailabilitywUser(eventID: String, userID: String) -> [AvailabilityStruct]{
         print("running func serialiseAvailability inputs - eventID \(eventID)")
            var filteredAvailability = [CoreDataAvailability]()
            var serialisedAvailability = [AvailabilityStruct]()
        
            let request : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
            request.predicate = NSPredicate(format: "eventID == %@ AND uid == %@", eventID, userID)
            filteredAvailability = CDFetchFilteredAvailabilityDataFromDB(with: request)
            
            for i in filteredAvailability{
                var nextAvailability = AvailabilityStruct()
                nextAvailability.documentID = i.documentID ?? ""
                nextAvailability.eventID = i.eventID ?? ""
                nextAvailability.uid = i.uid ?? ""
                nextAvailability.userAvailability = i.userAvailability ?? [99]
                nextAvailability.userName = i.userName ?? ""
                nextAvailability.calendarEventID = i.calendarEventID ?? ""
                nextAvailability.responded = i.responded ?? "nr"
    //            print("nextAvailability \(nextAvailability)")
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
        
        
        let dateFormatterTz = DateFormatter()
        dateFormatterTz.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTz.locale = Locale(identifier: "en_US_POSIX")
        
        
        print("running func getEventsFromCD inputs - pending: \(pending) createdByUser \(createdByUser) pastEvents: \(pastEvents)")
        
//        date for comparison to determine whether the event is occuring today.
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        let newDate = date.addingTimeInterval(TimeInterval(secondsFromGMT))
        let dateComponents = DateComponents(year: Calendar.current.component(.year, from: newDate), month: Calendar.current.component(.month, from: newDate), day: Calendar.current.component(.day, from: newDate), hour: 0, minute: 0, second: 0)
        let dateFromComponents = calendar.date(from: dateComponents)!.addingTimeInterval(TimeInterval(secondsFromGMT))
               
        if createdByUser == true && pending == true && pastEvents == false{
            let events = serialisedEvents.filter(){ $0.eventOwnerID == user! && $0.chosenDate == "" && $0.finalSearchDate > dateFromComponents}
//                print("events \(events)")
            return events
        }
        else if createdByUser == false && pending == true && pastEvents == false{
                let events = serialisedEvents.filter(){ $0.eventOwnerID != user! && $0.chosenDate == "" && $0.finalSearchDate > dateFromComponents}
//            print("events \(events)")
            return events
        }
        else if createdByUser == false && pending == true && pastEvents == true{
                    let events = serialisedEvents.filter(){ $0.eventOwnerID != user! && $0.chosenDate == "" && $0.finalSearchDate < dateFromComponents}
//                print("events \(events)")
            return events
            }
        else if createdByUser == true && pending == true && pastEvents == true{
                    let events = serialisedEvents.filter(){ $0.eventOwnerID == user! && $0.chosenDate == "" && $0.finalSearchDate < dateFromComponents}
//                print("events \(events)")
            return events
            }
        else if createdByUser == true && pending == false && pastEvents == false{
            let events = serialisedEvents.filter(){ $0.eventOwnerID == user! && $0.chosenDate != "" && dateFormatterTz.date(from:$0.startDateArray[$0.chosenDatePosition])! > dateFromComponents}
//            print("events \(events)")
            return events
        }
        else if createdByUser == false && pending == false && pastEvents == false{
                let events = serialisedEvents.filter(){ $0.eventOwnerID != user! && $0.chosenDate != "" && dateFormatterTz.date(from:$0.startDateArray[$0.chosenDatePosition])! > dateFromComponents}
//            print("events \(events)")
            return events
        }
        else if createdByUser == false && pending == false && pastEvents == true{
                let events = serialisedEvents.filter(){ $0.eventOwnerID != user! && $0.chosenDate != "" && dateFormatterTz.date(from:$0.startDateArray[$0.chosenDatePosition])! < dateFromComponents}
//            print("events \(events)")
            return events
        }
        else if createdByUser == true && pending == false && pastEvents == true{
                    let events = serialisedEvents.filter(){ $0.eventOwnerID == user! && $0.chosenDate != "" && dateFormatterTz.date(from:$0.startDateArray[$0.chosenDatePosition])! < dateFromComponents}
//                print("events \(events)")
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
    func eventAmendedNotification(userIDs: [String], eventID: String, amendWithAvailability: Bool){
        print("running func eventAmendedNotification inputs - userIDs: \(userIDs) eventID \(eventID) amendWithAvailability \(amendWithAvailability)")
        
        var textToSend = String()
        
//        we set to amendAvailability so that on retrieval the user also responds with their availability
        if amendWithAvailability == true{
            textToSend = "amendAvailability"
//            first we loop through and delete each users availability responses
            let availability = serialiseAvailability(eventID: eventID)
            for i in availability{
                print("eventAmendedNotification - delete availability update - user \(i.userName) i.documentID \(i.documentID)")
                let documentID = i.documentID
                dbStore.collection("userEventStore").document(documentID).updateData(["userAvailability" : FieldValue.delete(), "userResponded" : "false"])
            }
            
//            we post a notification to each user to delete each others user availability
//            fetch the availability for all users
            for i in userIDs{
                let userID = i
//                loop through each availability within the event and tell each user to delete it
                for y in availability{
                    print("eventAmendedNotification - post amend  - user \(userID) availabilityUser \(y.userName)")
                    let documentID = y.documentID
                    dbStore.collection("userAvailabilityUpdates").document(userID).setData([documentID: "Amend"], merge: true)
                }
            }
        }
        else{
          textToSend = "amend"
        }
        
          print("running func eventAmendedNotification- adding notificaitons to userEventUpdates - inputs - userIDs \(userIDs)")
            
            for i in userIDs{
           
//            add the eventID and an updated notification to the userEventUpdates tbales
                dbStore.collection("userEventUpdates").document(i).setData([eventID: textToSend], merge: true)
                
//                if this is the user updating the event, we don't want to update update their notifications
                
//                if i != user!{

//                                update the realtime DB with the new event notification information
                dbStore.collection("userNotification").document(i).setData(["eventNotificationPending" : true], merge: true)
                
//                we also need to add the eventID to the array for notifications
                dbStore.collection("userNotification").document(i).setData(["eventNotificationiDs" : [eventID]], merge: true)
                
//                }
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
          print("running func availabilityAmendedNotification- adding notificaitons to userAvailabilityUpdates - inputs - userIDs \(userIDs) availabilityString \(availabilityDocumentID)")
            
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
    
    
    //    notification function for new availability
            func deleteRemoveUserAvailabilityNotification(userID: String){
              print("running func deleteRemoveUserAvailabilityNotification - userID \(userID)")
                
//                get all availability for the event
                let allAvailability = currentUserSelectedAvailability
                
                for i in allAvailability{
        //            add the eventID and an updated notification to the userEventUpdates tbales
                    dbStore.collection("userAvailabilityUpdates").document(userID).setData([i.documentID: "Delete"], merge: true)
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
            
            if user == nil{
             print("eventChangeListener userID = nil")
            }
            else{
        
        print("engaging eventChangeListener")
           eventListenerRegistration = dbStore.collection("userEventUpdates").document(user!).addSnapshotListener(){ querySnapshot, error in
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
                        
                    }}}}
        }}
    
    
    //    check for availability with updated flags in the userEventsUpdate table
    func availabilityChangeListener(){
        
        if availabilityListenerEngaged == true{
            print("availabilityChangeListener already engaged, not re-engaging")
                   
               }
               else{
                availabilityListenerEngaged = true
        
        print("engaging availabilityChangeListener")
            
            if user == nil{
                print("availabilityChangeListener userID = nil")
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
                            
//                            let dictionary = UserDefaults.standard.object(forKey: "eventNotifications")
//                            print("CDRetrieveUpdatedEvents dictionary \(dictionary!) dictionary \(dictionary!)")
                        
                        self.CDRetrieveUpdatedAvailability(availabilityID: documentData)
                        
                        }}}}}

        }}
    
    
//    MARK: Misc functions
    func uploadCurrentUsersAvailability(eventID: String){
        print("running func uploadCurrentUsersAvailability inputs - eventID: \(eventID)")
//        if we don't have access to the calendar we stop
        if checkCalendarStatus2() == false{
               print("uploadCurrentUsersAvailability - checkCalendarStatusAuto = false")
           }
        else{
        
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
            if filteredAvailabilityData.count == 0{
                print("something went wrong")
            }
            else{
        let documentID = filteredAvailabilityData[0].documentID
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

        let endDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).endDatesOfTheEvents
        let startDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).startDatesOfTheEvents

        let finalAvailabilityArray2 = self.compareTheEventTimmings3(datesBetweenChosenDatesStart: eventData.startDateArray, datesBetweenChosenDatesEnd: eventData.endDateArray, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents)
        print("uploadCurrentUsersAvailability finalAvailabilityArray2: \(finalAvailabilityArray2)")

//                        add the finalAvailabilityArray to the userEventStore

        commitUserAvailbilityData(userEventStoreID: documentID, finalAvailabilityArray2: finalAvailabilityArray2, eventID: eventID)
                }}}}
    }
    
    
//    function to location events we haven't responded to and respond, this should run each time we open the app and maybe when we open the events page
    func nonRespondedEvents(){
//        find events where the availability for our user ID = [99]
        print("running func nonRespondedEvents")
        
        if user == nil{
        }
        else{
        let request : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@ && (userAvailability == %@ || userAvailability == %@)", argumentArray:[user ?? "", [99], []])
        let filteredAvailability = CDFetchFilteredAvailabilityDataFromDB(with: request)
        print("nonRespondedEvents filteredAvailability \(filteredAvailability)")
            
//            adding a catch in case nothing is returned from the request
            if filteredAvailability.count == 0{
                
            }
            else{
//            filter through each empty availability and respond
            for i in filteredAvailability{
                AutoRespondHelper.uploadCurrentUsersAvailabilityAuto(eventID: i.eventID!)
            }
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
            
            self.addEventToCalendar(title: eventData.eventDescription, description: eventData.eventDescription, startDate: eventData.startDateArray[chosenDatePosition], endDate: eventData.endDateArray[chosenDatePosition], location: eventData.eventLocation, eventOwner: eventData.eventOwnerName, startDateDisplay: eventData.startDatesDisplay[chosenDatePosition], eventOwnerID: eventData.eventOwnerID, locationLongitude: eventData.locationLongitude, locationLatitude: eventData.locationLatitue, userEventStoreID: availabilityData.documentID!, calendarEventIDInput: calendarEventIDInput){_,_ in 
                
            }
        }}
    
    
//    save an item to the availability CD
    func saveItemAvailabilty(userEventStoreID: String, key: String, value: Any){
        print("saveItemAvailabilty inputs: userEventStoreID: \(userEventStoreID) key: \(key) value: \(value)")
        
     let request : NSFetchRequest<CoreDataAvailability> = CoreDataAvailability.fetchRequest()
            request.predicate = NSPredicate(format: "documentID == %@", argumentArray:[userEventStoreID])
    let filteredAvailability = CDFetchFilteredAvailabilityDataFromDB(with: request)
        
        if filteredAvailability.count == 0 {
            print("saveItemAvailabilty - something went wrong")
        }
        else{
            let availabilityToUpdate = filteredAvailability[0]
            print("saveItemAvailabilty - availabilityToUpdate \(availabilityToUpdate)")
            
//            we set the current values of the availability to temporary variables for use later
            let documentID = availabilityToUpdate.documentID
            let eventID = availabilityToUpdate.eventID
            let uid = availabilityToUpdate.uid
            let userName = availabilityToUpdate.userName
            let userAvailability = availabilityToUpdate.userAvailability

        
//                            before we commit anything to the DB we should check if it alredy exists and remove it if it does
                if let index = CDAvailability.index(where: {$0.documentID == userEventStoreID}){
                                                            context.delete(CDAvailability[index])
                                                            CDAvailability.remove(at: index)
                                                            print("index: \(index)")
                                        self.CDSaveData()
            }
                                    
            let CDNewAvailability = CoreDataAvailability(context: context)
                                    
            CDNewAvailability.documentID = documentID
            CDNewAvailability.eventID = eventID
            CDNewAvailability.uid = uid
            CDNewAvailability.userName = userName
            CDNewAvailability.userAvailability = userAvailability
            CDNewAvailability.calendarEventID = value as? String

//                        append the new event onto CDAvailability
            CDAvailability.append(CDNewAvailability)
            print("saveItemAvailabilty - CDNewAvailability \(CDNewAvailability)")
                                    self.CDSaveData()
        }

    }
    
//    function to handle any errors with the data for an event.
//    this function takes in an eventID and eventInfo or availabilityBool and deletes either all the event data or availability data, to then download it again from the sever
    func somethingWentWrong(eventID: String, eventInfo: Bool, availabilityInfo: Bool, loginfo: String, viewController: UIViewController){
        print("running func somethingWentWrong")
        Crashlytics.crashlytics().log("running func somethingWentWrong")
        Crashlytics.crashlytics().log("running func somethingWentWrong - logs sent to func - loginfo \(loginfo)")
        
//        1. show the user a notification tell them there was an issue
        let utils = Utils()
        let button1 = AlertButton(title: "Ok", action: {
//            send the user back to the homepage
            let sampleStoryBoard : UIStoryboard = UIStoryboard(name: "NL_HomePage", bundle:nil)
            let homeView  = sampleStoryBoard.instantiateViewController(withIdentifier: "NL_HomePage") as! NL_HomePage
            self.navigationController?.pushViewController(homeView, animated: true)
            
            }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected)
        
        let alertPayload = AlertPayload(title: "Something Went Wrong!", titleColor: UIColor.red, message: "Oops, something went wrong, please try again later, we are working to fix it!", messageColor: MyVariables.colourPlanrGreen, buttons: [button1], backgroundColor: UIColor.clear, inputTextHidden: true)
        
        if self.presentedViewController == nil {
            utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true)
        }
        else {
            self.dismiss(animated: false, completion: nil)
            utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true)
        }
        
        
//        trigger to set the funtion to delete any current data for the event and then download the new data
        if eventInfo == true{
            
        }
        if availabilityInfo == true{
   
        }
    }
    
//    this function runs everytime the user opens the app, it checks that the data in our database appears consistent, if not corrective measures are preformed. This runs as part of the homepage opening and should be run last after all the data has been loaded into CoreData checks are as follows:
//    1. A list of key attributes that can't be missing from our database
//    2. does each event in our database have the correct number of userAvailability checks, if they are not equal delete and start again (need to ensure we don't get stuck in an infinitie loop, if there is an issue in the datbase)
    func dataConsistencyCheck(){
        print("running func dataConsistencyCheck")
        
        var userAvailabilityForTesting = [AvailabilityStruct]()
        
//        1. check key attributes
//        1.1 arrays that should be equal
        
        
//        2. check availability validity
//        2.1 itterate through the list of events to check the number of invitees
        for event in CDEevents{
            
//            count the number of invitees
//            print("event \(event)")
            let inviteeCount = event.currentUserNames!.count
//            retrieve each availability
            userAvailabilityForTesting = serialiseAvailability(eventID: event.eventID!)
            

            let availabilityInviteeCount = userAvailabilityForTesting.count
            
            if inviteeCount != availabilityInviteeCount{
                print("the number of invitees and the number of availabilities are not equal \(event.eventID ?? "") inviteeCount: \(inviteeCount) availabilityInviteeCount: \(availabilityInviteeCount)")
                
//                2.11 check the event still exists, if not delete it from our database and all its availability data
                dbStore.collection("eventRequests").document(event.eventID!).getDocument{ (documentEventData, error) in
                        if error != nil {
                            print("dataConsistencyCheck - Error getting documents: \(error!)")
                        }
                        else {
                            if documentEventData!.exists == false{
//                the event doesn't appear to exist in the database, we need to remove it from CoreData
                                print("dataConsistencyCheck - event no longer in FB")
//                                delete the event
                                if let index = CDEevents.index(where: {$0.eventID == event.eventID!}){
                                    context.delete(CDEevents[index])
                                    CDEevents.remove(at: index)
                                    print("index: \(index)")
                                    self.CDSaveData()
                                }
//                                delete all availability
                                self.deleteCDAvailability(eventID: event.eventID!){
                                 print("dataConsistencyCheck - event no longer in FB - deleted")
                                }
                            }
                            else{
//                2.12 if the event does exist in the database, retreive the correct event data
//                  we need to perform a number of checks to ensure the data appears correct
                                print("the event does exist in the database")
//                                delete all the records in the availability database
                                                                
                                self.deleteCDAvailability(eventID: event.eventID!){
                                                                
                                self.CDRetrieveAllAvailabilityFB(eventIDs: [event.eventID!], eventNumberOfDates: [event.startDates!.count]){
                            print("issue event now corrected: \(event.eventID ?? "")")
                                                        }}
//                  1. does the number of users in our event match those of the event online event, if not we delete our event from coreData and populate from FB
                                let currentNameFB = documentEventData?.get("currentUserNames") as? [String]
                                let currentNameCountFB = currentNameFB?.count
                                
                                if currentNameCountFB != inviteeCount{
                                    print("the number of users in our CD event doesnt match those of the FB event - deleting event and reloading")
                                   
                                    let eventID = event.eventID!
                                    
                                    self.deleteCDevent(eventID: eventID){
                                        self.CDRetrieveSinglEventsFB(eventID: eventID){_ in
                                        
                                            print("event deleted and reloaded \(eventID)")
                                        }}
                                }}
                    }}
            }
            else{
                print("no issues with availability versus event invitee count \(event.eventID ?? "")")
            }
            
        }
//        end of the event for loop
    }
    
//    fucntion to check if there are any duplicate events or availabilities, this must be complete before we run other consistency check
    func duplicationChecks(completion: @escaping () -> Void){
        
//        3. check for duplicate data in the database
        //        3.1 check if there are two events with the same eventID, the eventID is unique and there should only be one
                for event in CDEevents{
                    print("duplicationChecks - looping through events")
        //            get all the events with the same eventID as the one we are currently looping through
                    let filteredEvents = CDEevents.filter({$0.eventID == event.eventID})
//                    print("dataConsistencyCheck 3.1 - filteredEvents \(filteredEvents)")
        //            check if there is more than one event returned
                    if filteredEvents.count > 1{
                        print("dataConsistencyCheck - there was a duplicate event - we are deleting it")
        //              delete the duplicate
                        if let index = CDEevents.index(where: {$0.eventID == event.eventID!}){
                            context.delete(CDEevents[index])
                            CDEevents.remove(at: index)
                            print("index: \(index)")
                            self.CDSaveData()
                        }
                    }
        
                }
        //        end of event for loop
        //        3.2 check if there are any duplicate availabilities in the database
        
                for availability in CDAvailability{
                    print("duplicationChecks - looping through availability")
        //            get all the events with the same eventID as the one we are currently looping through
                    let filteredAvailability = CDAvailability.filter({$0.documentID == availability.documentID})
        //            check if there is more than one event returned
                if filteredAvailability.count > 1{
                    print("dataConsistencyCheck - there was a duplicate availability - we are deleting it")
        //              delete the duplicate
                    if let index = CDAvailability.index(where: {$0.documentID == availability.documentID}){
                            context.delete(CDAvailability[index])
                            CDAvailability.remove(at: index)
                            print("index: \(index)")
                            self.CDSaveData()
                            }
                    }
                }
        completion()
    }
    
    
    
//    deletes all entried in CoreData, this is used when the user logs out to ensure we don't carry over data we shouldn't, inputs should be the name of the entity in core data i.e. CoreDataAvailability and CoreDataEvent
    func deleteAllRecords(entityName: String) {
        
        print("running fun deleteAllRecords inputs - entityName: \(entityName)")
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
        
    
//    delete all availability for a specific event
    func deleteCDAvailability(eventID: String, completion: @escaping () -> Void){
       
        var deleteUserAvailabilityForTesting = [AvailabilityStruct]()
        
        deleteUserAvailabilityForTesting = serialiseAvailability(eventID: eventID)
        
//                                delete all the records in the availability database
        for i in deleteUserAvailabilityForTesting{
            print("removing availability i: \(i)")
            if let index = CDAvailability.index(where: {$0.documentID == i.documentID}){
                context.delete(CDAvailability[index])
                CDAvailability.remove(at: index)
                print("index: \(index)")
                self.CDSaveData()
            }
            }
        completion()
    }
    
//    delete event from CD
    
    func  deleteCDevent(eventID: String, completion: @escaping () -> Void){
        
        if let index = CDEevents.index(where: {$0.eventID == eventID}){
            context.delete(CDEevents[index])
            CDEevents.remove(at: index)
            print("index: \(index)")
            self.CDSaveData()
        }
        completion()
    }
    
//    function to retrieve the image
    func fetchImage(uid: String) -> [CoreDataUser] {
        print("running func fetchImage inputs: uid \(uid)")
    var fetchingImage = [CoreDataUser]()
        
        let fetchRequest : NSFetchRequest<CoreDataUser> = CoreDataUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uid == %@", uid)
    do {
    fetchingImage = try context.fetch(fetchRequest)
//        print("funcfetchImage - fetchingImage \(fetchingImage)")
//cehck if we found an image
        if fetchingImage.count == 0{
            print("we didnt find the users image, we will try and get it from Firebase")
        //        we didnt find the image, so lets see if there is anything to pull from firebase
                fetchUsersProfileImage(uid: uid){
        //            try to fetch the image again
                    let fetchRequest : NSFetchRequest<CoreDataUser> = CoreDataUser.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "uid == %@", uid)
                do {
                fetchingImage = try context.fetch(fetchRequest)
                } catch {
                print("Error while fetching the image")
                }
           
                }}
        
    } catch {
    print("Error while fetching the image")

    }
    return fetchingImage
    }
    
    
    }

//set notification names
extension Notification.Name {
     static let newDataLoaded = Notification.Name("newDataLoaded")
    static let newChatDataLoaded = Notification.Name("newChatDataLoaded")
    static let chatNotificationTapped = Notification.Name("chatNotificationTapped")
    static let editEventUsersChosen = Notification.Name("editEventUsersChosen")
    static let userPhotoUploaded = Notification.Name("userPhotoUploaded")
}



