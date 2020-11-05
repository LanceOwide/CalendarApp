//
//  FirebaseEvents.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 11/3/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import Foundation


//Analytics.logEvent(firebaseEvents., parameters: ["user": user])


struct firebaseEvents{
    
//    main events for the app
    static var eventCreated = "eventCreated"
    static var chatSent = "chatSent"
    static var homePageTogglePressed = "homePageTogglePressed"
    
    
//    some events for when the user is creating an event to tell us they got something wrong and where they are going wrong
    static var createEventTitleMissing = "createEventTitleMissing"
    static var createEventLocationMissing = "createEventLocationMissing"
    static var createEventStartTimeMissing = "createEventStartTimeMissing"
    static var createEventEndTimeMissing = "createEventEndTimeMissing"
    static var createEventEndBeforeStartTime = "createEventEndBeforeStartTime"
    static var createEventNoDatesSelected = "createEventNoDatesSelected"
    
    
    
//    settings tracking
    static var settingsLogOff = "settingsLogOff"
    
    
//    events tracking
    static var eventEditAvailability = "eventEditAvailability"
    static var eventEdit = "eventEdit"
    static var eventSendReminder = "eventSendReminder"
    static var eventSendInvite = "eventSendInvite"
    static var autoRespondwNotification = "autoRespondwNotification"
    static var remoteNotificationRecieved = "remoteNotificationRecieved"
    
    
}
