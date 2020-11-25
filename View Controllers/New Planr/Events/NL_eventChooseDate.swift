//
//  NL_eventChooseDate.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 10/1/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import Foundation
import UIKit



class NL_eventChooseDate: UIViewController {

    
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
    
    
//    create all variables for event detials
    var lbleventDescription = UILabel()
    var lbleventLocation = UILabel()
    var btnChoosen = UIButton()
    var imgEventType = UIImageView()
    var pageTitle = UILabel()
    
//    add the collectionViews
    var cvEventResponses: UICollectionView!
    
//    buttons
    var btnEdit = UIButton()
    var btnDelete = UIButton()
    var btnChat = UIButton()
    var btnEditAvailability = UIButton()
    var lblDelete = UILabel()
    var lblEdit = UILabel()
    
    let cellId = "cellId"
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(inputBottomView)
        // Set its constraint to display it on screen
        inputBottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputBottomView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        inputBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputBottomView.isUserInteractionEnabled = true
        
        setup()
        
//        MARK: listener to detect when the event availability has been udpated by the user
                NotificationCenter.default.addObserver(self, selector: #selector(updateTables), name: .availabilityUpdated, object: nil)
                
//        Listen for any updates to the DB and update the tables
                NotificationCenter.default.addObserver(self, selector: #selector(updateTables), name: .newDataLoaded, object: nil)
    }
    
    func setup(){
//        if the current user is not the owner, we do not want to show the button
        if currentUserSelectedEvent.eventOwnerID != user!{
            btnChoosen.isHidden = true
        }
        
    }
    

   lazy var inputBottomView: UIView = {
    
    
    let pageTitleHeight = CGFloat(50)
    let titleHeight = CGFloat(30)
    let timeHeight = CGFloat(25)
    let locationHeight = CGFloat(25)
    let sideInset = CGFloat(16)
    let imgSize = CGFloat(50)
    let closeSize = CGFloat(28)
    let cvInviteeHeight = CGFloat(70)
    let bottomButtonHeight = CGFloat(150)
    let spacer = CGFloat(10)
    let buttonSize = CGFloat(55)
    let buttonSpacing = (screenWidth - buttonSize*4)/5
    let lblSize = screenWidth/4
    let lblHeight = CGFloat(10)
    let btnChosenHeight = CGFloat(70)
    
    //   setup the view for holding the progress bar and title
    let containerView = UIView()
    containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight - topDistance)
    containerView.backgroundColor = UIColor.white
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    //        trying to add a top view
    let topView = UIView()
    topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight - topDistance)
    topView.backgroundColor = UIColor.white
    topView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(topView)
    topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
    topView.heightAnchor.constraint(equalToConstant: screenHeight).isActive = true
    topView.isUserInteractionEnabled = true
    
//    add the page title and the close button
    
