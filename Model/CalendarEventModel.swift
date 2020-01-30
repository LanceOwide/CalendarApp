//
//  CalendarEventModel.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 09/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import EventKit

class Event {
    
    var title: String? = ""
    var location: String = ""
    var calendar:[EKCalendar]?
    var alarms: [EKAlarm]?
    var URL: URL?
    var lastModified: Date?
    var startDate: Date?
    var endDate: Date?
    var allDay: Bool = false
    var floating: String = ""
    var recurrence: [EKRecurrenceRule]?
    var attendees: [EKParticipant]?
    var timezone: TimeZone?
    var availability: EKEventAvailability?
    var occuranceDate: Date?
    

}
