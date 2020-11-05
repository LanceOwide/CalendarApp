//
//  Message.swift
//  calendarApp
//
//  Created by Lance Owide on 06/01/2020.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Message: NSObject {

    var fromId: String?
    var text: String?
    var fromName: String?
    var timestamp: NSNumber?
    var toId: String?
    var messageID: String?
    
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.fromName = dictionary["fromName"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.messageID = dictionary["messageID"] as? String
    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
}

