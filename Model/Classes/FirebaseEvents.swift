//
//  FirebaseEvents.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 11/3/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import Foundation


//Analytics.logEvent(firebaseEvents., parameters: ["Test": ""])


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
    static var createEventClosed = "createEventClosed"
    
    
    
//    settings tracking
    static var settingsLogOff = "settingsLogOff"
    
    
//    events tracking
    static var eventEditAvailability = "eventEditAvailability"
    static var eventEditAvailabilityPressed = "eventEditAvailabilityPressed"
    static var eventEdit = "eventEdit"
    static var eventSendReminder = "eventSendReminder"
    static var autoRespondwNotification = "autoRespondwNotification"
    static var remoteNotificationRecieved = "remoteNotificationRecieved"
    static var closedEventPage = "closedEventPage"
    static var eventNotGoingTapped = "eventNotAttendingTapped"
    static var eventGoingTapped = "eventAttendingTapped"
    static var eventDeleted = "eventDeleted"
    static var eventDeletePressed = "eventDeleted"
    
    
//    issue tracking
    static var errorUpdatingPhoneNumber = "errorUpdatingPhoneNumber"
    
//    added to the calendar
    static var eventCalendarButtonPressed = "eventCalendarButtonPressed"
    static var eventCalendarButtonPressedEventNotInCalendar = "eventCalendarButtonPressedEventNotInCalendar"
    static var eventAddedToCalendar = "eventAddedToCalendar"
    static var eventUpdatedInCalendar = "eventUpdatedInCalendar"
    static var eventAddRejectedCalendar = "eventAddRejectedCalendar"
    static var eventUpdateRejectedCalendar = "eventAddRejectedCalendar"
    
    
// user invited new users to the app
    static var inviteFriendsPressed = "inviteFriendsPressed"
    static var eventSendInvite = "inviteFriendsSent"
    
    
//    access to phone
    static var accessToCalendarDenied = "accessToCalendarDenied"
    static var accessToCalendarGranted = "accessToCalendarGranted"
    
    static var accessToContactsDenied = "accessToContactsDenied"
    static var accessToContactsGranted = "accessToContactsGranted"
    static var accessToContactsDeniedShown = "accessToContactsDeniedShown"
    static var accessToContactsDeniedSettingURLClicked = "accessToContactsDeniedSettingURLClicked"
    
    static var accessToLocationDenied = "accessToLocationDenied"
    static var accessToLocationGranted = "accessToLocationGranted"
    
    static var accessToNotificationsDenied = "accessToNotificationsDenied"
    static var accessToNotificationsGranted = "accessToNotificationsGranted"
    
    
    
}
