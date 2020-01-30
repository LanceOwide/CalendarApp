//
//  ContactsViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 28/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import ContactsUI

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!

//    var detailViewController: DetailViewController? = nil
    var contacts = [contactList]()
    var filteredContacts = [contactList]()
    var sortedContacts = [contactList]()


    let searchController = UISearchController(searchResultsController: nil)

    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()


        fetchContacts{
            self.sortedContacts = self.contacts.sorted(by: { $0.name < $1.name })
            self.tableView.reloadData()

        }



        // Setup the Search Controller
        searchController.searchResultsUpdater = self

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        definesPresentationContext = true

    }


    //    this function is used to fetch the contacts
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


                            print(self.contacts)


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
            return filteredContacts.count
        }

        return sortedContacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        let candy: contactList
        if isFiltering() {
            candy = filteredContacts[indexPath.row]
        } else {
            candy = sortedContacts[indexPath.row]
        }
        cell.textLabel!.text = candy.name
        cell.tintColor = UIColor.black

        if candy.selectedContact == true {
            cell.accessoryType = .checkmark

        } else{
            cell.accessoryType = .none
        }


        return cell
    }


    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredContacts = sortedContacts.filter({( person : contactList) -> Bool in
            return person.name.lowercased().contains(searchText.lowercased())
        })

        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //        check to see if there already exist a check mark, if there is remove it, if there isnt add it
        //        sets the done property on the item in the array to the opposite of what it is now


        if isFiltering() {
            filteredContacts[indexPath.row].selectedContact = !filteredContacts[indexPath.row].selectedContact
        }

        sortedContacts[indexPath.row].selectedContact = !sortedContacts[indexPath.row].selectedContact


        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)

    }

}
extension ContactsViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}




