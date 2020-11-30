//
//  NL_AddInvitees.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/20/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit


class NL_AddInvitees: UIViewController, UISearchResultsUpdating{
    
    
    
    //    get the top distance of the page
      /// Get distance from top, based on status bar and navigation
      public var topDistance : CGFloat{
           get{
               if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                   return 0
               }else{
                  let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
                  let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                  return barHeight + statusBarHeight
               }
           }
      }
    
    public var barHeight : CGFloat{
         get{
             if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                 return 0
             }else{
                let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
                let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                print("statusBarHeight \(statusBarHeight) barHeight \(barHeight)")
                return barHeight
             }
         }
    }
    
//    variables
    var titleInput = UITextField()
    var tableViewContacts: UITableView!
    let cellId = "cellId"
    var isFiltering = false
    var selectedContactPredicate: NSPredicate = NSPredicate.init()
    var searcchControllercontacts: UISearchController!
    var keyboardFrame = CGRect()
    
//    var keyboardIsShowing = 0
    
//    used to house only the contacts we want to show to the user
    var contactsSortedToShow = [contactList]()
    var contactsFilteredToShow = [contactList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        this stops the viewcontroller from being dismissed when the user swipes down
                if #available(iOS 13.0, *) {
                    self.isModalInPresentation = true
                } else {
                    // Fallback on earlier versions
                }
        
//        setup the page
        setupThePage()
        createNextButton()
        
//        function to setup the keyboard observers to move the content on the screen
        setupKeyboardObservers()
        
//        access the users contacts
        AutoRespondHelper.getUserContacts(viewController: self){
          DispatchQueue.main.async {
            self.tableViewContacts.reloadData()
            }
        }
        
//        MUST ADD subview
        view.addSubview(inputTopView)
        view.addSubview(inputBottomView)

                
// Set its constraint to display it on screen
        inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: barHeight).isActive = true
        inputTopView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputTopView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
//        setup view for collectionView
        inputBottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputBottomView.topAnchor.constraint(equalTo: view.topAnchor, constant: barHeight + 80).isActive = true
        
    }
//    if the user presses back to get to the page, we need the table to reload to reflect any changes they made to the invitees
    override func viewDidAppear(_ animated: Bool) {
        tableViewContacts.reloadData()
    }
    
            func setupThePage(){
    //        set the title for the page
            let title = "Create Event"
            self.title = title
                
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = MyVariables.colourPlanrGreen
        navigationItem.backBarButtonItem = backItem
            }
    
    
    //    create the progress bar and title
        lazy var inputTopView: UIView = {
            print("setting up the inputTopView")
    //        set the variables for the setup
            let progressAmt = 0.75
            let headerLabelText = "Select Invitees"
            let numberLabelText = "03"
            let instructionLabelText = "Choose from your contact list"
            let sideInset = 16
         
            //   setup the view for holding the progress bar and title
            let containerView = UIView()
            containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
            containerView.backgroundColor = UIColor.white
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
    //        trying to add a top view
            let topView = UIView()
            topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
            topView.backgroundColor = UIColor.white
            topView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(topView)
            topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            topView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            
            //        setup the progress bar
            let progressBar = UIProgressView(progressViewStyle: .default)
            progressBar.progress = Float(progressAmt)
            progressBar.center = view.center
            progressBar.progressTintColor = MyVariables.colourPlanrGreen
            progressBar.backgroundColor = MyVariables.colourBackground
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            progressBar.layer.sublayers![1].cornerRadius = 4
            progressBar.subviews[1].clipsToBounds = true
            topView.addSubview(progressBar)
            progressBar.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive = true
            progressBar.topAnchor.constraint(equalTo: topView.topAnchor, constant: 0).isActive
             = true
            progressBar.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
            progressBar.heightAnchor.constraint(equalToConstant: 8).isActive = true
            
            //        setup the item label
            let numberLabel = UILabel()
            numberLabel.text = numberLabelText
            numberLabel.font = UIFont.systemFont(ofSize: 14)
            numberLabel.textColor = MyVariables.colourLight
            numberLabel.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(numberLabel)
            numberLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 16).isActive = true
            numberLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
            numberLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
            numberLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            //        setup the item label
            let headerLabel = UILabel()
            headerLabel.text = headerLabelText
            headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(headerLabel)
            headerLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset + 30)).isActive = true
            headerLabel.widthAnchor.constraint(equalToConstant: screenWidth - 30 - CGFloat(sideInset)).isActive = true
            headerLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
            headerLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
    //        set the instruction
            let instructionLabel = UILabel()
            instructionLabel.text = instructionLabelText
            instructionLabel.font = UIFont.systemFont(ofSize: 14)
            instructionLabel.textColor = MyVariables.colourLight
            instructionLabel.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(instructionLabel)
            instructionLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset + 30)).isActive = true
            instructionLabel.widthAnchor.constraint(equalToConstant: screenWidth - 30 - CGFloat(sideInset)).isActive = true
            instructionLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40).isActive = true
            instructionLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            
            return containerView
        }()
    
    //    setup the inputs for the detials
    lazy var inputBottomView: UIView = {
        
        let textBoxHeight = 50
        let sideInset = 16
        let sideInsetIcon = 24
        let separatorHeight = 1
        let iconSize = textBoxHeight/3
        
        //   setup the view for holding the assets
        let containerView2 = UIView()
        containerView2.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: screenHeight - topDistance - 100)
        containerView2.backgroundColor = UIColor.white
        containerView2.translatesAutoresizingMaskIntoConstraints = false
        
        
        //        trying to add a top view that represents the remainder of the screen
         let topView = UIView()
         topView.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: screenHeight - topDistance - 100)
         topView.backgroundColor = UIColor.white
         topView.translatesAutoresizingMaskIntoConstraints = false
         containerView2.addSubview(topView)
         topView.leftAnchor.constraint(equalTo: containerView2.leftAnchor).isActive = true
         topView.topAnchor.constraint(equalTo: containerView2.topAnchor).isActive = true
         topView.widthAnchor.constraint(equalTo: containerView2.widthAnchor).isActive = true
         topView.heightAnchor.constraint(equalToConstant: screenHeight - topDistance - 100).isActive = true
        
        //        create a separator line
        let separatorLine = UIView()
        separatorLine.backgroundColor = MyVariables.colourPlanrGreen
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLine)
        separatorLine.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        separatorLine.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        
        
        //        setup the collectionView for the contacts
        tableViewContacts = UITableView(frame: .zero)
        tableViewContacts.translatesAutoresizingMaskIntoConstraints = false
        tableViewContacts.delegate = self
        tableViewContacts.dataSource = self
        tableViewContacts.register(NL_contactTableViewCell.self, forCellReuseIdentifier: cellId)
        tableViewContacts.backgroundColor = .white
        tableViewContacts.isScrollEnabled = true
        tableViewContacts.rowHeight = 70
        tableViewContacts.separatorStyle = .none
        tableViewContacts.separatorColor = MyVariables.colourPlanrGreen
        tableViewContacts.isUserInteractionEnabled = true
        tableViewContacts.allowsSelection = true
        tableViewContacts.allowsMultipleSelection = false
        topView.addSubview(tableViewContacts)
        tableViewContacts.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        tableViewContacts.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        tableViewContacts.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight) + CGFloat(separatorHeight*10)).isActive = true
        tableViewContacts.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        
        searcchControllercontacts = UISearchController(searchResultsController: nil)
        searcchControllercontacts.searchResultsUpdater = self
        searcchControllercontacts.obscuresBackgroundDuringPresentation = false
        searcchControllercontacts.searchBar.setValue("Done", forKey:"cancelButtonText")
