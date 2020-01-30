//
//  ContactSearch.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 08/02/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import ContactsUI

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchFooter: SearchFooter!
    
    var contacts = [contactList]()
    var contactsSorted = [contactList]()
    var contactsFiltered = [contactList]()
    
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        fetchContacts {
            
            print(self.contacts)
            self.contactsSorted = self.contacts.sorted(by: { $0.name < $1.name })
            
        }
        
    }
    
    
    func fetchContacts(completion: @escaping () -> Void){
        print("Attempting to fetch the contacts")
        
        contacts.removeAll()
        
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("Failed to get access",error)
                return
            }
            if granted{
                print("Acccess Granted")
                
                //                Need to request access to both the given name and the family name and the phone number, each has its own key
                let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do{
                    
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopPointerEnumerating) in
                        //                        print(contact.givenName)
                        
                        self.contacts.append(contactList(name: contact.givenName + " " + contact.familyName, phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "", selectedContact: false))
                        
                        
                        
                        
                        
                    })
                    
                    completion()
                    
                } catch let error{
                    print("Failed to enumerate contacts:",error)
                }
            }
            else{
                print("Access Denied")
                
                
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return contactsFiltered.count
        }
        
        return contactsSorted.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let candy: contactList
        tableView.deselectRow(at: indexPath, animated: true)
        if isFiltering() {
            candy = contactsFiltered[indexPath.row]
        } else {
            candy = contactsSorted[indexPath.row]
            
        }
        cell.textLabel!.text = candy.name
        cell.tintColor = UIColor.black
        
        if candy.selectedContact == true {
            cell.accessoryType = .checkmark
            
        } else{
            cell.accessoryType = .none
        }
        
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
        
        
        return cell
    }
    
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        contactsFiltered = contactsSorted.filter({( candy : contactList) -> Bool in
            return candy.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        check to see if there already exist a check mark, if there is remove it, if there isnt add it
        //        sets the done property on the item in the array to the opposite of what it is now
        
        
        if isFiltering() {
            
            if contactsFiltered[indexPath.row].selectedContact == false {
                contactsFiltered[indexPath.row].selectedContact = true
                if let fooOffset = contactsSorted.index(where: {$0.phoneNumber == contactsFiltered[indexPath.row].phoneNumber}) {
                    contactsSorted[fooOffset].selectedContact = true
                    
                    
                } else {
                    // item could not be found
                }
            }
            else{
                
                contactsFiltered[indexPath.row].selectedContact = false
                if let fooOffset = contactsSorted.index(where: {$0.phoneNumber == contactsFiltered[indexPath.row].phoneNumber}) {
                    contactsSorted[fooOffset].selectedContact = false
                    
                } else {
                    // item could not be found
                }
                
            }}
            
        else{
            contactsSorted[indexPath.row].selectedContact = !contactsSorted[indexPath.row].selectedContact
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
        
        
    }
    
}
extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