    topView.addSubview(pageTitle)
    pageTitle.text = selectedDateString
    pageTitle.textAlignment = .center
    pageTitle.font = UIFont.systemFont(ofSize: 18)
    pageTitle.translatesAutoresizingMaskIntoConstraints = false
    pageTitle.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
    pageTitle.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset).isActive = true
    pageTitle.widthAnchor.constraint(equalToConstant: 100).isActive = true
    pageTitle.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
    
    let closeButton = UIButton()
    topView.addSubview(closeButton)
    closeButton.setImage(UIImage(named: "closeButtonCode"), for: .normal)
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset).isActive = true
    closeButton.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: closeSize).isActive = true
    closeButton.heightAnchor.constraint(equalToConstant: closeSize).isActive = true
    closeButton.addTarget(self, action: #selector(closeSeclected), for: .touchUpInside)
    
    
    
    
    //    add the event title
    topView.addSubview(btnChoosen)
    btnChoosen.bottomAnchor.constraint(equalTo: topView.bottomAnchor,constant: -topDistance - sideInset*2).isActive = true
    btnChoosen.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset).isActive = true
    btnChoosen.rightAnchor.constraint(equalTo: topView.rightAnchor,constant: -sideInset*2).isActive = true
    btnChoosen.heightAnchor.constraint(equalToConstant: btnChosenHeight).isActive = true
    btnChoosen.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    btnChoosen.setTitleColor(.white, for: .normal)
    btnChoosen.backgroundColor = MyVariables.colourPlanrGreen
    btnChoosen.titleLabel?.textAlignment = .center
    btnChoosen.layer.cornerRadius = 3
    btnChoosen.layer.masksToBounds = true
    btnChoosen.translatesAutoresizingMaskIntoConstraints = false
    btnChoosen.setTitle("Choose this Date", for: .normal)
    btnChoosen.addTarget(self, action: #selector(saveDateSelected), for: .touchUpInside)
    
    
//    add the invitee collectionView
    
    
    //        setup the collectionView
     let layout2 = UICollectionViewFlowLayout()
    layout2.scrollDirection = .vertical
    cvEventResponses = UICollectionView(frame: .zero, collectionViewLayout: layout2)
     cvEventResponses.register(NL_userCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    cvEventResponses.register(ResultsSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
     cvEventResponses.backgroundColor = .white
     cvEventResponses.isScrollEnabled = true
     cvEventResponses.isUserInteractionEnabled = true
     cvEventResponses.allowsSelection = true
    cvEventResponses.delegate = self
    cvEventResponses.dataSource = self
    topView.addSubview(cvEventResponses)
    cvEventResponses.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset).isActive = true
    cvEventResponses.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset + titleHeight + spacer*2).isActive = true
    cvEventResponses.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
    cvEventResponses.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -topDistance - btnChosenHeight - sideInset*2).isActive = true
    cvEventResponses.translatesAutoresizingMaskIntoConstraints = false
    
    
    return containerView
    }()
    
//    fucntion to reload the page, this can be triggered anywhere
    
    @objc func updateTables(){
        print("results page func updateTables - updated availability notification triggered - eventIDChosen: \(currentUserSelectedEvent.eventID)")
//        need to refresh the event data, we can also check if the user has deleted the event
                let predicate = NSPredicate(format: "eventID = %@", currentUserSelectedEvent.eventID)
                let predicateReturned = self.serialiseEvents(predicate: predicate, usePredicate: true)
                if predicateReturned.count == 0{
                    print("something went wrong")
                }
                else{
                    currentUserSelectedEvent = predicateReturned[0]
//        need to pull the new availability data from CoreData
                currentUserSelectedAvailability = serialiseAvailability(eventID: currentUserSelectedEvent.eventID)
                self.prepareForEventDetailsPageCD(segueName: "", isSummaryView: summaryView, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                    self.cvEventResponses.reloadData()
//            check if the user has responded and adjust the image accordingly
                    }
                }
    }
    
    
//    function to dismiss the event view on pressing the close button
    @objc func closeSeclected(){
        self.dismiss(animated: true)
    }
    
    
    @objc func saveDateSelected() {
        
    //    need to find the position of the date in the dates array, to upload to FB
        let dateChosenPosition = currentUserSelectedEvent.startDatesDisplay.index(of: selectedDateString) ?? 999
        
        
    //    need to convert the selected date from the display format into a fomrat without the time
    //    1. get the date from the start dates list and convert to the required YYYY-MM-DD format
        let dateChosen = currentUserSelectedEvent.startDateArray[dateChosenPosition]
        
        // create the alert
                let alert = UIAlertController(title: "Select Date \(selectedDateString)", message: "You're about to select this date for your event, would you like to continue?", preferredStyle: UIAlertController.Style.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: { action in
                    
                    
                }))
                alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { action in
                    
                    print("saveDateSelected \(dateChosen)")
                    
                    let chosenDateYear = String(dateChosen[0...3])
                    let chosenDateMonth = String(dateChosen[5...6])
                    let chosenDateDay = String(dateChosen[8...9])
                    
                    let chosenDateYearInt = Int(chosenDateYear)!
                    let chosenDateMonthInt = Int(chosenDateMonth)!
                    let chosenDateDayInt = Int(chosenDateDay)!
                      
    //                write the data into the eventRequets
                    dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).setData(["chosenDate" : dateChosen, "chosenDateMonth" : chosenDateMonthInt, "chosenDateYear" : chosenDateYearInt, "chosenDateDay": chosenDateDayInt, "chosenDatePosition" : dateChosenPosition], merge: true)

                        
                    print("date submitted to the eventRequest table: \(dateChosen)")
                        
    //            Adds the chosen date to each individuals user event store + add a notification for each user that the date for the event has been chosen
                    for i in currentUserSelectedAvailability{
                        
                        dbStore.collection("userEventStore").document(i.documentID).setData(["chosenDate" : dateChosen, "chosenDateMonth" : chosenDateMonthInt, "chosenDateYear" : chosenDateYearInt, "chosenDateDay": chosenDateDayInt, "chosenDateSeen": false], merge: true)
                        
                        dbStore.collection("userEventUpdates").document(i.uid).setData([currentUserSelectedEvent.eventID : "DateChosen"], merge: true)
                    }
                        
                    self.dismiss(animated: true)
                        
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
        }
    
}