//        definesPresentationContext = true
        topView.addSubview(searcchControllercontacts.searchBar)
        searcchControllercontacts.searchBar.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        searcchControllercontacts.searchBar.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        searcchControllercontacts.searchBar.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(separatorHeight*5)).isActive = true
        searcchControllercontacts.searchBar.heightAnchor.constraint(equalToConstant: CGFloat(textBoxHeight)).isActive = true
//        tableViewContacts.tableHeaderView = searcchControllercontacts.searchBar
//        searcchControllercontacts.searchBar.barTintColor = UIColor.white
        
        
        return containerView2
    }()
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func handleKeyboardWillShow(_ notification: Notification) {

//        we need to check if the keyboard is already the first responder, otherwise we will push the message of the screen again, this is being called when the viewload, we dont know how to stop this, so we check if there are no messages first
        keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
//        keyboardIsShowing = Int(keyboardFrame.height)
        
//        set the global variable for the keyboard
        print("handleKeyboardWillShow is running keyboardFrame!.height \(keyboardFrame.height)")
    }


    @objc func handleKeyboardWillHide(_ notification: Notification) {


        self.view.frame.origin.y = 0

    }

    
    
//    what to do when the search results are updating
    func updateSearchResults(for searchController: UISearchController) {
        print("running func updateSearchResults")
//        check that the user has typed some text
                guard let text = searcchControllercontacts.searchBar.text else { return }
                if text == ""{
                  
                    isFiltering = false
                    contactsFiltered = contactsSorted
                }
                else{
//                    searchController.obscuresBackgroundDuringPresentation = false
                    isFiltering = true
                    
                    filterContentForSearchText(text)
                }
                tableViewContacts.reloadData()
    }
//    filter the users contacts for
        func filterContentForSearchText(_ searchText: String, scope: String = "All") {
            contactsFiltered = contactsSorted.filter({( contact : contactList) -> Bool in
                return contact.name.lowercased().contains(searchText.lowercased())
            })
        }
       
}

