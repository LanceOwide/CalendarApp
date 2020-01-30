//
//  TestContactsSearch.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 13/02/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import ContactsUI

    var contactsSelected = [contactList]()
    var contacts = [contactList]()
    var contactsSorted = [contactList]()
    var contactsFiltered = [contactList]()

class TestContactsSearch: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    

    var isFiltering = false
    var selectedContactPredicate: NSPredicate = NSPredicate.init()
    
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Contacts"
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        tableView.dataSource = self
        tableView.delegate = self
//        navigationController?.delegate = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "testingCell")
        
        
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Contacts"
        search.searchBar.showsCancelButton = false
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        search.hidesNavigationBarDuringPresentation = false
        
//        add a toolbar to the datepicker
                    let toolBar = UIToolbar()
                    toolBar.sizeToFit()
                    
                    
//            Adding a done button to our navigation bar
                    
                    let doneButton2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneClicked))
                    
                    self.navigationItem.rightBarButtonItems = [doneButton2]
        
//        the contacts list will only be refreshed if the contacts list hasnt previously been populated, this ensures the selected contacts are perpetuated
        
        if contactsSorted.count == 0 {
        
        fetchContacts {
            
            DispatchQueue.main.async {
            self.tableView.reloadData()
            }
               
        }
        }

    }
    
    
    
//    The procedure once the done button is pressed
    @objc func doneClicked(){
        
        print("Done button pressed")
        
        performSegue(withIdentifier: "contactsListDonePressed", sender: Any.self)

    }
    
    
    func fetchContacts(completion: @escaping () -> Void){
        print("Attempting to fetch the contacts")
        
        contacts.removeAll()

        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("Failed to get access",error)
                
                print("Access Denied")
                
                let alert = UIAlertController(title: "Acess to Contacts Denied", message: "Please go to setting to enable Planr access", preferredStyle: UIAlertController.Style.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { action in
                    
                    print("User selected OK")
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                    
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })}
                    
                    
                    print("User selected Settings")
                    
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)

            }
            if granted{
                print("Acccess Granted")
                
                //                Need to request access to both the given name and the family name and the phone number, each has its own key
                let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do{
                    
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopPointerEnumerating) in
                        //                        print(contact.givenName)
                        
                        contacts.append(contactList(name: contact.givenName + " " + contact.familyName, phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "", selectedContact: false))

                    })
                    
                    contactsSorted = contacts.sorted(by: { $0.name < $1.name })
                    
                    contactsSorted.removeAll {$0.name == ""}
                    contactsSorted.removeAll {$0.name == " "}
                    contactsSorted.removeAll {$0.name == "  "}
                    contactsSorted.removeAll {$0.name == "   "}
                    contactsSorted.removeAll {$0.name == "    "}
                    contactsSorted.removeAll {$0.name == "     "}
                    contactsSorted.removeAll {$0.name == "      "}
                    contactsSorted.removeAll {$0.name == "       "}
                    contactsSorted.removeAll {$0.phoneNumber == ""}
                    contactsSorted.removeAll {$0.phoneNumber == " "}
                    contactsSorted.removeAll {$0.phoneNumber == "  "}
                    contactsSorted.removeAll {$0.phoneNumber == "   "}
                    contactsSorted.removeAll {$0.phoneNumber == "    "}
                    contactsSorted.removeAll {$0.phoneNumber == "     "}
                    contactsSorted.removeAll {$0.phoneNumber == "      "}
                    contactsSorted.removeAll {$0.phoneNumber == "       "}
                        
                    
                    completion()
                    
                } catch let error{
                    print("Failed to enumerate contacts:",error)
                }
            }
            else{
                print("Access Denied")
                
                let alert = UIAlertController(title: "Acess to Contacts Denied", message: "Please go to setting to enable Planr access", preferredStyle: UIAlertController.Style.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { action in
                    
                    print("User selected OK")
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                    
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })}
                    
                    
                    print("User selected Settings")
                    
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
   
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {

        guard let text = searchController.searchBar.text else { return }
        if text == ""{
          
            isFiltering = false
            contactsFiltered = contactsSorted
        }
        else{
            searchController.obscuresBackgroundDuringPresentation = false
            isFiltering = true
            
            filterContentForSearchText(text)
        }
        tableView.reloadData()
//        print(isFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        contactsFiltered = contactsSorted.filter({( contact : contactList) -> Bool in
            return contact.name.lowercased().contains(searchText.lowercased())
        })
//        print(contactsFiltered)
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering{
            
            return contactsFiltered.count
        }
        else{
        
       return contactsSorted.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "testingCell", for: indexPath)
    let contact: contactList
        
        if isFiltering{
        
            contact = contactsFiltered[indexPath.row]
        
        cell.textLabel!.text = contact.name
        cell.tintColor = UIColor.black
        }
        else{
            
            contact = contactsSorted[indexPath.row]
            
            cell.textLabel!.text = contact.name
            cell.tintColor = UIColor.black
            cell.detailTextLabel?.text = contact.phoneNumber
            
        }
        
        if contact.selectedContact == true {
            cell.accessoryType = .checkmark
        }
        else{
            cell.accessoryType = .none
        }
        
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        check to see if there already exist a check mark, if there is remove it, if there isnt add it
        //        sets the done property on the item in the array to the opposite of what it is now
        
        
        print("Row Selected")
 
        if isFiltering {
            
            if contactsFiltered[indexPath.row].selectedContact == false {
                contactsFiltered[indexPath.row].selectedContact = true
                contactsSelected.append(contactsFiltered[indexPath.row])
                if let fooOffset = contactsSorted.index(where: {$0.phoneNumber == contactsFiltered[indexPath.row].phoneNumber}) {
                    contactsSorted[fooOffset].selectedContact = true
                    
                    print(contactsSelected)
                } else {
                    // item could not be found
                }
            }
            else{
                
                contactsFiltered[indexPath.row].selectedContact = false
                if let fooOffset = contactsSorted.index(where: {$0.phoneNumber == contactsFiltered[indexPath.row].phoneNumber}) {
                    contactsSorted[fooOffset].selectedContact = false
                    
//                    remove the selected row from the selected list

                    contactsSelected.removeAll(where: { $0.name == contactsFiltered[indexPath.row].name})
                    
              print(contactsSelected)
                    
                } else {
                    // item could not be found
                }
                
            }}
            
        else{
            
            if contactsSorted[indexPath.row].selectedContact == false{
               contactsSorted[indexPath.row].selectedContact = true
                contactsSelected.append(contactsSorted[indexPath.row])
                print(contactsSelected)
            }
            else{
              contactsSorted[indexPath.row].selectedContact = false
                
                
//                    remove the selected row from the selected list
                contactsSelected.removeAll(where: { $0.name == contactsSorted[indexPath.row].name})
                
                print(contactsSelected)
                
            }
        }
        
//        print(contactsSorted[indexPath.row])
        

        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        print(contactsSelected.count)

    }
    
}



