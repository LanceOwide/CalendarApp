//
//  ContactList.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 28/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import Foundation
import ContactsUI


struct contactList {
    var name: String = ""
    var phoneNumber: String = ""
    var selectedContact: Bool = false
    var phoneNumberList = [CNLabeledValue<CNPhoneNumber>]()
    var userID = String()
    var planrName = String()
    var validatedANumber = Bool()
}