// setup the collectionView
extension NL_eventChooseDate: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        var numberOfSections = Int()
//        there are two sections for the responses collectionView
        var n = 0
        
        if availableUserArray.count > 0 {
            n = n + 1
        }
        if nonAvailableArray.count > 0{
            n = n + 1
            
            }
        if notRespondedArray.count > 0{
            
            n = n + 1
        
        }
        if nonUserArray.count > 0{
            n = n + 1
        }
        
        numberOfSections = n

        return numberOfSections
    }
    

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            print("collectionViewCell invitees reloading")
            
            var numberOfRows = [Int]()
            numberOfRows.removeAll()
            
            if availableUserArray.count > 0{
                
                numberOfRows.append(availableUserArray.count)
            }
            if nonAvailableArray.count > 0 {
                
                numberOfRows.append(nonAvailableArray.count)
            }
            if notRespondedArray.count > 0{

                numberOfRows.append(notRespondedArray.count)
            }
            if nonUserArray.count > 0{
                numberOfRows.append(nonUserArray.count)
            }
            

            return numberOfRows[section]
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
            let cell = cvEventResponses?.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NL_userCollectionViewCell
            
//            array to contain the list and order of the sections, we use this later to determine which secions contain data
            
            var sections = [String: Int]()
            
            var arrays = [[Int]]()
            arrays.removeAll()
            var n = -1
            
            if availableUserArray.count > 0{
                n = n + 1
                arrays.append(availableUserArray)
                sections["Available"] = n
            }
            else{
                sections["Available"] = 99
            }
            if nonAvailableArray.count > 0 {
                n = n + 1
                arrays.append(nonAvailableArray)
                sections["Not Available"] = n
            }
            else{
                sections["Not Available"] = 99
            }
            if notRespondedArray.count > 0{
                n = n + 1
                arrays.append(notRespondedArray)
                sections["Not Responded"] = n
            }
            else{
                sections["Not Responded"] = 99
            }
            if nonUserArray.count > 0{
                n = n + 1
                arrays.append(nonUserArray)
                sections["Non User"] = n
            }
            else{
                sections["Non User"] = 99
            }
              print("indexPath.section \(indexPath.section) indexPath.row \(indexPath.row)")
            
            if arrayForEventResultsPageFinal.indices.contains([arrays[indexPath.section][indexPath.row]][0]){
            
            cell.cellText.text = arrayForEventResultsPageFinal[arrays[indexPath.section][indexPath.row]][0] as? String
            }
            else{
                print("something went wrong")
                
                self.dismiss(animated: true)
            }
            
