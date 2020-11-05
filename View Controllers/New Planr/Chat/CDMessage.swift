//
//  CDMessage.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 9/15/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import Foundation


struct CDMessage: Equatable {
    var fromId: String?
    var text: String?
    var fromName: String?
    var timestamp: Int64?
    var toId: String?
    var eventID: String?
    var messageID: String?
}
