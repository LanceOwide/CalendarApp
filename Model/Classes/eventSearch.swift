//
//  eventSearch.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 22/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import Foundation

struct eventSearch {
    
    var eventID: String = ""
    var eventDescription: String = ""
    var eventLocation: String = ""
    var eventEndTime: String = ""
    var eventStartTime: String = ""
    var eventStartDate: String = ""
    var eventEndDate: String = ""
    var timeStamp: Float = 0.0
    var eventOwnerID: String = ""
    var eventOwnerName: String = ""
    var chosenDate: String = ""
    var startDateArray: [String] = []
    var inviteeNamesArray: [String] = []
    var newChatMessage = Bool()
}