//extension for the collectionview containing the event choices
extension NL_AddInvitees: UITableViewDataSource, UITableViewDelegate {
    
//    set the number of sections in the tableView, we have two, one for the users selected the other for the other users in the users contacts
    func numberOfSections(in tableView: UITableView) -> Int {
         return 2
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//       if this is the selected contacts we reutrn only the invitees in the first section
        if section == 0{
            
//            if the user is filtering the data we only want to show the last user they selected
            
            if isFiltering == true{
//          we want to show one user if there is one selected, otherwise we show nothing
                if contactsSelected.count > 0{
                    return 1
                }
                else{
                    return 0
                }
            }else{
                return contactsSelected.count
            }
            
        }
//            if this is the contacts section we check if filtering and filter accoringly
        else{
            
//            we only want to show the contacts who havent already been selected
            if isFiltering{
                 return contactsFiltered.count
             }
             else{
            return contactsSorted.count
             }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! NL_contactTableViewCell
         let contact: contactList
        
//        we dont want the cell to be highlighted when the user selects it
        cell.selectionStyle = .none
        
        if indexPath.section == 0{
//            if the user is filtering, we want to show them only the last user they chose
            if isFiltering == true{
                contact = contactsSelected.last!
               cell.cellText.text = contact.name
               cell.addImageView.image = UIImage(named: "deleteCode")
            }
            else{
         contact = contactsSelected[indexPath.row]
        cell.cellText.text = contact.name
        cell.addImageView.image = UIImage(named: "deleteCode")
            }
        }
        else{
        if isFiltering{
        contact = contactsFiltered[indexPath.row]
        cell.cellText.text = contact.name
            cell.addImageView.image = UIImage(named: "addUserCode")
        }
        else{
            contact = contactsSorted[indexPath.row]
            cell.cellText.text = contact.name
            cell.addImageView.image = UIImage(named: "addUserCode")
            }}
        return cell
    }
    
//    build a view for the display of the tableView header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let lbl = UILabel()
        let lblCount = UILabel()
        view.backgroundColor = .white
        view.addSubview(lbl)
        view.addSubview(lblCount)
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        lbl.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        lbl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60).isActive = true
        lbl.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lblCount.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        lblCount.widthAnchor.constraint(equalToConstant: 60).isActive = true
        lblCount.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        lblCount.translatesAutoresizingMaskIntoConstraints = false
        lblCount.textColor = MyVariables.colourLight
        lblCount.textAlignment = .center
        
        //        create a separator line
        let separatorLine = UIView()
        separatorLine.backgroundColor = MyVariables.colourPlanrGreen
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorLine)
        separatorLine.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth))).isActive = true
        separatorLine.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: CGFloat(1)).isActive = true
        
//        set the header text based on the section
        if section == 0{
        lbl.text =  "Selected Contacts"
        lblCount.text = ("(\(contactsSelected.count))")
        }
        else{
        lbl.text = "All Contacts"
        lblCount.text = ("(\(contactsSorted.count))")
        }
        
        
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        the user has selected from their selected users
        if indexPath.section == 0{
//            if the user is filtering we want to remove the last user in the selected contacts
            if isFiltering == true{
//            add the contact back to the other two lists
                contactsFiltered.append(contactsSelected.last!)
                contactsSorted.append(contactsSelected.last!)
//            remove the user from the selected list
                contactsSelected.removeLast()
            }
            else{
            
//            add the contact back to the other two lists
            contactsFiltered.append(contactsSelected[indexPath.row])
            contactsSorted.append(contactsSelected[indexPath.row])
//            remove the user from the selected list
            contactsSelected.remove(at: indexPath.row)
            }
        }
        
//        the user is selecting from their list of contacts
        if indexPath.section == 1{
            if isFiltering {
//                add the user to the selected list of users
                contactsSelected.append(contactsFiltered[indexPath.row])
//                remove the user from the full list of contacts
                if let fooOffset = contactsSorted.index(where: {$0.phoneNumber == contactsFiltered[indexPath.row].phoneNumber}) {
                    contactsSorted.remove(at: fooOffset)
            }
            else {
            // item could not be found
            }
//                remove the user from the filtered list
                contactsFiltered.remove(at: indexPath.row)
                
            }
//        the user wasnt filtering
            else{
//                add the contact to the contactsSelected array
                contactsSelected.append(contactsSorted[indexPath.row])
//               remove the user from the filtered and unfiltered list
                contactsSorted.remove(at: indexPath.row)
                print(contactsSelected)
            }
        }
//        deselect the row and refresh the table
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
//        check to see if the user has now selected anyone and create the next button
        createNextButton()
    }
    
    
    //    create the next button
        func createNextButton(){
            
            if contactsSelected.count == 0{
                print("the user hasnt selected any contacts, we don't create the next button")
            }
            else{
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(createTapped))
                navigationItem.rightBarButtonItem?.tintColor = MyVariables.colourPlanrGreen}
            }
    //    segue to summary page
        @objc func createTapped(){
            
            let utils = Utils();
//            check if the user selected anyone
            if contactsSelected.count == 0{
                let button = AlertButton(title: "OK", action: {
                    print("OK clicked");
                }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
            
            let alertPayload = AlertPayload(title: "No Invitees!", titleColor: UIColor.red, message: "Please add invitees to your event", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
            
                utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true)
            }
            else{
                performSegue(withIdentifier: "segueToSummary", sender: self)}
        }

}


