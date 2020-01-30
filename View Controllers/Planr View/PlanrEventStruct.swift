
//
//  eventSearch.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 22/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import Foundation

struct PlanrEventStruct: Equatable {
    
    var eventID: String = ""
    var eventDescription: String = ""
    var eventLocation: String = ""
    var eventEndTime: String = ""
    var eventStartTime: String = ""
    var timeStamp: Float = 0.0
    var eventOwnerID: String = ""
    var eventOwnerName: String = ""
    var chosenDate: String = ""
    var startDateArray: [String] = []
    var inviteeNamesArray: [String] = []
    var chosenDatePosition = Int()
    var startDates = [String()]
    var endDates = [String()]
    var chosenDay = Int()
    var hoursFromGMT = Int()
}