//            if we assume the order of the user IDs and the user names are the same, we can use a search for the user name and its index as the index for the user ID, we only want to do this for the first two rows as the other two are not users
            
            let availableSection = sections["Available"]
            let notAvailableSection = sections["Not Available"]
            let notRespondedSection = sections["Not Responded"]
            let nonUserSection = sections["Non User"]
            
            if indexPath.section == availableSection || indexPath.section == notAvailableSection || indexPath.section == notRespondedSection{
            
            let currentUsers = currentUserSelectedEvent.currentUserNames
                let currentUserIDs = currentUserSelectedEvent.users
//                get the index of the users name from
                if let index = currentUsers.index(of: arrayForEventResultsPageFinal[arrays[indexPath.section][indexPath.row]][0] as! String){
//                    get the users id based on the index
        
                    let userID = currentUserIDs[index]
                    
                    // get the users image
                    let imageList = CoreDataCode().fetchImage(uid: userID)
                                        
                    var image = Data()
                    if imageList.count != 0{
                    image = imageList[0].userImage!
                                        }
//
                    cell.eventImageView.image = UIImage(data: image)
                }
                else{
//                    there were no images returned
                    cell.eventImageView.image = .none
                }
                
            }else if indexPath.section == nonUserSection{
//                the user is a non user, we should display the invite message
                let inviteImage = imageWith(name: "Invite", width: 100, height: 100, fontSize: 20, textColor: MyVariables.colourPlanrGreen)
                cell.eventImageView.image = inviteImage
            }
            
            
            return cell
        }
    
        
    // sets the size of the cell
            func collectionView(_ collectionView: UICollectionView,
                                   layout collectionViewLayout: UICollectionViewLayout,
                                   sizeForItemAt indexPath: IndexPath) -> CGSize {
                
                var size = CGSize()
                
//            load the collectionView for the invitees
                size = CGSize(width: screenWidth - 32, height: 57)
                    
                   return size
               }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if collectionView == cvEventResponses{
                if kind == UICollectionView.elementKindSectionHeader {
             let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! ResultsSectionHeader

                    var headersList = [String]()
                    headersList.removeAll()
                    
                    let headersListStatic = ["Available","Unavailable","Not Responded","Non User"]
                    

                    if availableUserArray.count > 0 {
                        
                        headersList.append(headersListStatic[0])
                        
                    }
                    if nonAvailableArray.count > 0{
                        
                        headersList.append(headersListStatic[1])
                        
                        }
                    if notRespondedArray.count > 0{
                        
                        headersList.append(headersListStatic[2])
                    
                    }
                    if nonUserArray.count > 0{
                        
                        headersList.append(headersListStatic[3])
                    
                    }
                    
                    sectionHeader.label.text = headersList[indexPath.section]
                
                    
             return sectionHeader
        } else { print("this wasnt a collectionView header kind - \(kind)")
             return UICollectionReusableView()
                }}
             return UICollectionReusableView()
        }
    
//    defines the size of the header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: screenWidth - 32, height: 30)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        var sections = [String: Int]()
        var arrays = [[Int]]()
        arrays.removeAll()
        var n = -1
        
        if availableUserArray.count > 0{
            n = n + 1
            sections["Available"] = n
        }
        else{
            sections["Available"] = 99
        }
        if nonAvailableArray.count > 0 {
            n = n + 1
            sections["Not Available"] = n
        }
        else{
            sections["Not Available"] = 99
        }
        if notRespondedArray.count > 0{
            n = n + 1
            sections["Not Responded"] = n
        }
        else{
            sections["Not Responded"] = 99
        }
        if nonUserArray.count > 0{
            n = n + 1
            sections["Non User"] = n
        }
        else{
            sections["Non User"] = 99
        }
        
        
        let nonUserSection = sections["Non User"]
        
//        if the user selected a non user
        
        if indexPath.section == nonUserSection{
        
//        get the nonusers mobile phone numbers from FB
                getNonUsers(eventID: currentUserSelectedEvent.eventID){
                (usersName, usersNumbers) in
                        self.inviteFriendsPopUp(notExistingUserArray: usersNumbers, nonExistingNameArray: usersName)
                }
        }
        else{
            print("the user selected a current user")
        }

    }
  
}




