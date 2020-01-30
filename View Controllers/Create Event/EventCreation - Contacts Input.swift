//
//  EventCreation - Contacts Input.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 22/07/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import DLRadioButton
import MBProgressHUD
import Firebase
import Alamofire


var currentLocale = NSLocale.current.regionCode
var selectedContacts: [String] = [""]
var eventCreationID = String()
var nonExistingUsers = [String]()
var nonExistingNumbers = [String]()

class EventCreation___Contacts_Input: UIViewController, UITableViewDataSource, UITableViewDelegate, CellSubclassDelegate2 {


//    variable to describe the time, in seconds, from GMT of the user
    var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
    
//    other variables
    var userIDArray = Array<String>()
    var fireStoreRef: DocumentReference? = nil
    var myAddedUserName = String()
    var userNameArray = Array<String>()
    var myAddedUserID = String()
    
    
    @IBOutlet weak var invitedFriendsTableView: UITableView!
    
    
    @IBAction func createEventButton(_ sender: Any) {
        
//        validation to ensure sure the user has added some contacts
        if contactsSelected.count == 0 {
            
            showProgressHUD(notificationMessage: "Please select contacts to invite to your event", imageName: "Unavailable", delay: 2)


    }
        else{
            
//            performSegue(withIdentifier: "eventCreatedSegue", sender: Any.self)
            
            performSegue(withIdentifier: "eventSummarySegue", sender: Any.self)
        
        }}
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Invitees"
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
//        allows this view controller to present alerts
//        definesPresentationContext = true
        
        //        set the background colour
        self.view.backgroundColor = UIColor(red: 253, green: 253, blue: 253)
        
        invitedFriendsTableView.dataSource = self
        invitedFriendsTableView.delegate = self
        
        self.invitedFriendsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none

        invitedFriendsTableView.rowHeight = 60
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(doneSelected))
    
}


//    Segue to the summary view page
@objc func doneSelected(){
    
    
    performSegue(withIdentifier: "selectFriendsSegue", sender: self)
    
    
  
}
    
//    the user selected the delete button in the tableview
    @objc func deleteButtonPressed2(indexPath: IndexPath){
        print("delete button pressed")
    }
    
func buttonTapped2(cell: CollectionViewCellAddFriends) {
    guard let indexPath = self.invitedFriendsTableView.indexPath(for: cell) else {
        print("something went wrong when selecting to remove a user")
        // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
        return
    }
    
//    do what we need to with the information
    
    print("user selected section: \(indexPath.section)")
    
    //    DEVELOPMENT - how do we remove the removed user from the sorted contactcs list
    let index = contactsSorted.index(where: { $0.name == contactsSelected[indexPath.section].name})!

    contactsSorted[index].selectedContact = false
    
    
    contactsSelected.remove(at: indexPath.section)
    invitedFriendsTableView.reloadData()
        
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        
//        reloads the tableview once the user has finished choosing the invitees
        invitedFriendsTableView.reloadData()
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        
        if contactsSelected.count == 0{
            
            return 1
        }
        else{
            return contactsSelected.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
    return 1
  
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = invitedFriendsTableView.dequeueReusableCell(withIdentifier: "selectedContactCell", for: indexPath) as? CollectionViewCellAddFriends
                else{
                    fatalError("failed to create user created events cell")
            }
        
        
        
        if contactsSelected.count == 0{
            
            cell.addFriendsLabel.text = "Select friends using the 'Add' button above"
            cell.deleteUserButton.isHidden = true
            
            
            
        }
        else{
            let item = contactsSelected[indexPath.section]
            cell.addFriendsLabel.text = item.name
            cell.deleteUserButton.isHidden = false
            cell.backgroundColor = UIColor.white
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1
            cell.clipsToBounds = true
        }
        
        cell.addFriendsLabel.adjustsFontSizeToFitWidth = true
        cell.delegate = self
        
        return cell
    }
    
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cellSpacingHeight: CGFloat = 10
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "selectFriendsSegue"{
            
           selectedContacts.removeAll()
            
        }
    }
    
    
    
    //    MARK: code to add an event to the Firebase database
    

//    get the phone numbers of the users selected for the event
    func getSelectedContactsPhoneNumbers( completion: @escaping () -> Void){
        selectedContacts.removeAll()
        
        getCurrentUsersPhoneNumber {
            
            
            for contact in contactsSelected{
                if contact.selectedContact == true {
                    
                    let phoneNumber = contact.phoneNumber
                    
                    let cleanPhoneNumber = self.cleanPhoneNumbers(phoneNumbers: phoneNumber)
                    
                        selectedContacts.append(cleanPhoneNumber)
                    }}
            print("Selected Contacts Phone Numbers \(selectedContacts)")
            completion()
            
        }}
    
    

    
//    get the current users phone number
    func getCurrentUsersPhoneNumber( completion: @escaping () -> Void){
        
        dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments{ (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents{
                    let usersPhoneNumber = document.get("phoneNumber")
                    selectedContacts.append(usersPhoneNumber as! String)
                    print("Current users phone number to add to selected contacts \(selectedContacts)")
                }}
            completion()
        }}
}

