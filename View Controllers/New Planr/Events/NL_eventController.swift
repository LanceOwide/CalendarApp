//
//  NL_eventController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/26/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import Instructions


var selectedDateString = String()


class NL_eventController: UIViewController, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
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
    var lbleventTime = UILabel()
    var imgEventType = UIImageView()
    var lblstatus = UILabel()
    var lbleventDate = UILabel()
    
//    add the collectionViews
    var cvEventInviteesCollectionView: UICollectionView!
    var cvEventResponses: UICollectionView!
    
//    buttons
    var btnEdit = UIButton()
    var btnDelete = UIButton()
    var btnChat = UIButton()
    var btnEditAvailability = UIButton()
    var lblDelete = UILabel()
    var lblEdit = UILabel()
    let coachMarksController = CoachMarksController()
    
    let cellId = "cellId"
    let cellId2 = "cellId2"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        MARK: remove when pushing to prod
//        newEventCreated = true
        
        title = "Details"
        
        //        ***For coachMarks
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.isUserInteractionEnabled = true
        
        
        view.addSubview(inputBottomView)
        // Set its constraint to display it on screen
        inputBottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputBottomView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        inputBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputBottomView.isUserInteractionEnabled = true
        
        setup()
        
        cvEventInviteesCollectionView.reloadData()
        
        
//        MARK: listener to detect when the event availability has been udpated by the user
                NotificationCenter.default.addObserver(self, selector: #selector(updateTables), name: .availabilityUpdated, object: nil)
                
//        Listen for any updates to the DB and update the tables
                NotificationCenter.default.addObserver(self, selector: #selector(updateTables), name: .newDataLoaded, object: nil)
//        we run the data consistency check to ensure the data is correct when the user opens the app
        dataConsistencyCheck()
    }
    
//    we call the instructions here, because view controller's view is not in the window's view hierarchy at the point that it has been loaded (when the viewDidLoad message is sent), but it is in the window hierarchy after it has been presented (when the viewDidAppear: message is sent).
    override func viewDidAppear(_ animated: Bool) {
        //        show the instructions
                showInstructions()
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
    let statusWidth = CGFloat(60)
    let statusHeight = CGFloat(60)
    
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
    
    let pageTitle = UILabel()
    topView.addSubview(pageTitle)
    pageTitle.text = "Details"
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
    
    //        add the status
    topView.addSubview(lblstatus)
    lblstatus.text = "Pending"
    lblstatus.textAlignment = .center
    lblstatus.font = UIFont.systemFont(ofSize: 11)
    lblstatus.textColor = MyVariables.colourPendingText
    lblstatus.numberOfLines = 2
    lblstatus.adjustsFontSizeToFitWidth = true
    lblstatus.backgroundColor = MyVariables.colourPendingBackground
    lblstatus.widthAnchor.constraint(equalToConstant: statusWidth).isActive = true
    lblstatus.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset - 5).isActive = true
    lblstatus.heightAnchor.constraint(equalToConstant: statusHeight).isActive = true
    lblstatus.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -sideInset).isActive = true
    lblstatus.translatesAutoresizingMaskIntoConstraints = false
    
    
//    add the image for the event
    topView.addSubview(imgEventType)
    imgEventType.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset
        + pageTitleHeight).isActive = true
    imgEventType.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset).isActive = true
    imgEventType.widthAnchor.constraint(equalToConstant: imgSize).isActive = true
    imgEventType.heightAnchor.constraint(equalToConstant: imgSize).isActive = true
    imgEventType.translatesAutoresizingMaskIntoConstraints = false
//    set the image to the user set image
    if let index = eventTypeImages.userEventChoices.index(of: currentUserSelectedEvent.eventType){
            let imageName = eventTypeImages.userEventChoicesImagesColored[index]
        self.imgEventType.image = UIImage(named: imageName)
    }
    else{
        self.imgEventType.image = UIImage(named: "customColoredCode")
        }
    
    
    
//    add the event title
    topView.addSubview(lbleventDescription)
    lbleventDescription.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset + pageTitleHeight).isActive = true
    lbleventDescription.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset + imgSize + sideInset).isActive = true
    lbleventDescription.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*3 - imgSize).isActive = true
    lbleventDescription.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
    lbleventDescription.translatesAutoresizingMaskIntoConstraints = false
    lbleventDescription.font = UIFont.boldSystemFont(ofSize: 17)
    lbleventDescription.text = "Test Event"
    
    
    //    add the event location
    topView.addSubview(lbleventLocation)
    lbleventLocation.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset + titleHeight + pageTitleHeight).isActive = true
    lbleventLocation.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset*2 + imgSize).isActive = true
    lbleventLocation.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*3 - imgSize).isActive = true
    lbleventLocation.heightAnchor.constraint(equalToConstant: locationHeight).isActive = true
    lbleventLocation.translatesAutoresizingMaskIntoConstraints = false
    lbleventLocation.text = "Test Location"
    lbleventLocation.textColor = MyVariables.colourLight
    lbleventLocation.font = UIFont.systemFont(ofSize: 13)
    
    //    add the event title
    topView.addSubview(lbleventTime)
    lbleventTime.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset + titleHeight*2 + pageTitleHeight).isActive = true
    lbleventTime.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset*2 + imgSize).isActive = true
    lbleventTime.widthAnchor.constraint(equalToConstant: 150).isActive = true
    lbleventTime.heightAnchor.constraint(equalToConstant: timeHeight).isActive = true
    lbleventTime.font = UIFont.boldSystemFont(ofSize: 17)
    lbleventTime.textColor = .white
    lbleventTime.backgroundColor = MyVariables.colourPlanrGreen
    lbleventTime.textAlignment = .center
    lbleventTime.layer.cornerRadius = 3
    lbleventTime.layer.masksToBounds = true
    lbleventTime.translatesAutoresizingMaskIntoConstraints = false
    lbleventTime.text = "12:00 - 13:00"
    
    
//    topView.addSubview(lbleventDate)
//    lbleventDate.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset + titleHeight*2 + pageTitleHeight).isActive = true
//    lbleventDate.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset*2 + imgSize + 150 + 10).isActive = true
//    lbleventDate.widthAnchor.constraint(equalToConstant: 150).isActive = true
//    lbleventDate.heightAnchor.constraint(equalToConstant: timeHeight).isActive = true
//    lbleventDate.font = UIFont.boldSystemFont(ofSize: 17)
//    lbleventDate.text = "12:00 - 13:00"
//    lbleventDate.textAlignment = .center
//    lbleventDate.font = UIFont.boldSystemFont(ofSize: 14)
//    lbleventDate.textColor = MyVariables.colourPlanrGreen
//    lbleventDate.backgroundColor = MyVariables.colourSelected
//    lbleventDate.layer.cornerRadius = 3
//    lbleventDate.layer.masksToBounds = true
//    lbleventDate.widthAnchor.constraint(equalToConstant: 120).isActive = true
//    lbleventDate.translatesAutoresizingMaskIntoConstraints = false
//    lbleventDate.isHidden = true
    
    
//    add the invitee collectionView
    
    //        setup the collectionView
     let layout = UICollectionViewFlowLayout()
     layout.scrollDirection = .horizontal
    cvEventInviteesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
     cvEventInviteesCollectionView.register(NL_inviteesCell.self, forCellWithReuseIdentifier: cellId)
     cvEventInviteesCollectionView.backgroundColor = .white
     cvEventInviteesCollectionView.isScrollEnabled = true
     cvEventInviteesCollectionView.isUserInteractionEnabled = true
     cvEventInviteesCollectionView.allowsSelection = true
    cvEventInviteesCollectionView.delegate = self
    cvEventInviteesCollectionView.dataSource = self
    topView.addSubview(cvEventInviteesCollectionView)
    cvEventInviteesCollectionView.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset*2 + imgSize).isActive = true
    cvEventInviteesCollectionView.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset + titleHeight*2 + timeHeight + spacer + pageTitleHeight).isActive = true
     cvEventInviteesCollectionView.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*3 - imgSize).isActive = true
    cvEventInviteesCollectionView.heightAnchor.constraint(equalToConstant: cvInviteeHeight).isActive = true
    cvEventInviteesCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
    
    //        setup the collectionView
     let layout2 = UICollectionViewFlowLayout()
    layout2.scrollDirection = .vertical
    cvEventResponses = UICollectionView(frame: .zero, collectionViewLayout: layout2)
     cvEventResponses.register(NL_eventResultsCell.self, forCellWithReuseIdentifier: cellId2)
    cvEventResponses.register(ResultsSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
     cvEventResponses.backgroundColor = .white
     cvEventResponses.isScrollEnabled = true
     cvEventResponses.isUserInteractionEnabled = true
     cvEventResponses.allowsSelection = true
    cvEventResponses.delegate = self
    cvEventResponses.dataSource = self
    topView.addSubview(cvEventResponses)
    cvEventResponses.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset).isActive = true
    cvEventResponses.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset + titleHeight*2 + timeHeight + cvInviteeHeight + spacer*2 + pageTitleHeight).isActive = true
    cvEventResponses.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
    cvEventResponses.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -bottomButtonHeight).isActive = true
    cvEventResponses.translatesAutoresizingMaskIntoConstraints = false
    
//    MARK: setup the view for the buttons
    
    let buttonsView = UIView()
    topView.addSubview(buttonsView)
    buttonsView.translatesAutoresizingMaskIntoConstraints = false
    buttonsView.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
    buttonsView.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive = true
    buttonsView.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
    buttonsView.heightAnchor.constraint(equalToConstant: bottomButtonHeight).isActive = true
    buttonsView.isUserInteractionEnabled = true
    
//     we add four buttons to the buttonsView
    
    buttonsView.addSubview(btnEdit)
    buttonsView.addSubview(btnDelete)
    buttonsView.addSubview(btnChat)
    buttonsView.addSubview(btnEditAvailability)
    
    btnEdit.translatesAutoresizingMaskIntoConstraints = false
    btnDelete.translatesAutoresizingMaskIntoConstraints = false
    btnChat.translatesAutoresizingMaskIntoConstraints = false
    btnEditAvailability.translatesAutoresizingMaskIntoConstraints = false
    
    btnEdit.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
    btnDelete.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
    btnChat.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
    btnEditAvailability.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
    
    btnEdit.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
    btnDelete.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
    btnChat.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
    btnEditAvailability.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
    
    btnEdit.topAnchor.constraint(equalTo: buttonsView.topAnchor).isActive = true
    btnDelete.topAnchor.constraint(equalTo: buttonsView.topAnchor).isActive = true
    btnChat.topAnchor.constraint(equalTo: buttonsView.topAnchor).isActive = true
    btnEditAvailability.topAnchor.constraint(equalTo: buttonsView.topAnchor).isActive = true
    
    btnEdit.leftAnchor.constraint(equalTo: buttonsView.leftAnchor, constant: buttonSpacing).isActive = true
    btnChat.leftAnchor.constraint(equalTo: buttonsView.leftAnchor, constant: buttonSpacing*2 + buttonSize).isActive = true
    btnEditAvailability.leftAnchor.constraint(equalTo: buttonsView.leftAnchor, constant: buttonSpacing*3 + buttonSize*2).isActive = true
    btnDelete.leftAnchor.constraint(equalTo: buttonsView.leftAnchor, constant: buttonSpacing*4 + buttonSize*3).isActive = true
    
    btnEdit.setImage(UIImage(named: "editButtonCode"), for: .normal)
    btnDelete.setImage(UIImage(named: "deleteButtonCode"), for: .normal)
    btnChat.setImage(UIImage(named: "chatButtonCode"), for: .normal)
    btnEditAvailability.setImage(UIImage(named: "editAvailabilityButtonCode"), for: .normal)

    btnEdit.addTarget(self, action: #selector(btnEditSelected), for: .touchUpInside)
    btnDelete.addTarget(self, action: #selector(btnDeletePressed), for: .touchUpInside)
    btnChat.addTarget(self, action: #selector(btnChatPressed), for: .touchUpInside)
    btnEditAvailability.addTarget(self, action: #selector(btnEditAvailabilityPressed), for: .touchUpInside)
    
    btnDelete.isUserInteractionEnabled = true
    
    
    let lblChat = UILabel()
    lblChat.text = "Chat"
    lblChat.translatesAutoresizingMaskIntoConstraints = false
    lblChat.textAlignment = .center
    lblChat.font = UIFont.systemFont(ofSize: 10)
    lblChat.textColor = MyVariables.colourLight
    
    lblEdit.text = "Edit"
    lblEdit.translatesAutoresizingMaskIntoConstraints = false
    lblEdit.textAlignment = .center
    lblEdit.font = UIFont.systemFont(ofSize: 10)
    lblEdit.textColor = MyVariables.colourLight
    
    lblDelete.text = "Delete"
    lblDelete.translatesAutoresizingMaskIntoConstraints = false
    lblDelete.textAlignment = .center
    lblDelete.font = UIFont.systemFont(ofSize: 10)
    lblDelete.textColor = MyVariables.colourLight
    
    let lblAEdit = UILabel()
    lblAEdit.text = "Edit Availability"
    lblAEdit.translatesAutoresizingMaskIntoConstraints = false
    lblAEdit.textAlignment = .center
    lblAEdit.font = UIFont.systemFont(ofSize: 10)
    lblAEdit.textColor = MyVariables.colourLight
    
    buttonsView.addSubview(lblChat)
    buttonsView.addSubview(lblEdit)
    buttonsView.addSubview(lblDelete)
    buttonsView.addSubview(lblAEdit)
    
    lblChat.widthAnchor.constraint(equalToConstant: lblSize).isActive = true
    lblDelete.widthAnchor.constraint(equalToConstant: lblSize).isActive = true
    lblAEdit.widthAnchor.constraint(equalToConstant: lblSize).isActive = true
    lblEdit.widthAnchor.constraint(equalToConstant: lblSize).isActive = true
    
    lblChat.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
    lblDelete.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
    lblAEdit.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
    lblEdit.heightAnchor.constraint(equalToConstant: lblHeight).isActive = true
    
    lblChat.topAnchor.constraint(equalTo: buttonsView.topAnchor,constant: buttonSize + 5).isActive = true
    lblDelete.topAnchor.constraint(equalTo: buttonsView.topAnchor,constant: buttonSize + 5).isActive = true
    lblAEdit.topAnchor.constraint(equalTo: buttonsView.topAnchor,constant: buttonSize + 5).isActive = true
    lblEdit.topAnchor.constraint(equalTo: buttonsView.topAnchor,constant: buttonSize + 5).isActive = true
    
    lblEdit.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor, constant: -buttonSize*1.5 - buttonSpacing*1.5).isActive = true
    lblChat.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor,constant: -buttonSize*0.5 - buttonSpacing*0.5).isActive = true
    lblAEdit.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor,constant: buttonSize*0.5 + buttonSpacing*0.5).isActive = true
    lblDelete.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor,constant: buttonSize*1.5 + buttonSpacing*1.5).isActive = true
    
    return containerView
    }()
    
    
//    function to show the instructions for a newly created event
    
    func showInstructions(){
        let firstTimeUser = UserDefaults.standard.string(forKey: "firstCreatingOpeningv2.0001.4") ?? ""
        
//        let firstTimeUser = ""
        
//        if the user hasnt seen the instructions  before and they have been sent to the event from the create event page
        if firstTimeUser == "" && newEventCreated == true{
        coachmarkHelperText = "newEventCreated"
        coachMarksController.start(in: .window(over: self))
//        if the user has invited non users, we show them the popup
            if currentUserSelectedEvent.nonUserNames.count != 0{
        self.inviteFriendsPopUp(notExistingUserArray: currentUserSelectedEvent.nonUserNames, nonExistingNameArray: currentUserSelectedEvent.nonUserNames)
            }
//            set this back to the false status
        newEventCreated = false
//            set the user default so that it doesnt show again
        UserDefaults.standard.setValue("shown", forKey: "firstCreatingOpeningv2.0001.4")
        }
        else if newEventCreated == true && currentUserSelectedEvent.nonUserNames.count != 0{
            self.inviteFriendsPopUp(notExistingUserArray: currentUserSelectedEvent.nonUserNames, nonExistingNameArray: currentUserSelectedEvent.nonUserNames)
        }
    }
    
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
                    self.cvEventInviteesCollectionView.reloadData()
        //            check if the user has responded and adjust the image accordingly
                    self.checkIfUserHasResponded()
                    
//                    we also reset the event details
                    self.lbleventDescription.text = currentUserSelectedEvent.eventDescription
                    self.lbleventLocation.text = currentUserSelectedEvent.eventLocation
                    self.lbleventTime.text = ("\(self.convertToLocalTime(inputTime: currentUserSelectedEvent.eventStartTime)) - \(self.convertToLocalTime(inputTime:(currentUserSelectedEvent.eventEndTime)))")
                    
                    if let index = eventTypeImages.userEventChoices.index(of: currentUserSelectedEvent.eventType){
                            let imageName = eventTypeImages.userEventChoicesImagesColored[index]
                        self.imgEventType.image = UIImage(named: imageName)
                    }
                    else{
                        self.imgEventType.image = UIImage(named: "customColoredCode")
                        }
                    
                    }
                }
    }
    
    
    //    MARK: we need to update this to show if the current user has responded
        func checkIfUserHasResponded(){
            print("running func checkIfUserHasResponded")
    //        get the current event availability
            let availabilityResults = serialiseAvailability(eventID: currentUserSelectedEvent.eventID)
    //        get this users availability
            let filter = availabilityResults.filter {$0.uid == user!}
    //        determine if the user has responded
            if filter.count == 0{
              print("user doesnt have an availability")
//                btnEditAvailability.setImage(UIImage(named: "icons8-unavailable-500"), for: .normal)
                AutoRespondHelper.nonRespondedEventsAuto()
            }
            else if filter[0].userAvailability.count == 0{
              print("user hasnt responded")
//                btnEditAvailability.setImage(UIImage(named: "icons8-unavailable-500"), for: .normal)
                AutoRespondHelper.nonRespondedEventsAuto()
            }
    //            99 is used as a fill factor is the user hasn't responded yet
            else if filter[0].userAvailability[0] == 99 {
               print("user hasnt responded")
//                btnEditAvailability.setImage(UIImage(named: "icons8-unavailable-500"), for: .normal)
                AutoRespondHelper.nonRespondedEventsAuto()
            }
    //            if all the elements in the array meet certain criteria then we want to show no response
            else if filter[0].userAvailability.allSatisfy({$0 == 10}){
               print("user hasnt responded")
//                btnEditAvailability.setImage(UIImage(named: "icons8-unavailable-500"), for: .normal)
                AutoRespondHelper.nonRespondedEventsAuto()
                
            }
            else{
               print("user has responded - filter[0].userAvailability[0] - \(filter[0].userAvailability)")
//                btnEditAvailability.setImage(UIImage(named: "icons8-double-tick-200"), for: .normal)
            }
            
        }
    
//    function to dismiss the event view on pressing the close button
    @objc func closeSeclected(){
        
        self.dismiss(animated: true)
    }
    
    @objc func btnEditPressed(){
        
        
    }
    @objc func btnDeletePressed(){
        print("button delete pressed")
        
//            utils for calling the alert
                    let utils = Utils()
        
        
        let button = AlertButton(title: "OK", action: {
                               print("OK clicked")
            print("User yes on the event delete")
            
            AutoRespondHelper.deleteEventStore(eventID: currentUserSelectedEvent.eventID)
            AutoRespondHelper.deleteEventRequest(eventID: currentUserSelectedEvent.eventID)
            AutoRespondHelper.deleteTemporaryUserEventStore(eventID: currentUserSelectedEvent.eventID)
            AutoRespondHelper.deleteRealTimeDatabaseEventInfo(eventID: currentUserSelectedEvent.eventID)
            AutoRespondHelper.deleteRealTimeDatabaseUserEventLink(eventID: currentUserSelectedEvent.eventID)
            self.eventDeletedNotification(userIDs: currentUserSelectedEvent.users, eventID: currentUserSelectedEvent.eventID)
            
//            post a notification to say there is new data
                NotificationCenter.default.post(name: .newDataLoaded, object: nil)
            
// we need to dismiss the pop-up and reload whatever the user was looking at
            self.dismiss(animated: true)

            
            
        }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
        
        let button2 = AlertButton(title: "Cancel", action: {
            print("cancel delete pressed")
                }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                       
        let alertPayload = AlertPayload(title: "Delete Event!", titleColor: UIColor.red, message: "Are you sure you would like to delete the event? (this can't be undone)", messageColor: MyVariables.colourPlanrGreen, buttons: [button,button2], backgroundColor: UIColor.clear)
                       
            utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0);
        
        
    }
    @objc func btnChatPressed(){
    print("chat button pressed")
//        push the chat page, we push this rather than pop to give the user a better experience
        //        send the user to the edit chat page
            if let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatNavigation") as? UINavigationController{
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
// present the popover
        self.present(popController, animated: true, completion: nil)
                }
   
    }
    
    
    @objc func btnEditAvailabilityPressed(){
        Analytics.logEvent(firebaseEvents.eventEditAvailability, parameters: ["user": user])
        
        print("user selected to edit thier availability")
        
//        send the user to the edit availability page
        if let popController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_editAvailability") as? NL_editAvailability{
                            
        //                    var nav = UINavigationController(rootViewController: popController)
                            // set the presentation style
                            popController.modalPresentationStyle = UIModalPresentationStyle.popover
// present the popover
            self.present(popController, animated: true, completion: nil)
        }
    }
    
    @objc func btnEditSelected(){
        
//       remove any of the data in the setting dates properties
        startDatesNewEvent.removeAll()
        endDatesNewEvent.removeAll()
        print("user selected to edit thier event")
        
//        we set the startDatesChosen
                startDatesChosen = currentUserSelectedEvent.startDateArray
        
        
        //        create a list of the users currently invited to the event
                inviteesNames = currentUserSelectedEvent.currentUserNames
                inviteesUserIDs = currentUserSelectedEvent.users
        //        if non user invitees = none, we need to show nothing
                if currentUserSelectedEvent.nonUserNames.count != 0{
                    print("there is some data in currentUserSelectedEvent")
                    nonUserInviteeNames = currentUserSelectedEvent.nonUserNames
                }
                else{
                    nonUserInviteeNames.removeAll()
                }
                
//        remove the lists being stored with the new invitees in them - we add this here to ensure each time the user selects the edit button these get reset
                contactsSelected.removeAll()
                inviteesNamesNew.removeAll()

        
//        send the user to the edit availability page
        if let popController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_editEvent") as? NL_editEvent{
            
            Analytics.logEvent(firebaseEvents.eventEdit, parameters: ["user": user])
                            
                var nav = UINavigationController(rootViewController: popController)
                            // set the presentation style
                            popController.modalPresentationStyle = UIModalPresentationStyle.popover
// present the popover
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    
    
    func setup(){
        
//        setup some of the event details
        lbleventDescription.text = currentUserSelectedEvent.eventDescription
        lbleventLocation.text = currentUserSelectedEvent.eventLocation
        lbleventTime.text = ("\(convertToLocalTime(inputTime: currentUserSelectedEvent.eventStartTime)) - \(convertToLocalTime(inputTime:(currentUserSelectedEvent.eventEndTime)))")
        
        
//        hide the edit and delete buttons if the user isnt the owner
        if currentUserSelectedEvent.eventOwnerID != user!{
            btnEdit.isHidden = true
            btnDelete.isHidden = true
            lblDelete.isHidden = true
            lblEdit.isHidden = true
        }
        
//        set the text and color for the status label
        if currentUserSelectedEvent.chosenDate != ""{
          lblstatus.text = "Confirmed"
            lblstatus.textColor = MyVariables.colourPlanrGreen
            lblstatus.backgroundColor = MyVariables.colourSelected
//                convert the date into a display date DD MMM
//            let displayDate = dateTZToShortDisplayDate(date: currentUserSelectedEvent.chosenDate)
//            lbleventDate.text = displayDate
//            lbleventDate.isHidden = true
            
        }
        else{
//            we need to check if every user has responded, this can be done, 1. there should be no non user names, 2.we need to loop through each user in the event and check if no every one has responded
            
//            tracking bool for a user not having responded
            var notResponded = false
            
            for user in currentUserSelectedEvent.users{
                print("eventController looping through availability")
//                get the availability
                let availability = CoreDataCode().serialiseAvailabilitywUser(eventID: currentUserSelectedEvent.eventID, userID: user)
//                the user isnt a user, we could not fund them so we set to 0
                if availability.count == 0 || currentUserSelectedEvent.nonUserNames.count != 0{
                    notResponded = true
                }
                else{
//                    we check what was retruned
                    let userAvailabilityArray = availability[0].userAvailability
                    print("eventController userAvailabilityArray \(userAvailabilityArray)")
    //                       2.1 the user has not responded and they have a picture
                    if userAvailabilityArray[0] == 11 ||  userAvailabilityArray[0] == 99{
                        notResponded = true
                    }
                }
            }

//            if the not responded is now set to true we are awaiting responses
            if notResponded == true{
                lblstatus.text = "Awaiting Responses"
                lblstatus.textColor = MyVariables.colourPendingText
                lblstatus.backgroundColor = MyVariables.colourPendingBackground
                lbleventDate.isHidden = true
            }
            else{
                lblstatus.text = "Host to Pick Date"
                lblstatus.textColor = MyVariables.colourPendingText
                lblstatus.backgroundColor = MyVariables.colourPendingBackground
                lbleventDate.isHidden = true
            }
        }
    }
    
//    function to get the positions of the dates when users are available
        func getPositionOfAllAvailable(array: [Float]) -> (allAvailablePositionsArray: [Int], someAvailablePositionsArray: [Int]){
            
            var n = 0
            var allAvailablePositionsArray = [Int]()
            var someAvailablePositionsArray = [Int]()
            
            repeat{

            if array[n] == 1{
                
                allAvailablePositionsArray.append(n)
                
            }
            else{
                someAvailablePositionsArray.append(n)
                
            }
            n = n + 1
       
            }while n <= array.count - 1
            
    //        print("allAvailablePositionsArray: \(allAvailablePositionsArray) someAvailablePositionsArray: \(someAvailablePositionsArray)")
            return (allAvailablePositionsArray, someAvailablePositionsArray)
        }
    
//    function used to get the event results when the user chooses a date
    func getUserAvailabilityArrays(position: Int){
        
        print("running func: getUserAvailabilityArrays - inputs: position: \(position)")
        
        
        var n = 2
        availableUserArray.removeAll()
        nonAvailableArray.removeAll()
        notRespondedArray.removeAll()
        nonUserArray.removeAll()
        let numberOfRows = arrayForEventResultsPageFinal.count - 1
        print("arrayForEventResultsPageFinal \(arrayForEventResultsPageFinal)")
        
        repeat{
            
            if arrayForEventResultsPageFinal[n][position] as! Int == 1{
                
                availableUserArray.append(n)
                
                
            }
           else if arrayForEventResultsPageFinal[n][position] as! Int == 0{
                
                nonAvailableArray.append(n)
                
            }
            else if arrayForEventResultsPageFinal[n][position] as! Int == 11{
                
                nonUserArray.append(n)
                
            }
            else if arrayForEventResultsPageFinal[n][position] as! Int == 10{
                
                notRespondedArray.append(n)
                
            }
            
            n = n + 1
            
        }
        while n <= numberOfRows
        
        
    }
    
    
    //    MARK: coachmarkt controllers
        func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?){
                     
                     let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
                    
                    var hintLabels = [String]()
                    var nextlabels = [String]()
                    
    //        we set the global variable coachmarkHelperText just before we launch the coachMarks, this tell it what we are running
                    if coachmarkHelperText == "newEventCreated"{
                        
                        hintLabels = ["Your friends have been notified of the event, a tick means they've responded","Once you've chosen the date for your event, select it and press save, Planr will notify your friends","If Planr has access to your calendar, your availability will be automatically added, you can also update or override it"]
                        
                        coachViews.bodyView.hintLabel.text = hintLabels[index]
    //                    coachViews.bodyView.nextLabel.text = nextlabels[index]
                    }
                     
                     return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
                     
                 }
                 
                 
                 func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
                     //    Defines where the coachmark will appear
                    var pointOfInterest = UIView()
                    
                    if coachmarkHelperText == "newEventCreated"{
    //                    we set where the coachmarks will appear
                        let hintPositions = [CGRect(x: 0, y: topDistance + 170, width: screenWidth, height: 75),CGRect(x: 0, y: topDistance + 250, width: screenWidth, height: 250),CGRect(x: screenWidth/2, y: screenHeight - 100, width: screenWidth/4, height: screenWidth/4)]
                        
                        pointOfInterest.frame = hintPositions[index]
                    }

                     return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
                 }
                 
                 
                 
             //    The number of coach marks we wish to display
                 func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
                    
                    var numberOfCoachMarks = Int()
                    
                    if coachmarkHelperText == "newEventCreated"{
                        
                       numberOfCoachMarks = 3
                    }
                    
                     return numberOfCoachMarks
                 }
             
         //    When a coach mark appears
             func coachMarksController(_ coachMarksController: CoachMarksController, willShow coachMark: CoachMark, at index: Int){
                 
                 print("Coach Index appeared \(index)")
        
             }
             
         //    when a coach mark dissapears
             func coachMarksController(_ coachMarksController: CoachMarksController, willHide coachMark: CoachMark, at index: Int){
                print("Coach Index disappeared \(index)")
                
                
             }

}


// setup the collectionView
extension NL_eventController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        var numberOfSections = Int()
        
//        there are two sections for the responses collectionView
        if collectionView == cvEventResponses{
        
        numberOfSections = 2
        
        }
        else{
            numberOfSections = 1
            
        }
        return numberOfSections
    }
    

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            print("collectionViewCell invitees reloading")
            var numberOfRows = Int()
            
//            load the collectionView for the invitees
            if collectionView == cvEventInviteesCollectionView{
            
             numberOfRows = currentUserSelectedEvent.currentUserNames.count + currentUserSelectedEvent.nonUserNames.count
            }
                
                
            else if collectionView == cvEventResponses{
                let fullAvailabilityCount = countedResultArrayFraction.filter { $0 == 1 }.count
//        print("fullAvailabilityCount: \(fullAvailabilityCount)")
                        
                let nonFullAvailabilityCount = (countedResultArrayFraction.count - fullAvailabilityCount)
//        print("nonFullAvailabilityCount: \(nonFullAvailabilityCount)")
                if section == 0{
                            
                numberOfRows = fullAvailabilityCount
                            
                        }
                else if section == 1{
                            
                numberOfRows = nonFullAvailabilityCount
                            
                    }
            }
           
            return numberOfRows
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
//            load the collectionView for the invitees
            if collectionView == cvEventInviteesCollectionView{
            let cellId = "cellId"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NL_inviteesCell

                let combinedNameList = currentUserSelectedEvent.currentUserNames + currentUserSelectedEvent.nonUserNames
                var combinedNameListSorted = [""]
                var combinedNameListOthers = [""]
                
        //        we loop through the combined list of users and add the host to the combined list first
                for i in combinedNameList{
        //            if the current user is the host add them to the combinedNameListSorted
                    if i == currentUserSelectedEvent.eventOwnerName{
                        combinedNameListSorted.append(i)
                    }else{
        //                otherwise we add them to the other list
                        combinedNameListOthers.append(i)
                    }
                }
        //        combine the two lists
                combinedNameListSorted = combinedNameListSorted + combinedNameListOthers
        //        add the name of the invitee to the names list
                cell.lblInviteeName.text = combinedNameList[indexPath.row]
        //        hide all host icons for all user
                cell.lblHost.isHidden = true
                cell.layer.borderWidth = 0
                cell.layer.cornerRadius = 0
                
            
                
                if indexPath.row <= currentUserSelectedEvent.currentUserNames.count - 1{
//        we want to set the images for the event invitees
                    let currentUserId = currentUserSelectedEvent.users[indexPath.row]
                    
//                    we want to check if the user has responded and if not display the hourglass
                    let availability = serialiseAvailabilitywUser(eventID: currentUserSelectedEvent.eventID, userID: currentUserId)
                    
// get the users image
                        let imageList = CoreDataCode().fetchImage(uid: currentUserId)
                    
                    var image = Data()
                    if imageList.count != 0{
                        image = imageList[0].userImage!
                    }
//                    loop through each possible user itteration and set the image and status accordingly
                    
//                    1. they are not a user and we want to invite them
                    if availability.count == 0{
                        cell.inviteeStatus.isHidden = false
                        cell.inviteeStatus.image = UIImage(named: "hourGlassCodeCircle")
                        cell.inviteePicture.image = UIImage(data: image)?.alpha(0.5)
                        cell.inviteePicture.isHidden = false
                        cell.eventImageView.isHidden = true
                    }
                    
//                    2. They are a user
                    if availability.count != 0{
//                        check if the user has responded
                        let userAvailabilityArray = availability[0].userAvailability
//                       2.1 the user has not responded and they have a picture, we set their image and blur it
                        if userAvailabilityArray[0] == 11 ||  userAvailabilityArray[0] == 99 && imageList.count != 0{
                            cell.inviteeStatus.isHidden = false
                            cell.inviteeStatus.image = UIImage(named: "hourGlassCodeCircle")
                            cell.inviteePicture.image = UIImage(data: image)?.alpha(0.5)
                            cell.inviteePicture.isHidden = false
                            cell.eventImageView.isHidden = true
                        }
//                        2.2 the user has responded and they do not have a picture
                        else if userAvailabilityArray[0] != 11 &&  userAvailabilityArray[0] != 99 && imageList.count == 0{
                            cell.inviteeStatus.isHidden = true
                            cell.inviteePicture.image = .none
                            cell.inviteePicture.isHidden = false
                            cell.eventImageView.isHidden = false
                        }
//                      2.3 the user has responded and they have a picture
                        else if userAvailabilityArray[0] != 11 &&  userAvailabilityArray[0] != 99 && imageList.count != 0{
                            cell.inviteeStatus.isHidden = true
                            cell.inviteePicture.image = UIImage(data: image)
                            cell.inviteePicture.isHidden = false
                            cell.eventImageView.isHidden = false
                        }
//                        2.4 the user has not responded and they do not have a picture
                        else if userAvailabilityArray[0] == 11 ||  userAvailabilityArray[0] == 99 && imageList.count == 0{
                            cell.inviteeStatus.isHidden = false
                            cell.inviteeStatus.image = UIImage(named: "hourGlassCodeCircle")
                            cell.inviteePicture.image = .none
                            cell.inviteePicture.isHidden = false
                            cell.eventImageView.isHidden = true
                            }
                    }
                    
                }
//                    this invitee isnt a user yet
                else{
//            the invitee isnt a user yet
                    cell.inviteePicture.image = .none
                    cell.inviteeStatus.isHidden = false
//                    set the status image to say invite to Planr
                    let inviteImage = imageWith(name: "Invite", width: 100, height: 100, fontSize: 20, textColor: MyVariables.colourPlanrGreen)
                    cell.inviteeStatus.image = inviteImage
                                    }

        //        show the host label for the first invitee
                if indexPath.row == 0{
                    cell.lblHost.isHidden = false
                }
                
    //        return the cell of the invitee
                return cell
            }
            else{
                let cellId2 = "cellId2"
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId2, for: indexPath) as! NL_eventResultsCell
             
//                get the event results
                allAvailablePositions = getPositionOfAllAvailable(array: countedResultArrayFraction).allAvailablePositionsArray
                
                 someAvailablePositions = getPositionOfAllAvailable(array: countedResultArrayFraction).someAvailablePositionsArray
                
                if indexPath.section == 0{
                   let text = ("\(arrayForEventResultsPageFinal[0][allAvailablePositions[indexPath.row] + 1] as! String)")
                    
                    cell.label.text = text
                    cell.label.isHidden = false
                    cell.label2.isHidden = true
                    cell.label3.isHidden = true
                    
//                    setup the cell itself
                    cell.backgroundColor = MyVariables.colourPlanrGreen
                    cell.layer.borderWidth = 1
                    cell.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
                    cell.layer.cornerRadius = 5
                    cell.layer.masksToBounds = true
                    
//                check if the date has been chosen for this event
                    if currentUserSelectedEvent.chosenDate != ""{
                    let stringDate = dateTZToShortDisplayDate(date: currentUserSelectedEvent.chosenDate)
                        print("currentUserSelectedEvent.chosenDate \(currentUserSelectedEvent.chosenDate) stringDate \(stringDate)")
//                        check if this cell is the chosen date
                        if text == stringDate{
                            cell.backgroundColor = MyVariables.colourSelected
                            cell.label.backgroundColor = MyVariables.colourSelected
                            cell.label.textColor = MyVariables.colourPlanrGreen
                            let newText = ("Confirmed \(arrayForEventResultsPageFinal[0][allAvailablePositions[indexPath.row] + 1] as! String)")
                            cell.label.text = newText
                        }
                    }
                }
                else if indexPath.section == 1{
                   let text = ("\(arrayForEventResultsPageFinal[0][someAvailablePositions[indexPath.row] + 1] as! String)")
                   let fraction = arrayForEventResultsPageFinal[1][someAvailablePositions[indexPath.row] + 1] as! String
                    
                    cell.label2.text = fraction
                    cell.label3.text = text
                    cell.label.isHidden = true
                    cell.label2.isHidden = false
                    cell.label3.isHidden = false
                    
//                    setup the cell itself
                    cell.backgroundColor = .white
                    cell.layer.borderWidth = 1
                    cell.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
                    cell.layer.cornerRadius = 5
                    cell.layer.masksToBounds = true
                    
//                check if the date has been chosen for this event
                    if currentUserSelectedEvent.chosenDate != ""{
                    let stringDate = dateTZToShortDisplayDate(date: currentUserSelectedEvent.chosenDate)
                    print("currentUserSelectedEvent.chosenDate \(currentUserSelectedEvent.chosenDate) stringDate \(stringDate)")
//                        check if this cell is the chosen date
                    if text == stringDate{
                        cell.backgroundColor = MyVariables.colourSelected
                        cell.label3.backgroundColor = MyVariables.colourSelected
                        cell.label3.textColor = MyVariables.colourPlanrGreen
                        cell.label2.backgroundColor = MyVariables.colourSelected
                        cell.label2.textColor = MyVariables.colourPlanrGreen
                        cell.label2.text = "Confirmed"
                        }
                    }
                    
                }
              return cell
            }
        }
        
    // sets the size of the cell
            func collectionView(_ collectionView: UICollectionView,
                                   layout collectionViewLayout: UICollectionViewLayout,
                                   sizeForItemAt indexPath: IndexPath) -> CGSize {
                
                var size = CGSize()
                
//            load the collectionView for the invitees
                if collectionView == cvEventInviteesCollectionView{
                size = CGSize(width: 70, height: 70)
                }
                else if collectionView == cvEventResponses{
                 size = CGSize(width: 72, height: 57)
                    
                }
                   return size
               }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if collectionView == cvEventResponses{
                if kind == UICollectionView.elementKindSectionHeader {
             let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! ResultsSectionHeader

                    if indexPath.section == 0{
                        
                        sectionHeader.label.text = "Everyone is Available"
                        
                    }
                    else{
                        sectionHeader.label.text = "Partial Availability"
                    }
                
                    
             return sectionHeader
        } else { print("this wasnt a collectionView header kind - \(kind)")
             return UICollectionReusableView()
                }}
             return UICollectionReusableView()
        }
    
//    defines the size of the header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView == cvEventResponses{
        
        return CGSize(width: screenWidth - 32, height: 30)
        }
        else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == cvEventInviteesCollectionView{
            
            if currentUserSelectedEvent.eventOwnerID == user{
                
                if indexPath.row == 0{
                    
                }
                else{
        
//        if the user selected an invitee that isnt a user we want to offer the user to invite them
        print("user selected an invitee")
//        check if the selected user wasnt a user
        if indexPath.row >= currentUserSelectedEvent.currentUserNames.count{
            
//        get the nonusers mobile phone numbers from FB
        getNonUsers(eventID: currentUserSelectedEvent.eventID){
        (usersName, usersNumbers) in
                self.inviteFriendsPopUp(notExistingUserArray: usersNumbers, nonExistingNameArray: usersName)
        }
        }
        else{
            print("user selected to remind eventPageEvents")
            let userID = currentUserSelectedEvent.users[indexPath.row]
            let userName = currentUserSelectedEvent.currentUserNames[indexPath.row]
            let eventID = currentUserSelectedEvent.eventID
            reminderPopUp(eventID: eventID, userID: userID, userName: userName)
        }
    }
        }
        }
        else{
//            the user must have selected a date
            print("indexPath: row: \(indexPath.row) section: \(indexPath.section)")
            
//            set the selected date to use as the header on the next page
            
            
            if indexPath.section == 0{
    //            set the selected date to the display date of cell the user selected
    //            selectedDate = ("\(arrayForEventResultsPageFinal[0][allAvailablePositions[indexPath.row] + 1] as! String)")
                
            selectedDateString = ("\(arrayForEventResultsPageFinal[0][allAvailablePositions[indexPath.row] + 1] as! String)")
                
                print("selected Date \(selectedDateString)")
    //            get index of the selected date
    //            let index = arrayForEventResultsPageFinal[0].index(of: selectedDate)
                getUserAvailabilityArrays(position: allAvailablePositions[indexPath.row] + 1)
                
                
            }
            else if indexPath.section == 1{
    //            set the selected date to the display date of cell the user selected
                selectedDateString = ("\(arrayForEventResultsPageFinal[0][someAvailablePositions[indexPath.row] + 1] as! String)")
                print("selected Date \(selectedDateString)")
                getUserAvailabilityArrays(position: someAvailablePositions[indexPath.row] + 1)
            }
            
//            we pop the select a date view controller
            if let popController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventChooseDate") as? NL_eventChooseDate{
                
// present the popover
        self.present(popController, animated: true, completion: nil)
            }
        }
}
}

//class for the section header of the collectionView
class ResultsSectionHeader: UICollectionReusableView {
    
    var label: UILabel = {
    let label: UILabel = UILabel()
    label.textColor = MyVariables.colourLight
    label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    label.sizeToFit()
    label.numberOfLines = 1
    label.textAlignment = .center
    label.lineBreakMode = .byWordWrapping
        return label
      }()
    
    var separatorLine: UIView = {
    let separatorLine: UIView = UIView()
    separatorLine.backgroundColor = MyVariables.colourPlanrGreen
    separatorLine.translatesAutoresizingMaskIntoConstraints = false
        return separatorLine
      }()
    
    var separatorLine2: UIView = {
    let separatorLine: UIView = UIView()
    separatorLine.backgroundColor = MyVariables.colourPlanrGreen
    separatorLine.translatesAutoresizingMaskIntoConstraints = false
        return separatorLine
      }()
    
    

     override init(frame: CGRect) {
          super.init(frame: frame)

          addSubview(label)
        addSubview(separatorLine)
        addSubview(separatorLine2)

          label.translatesAutoresizingMaskIntoConstraints = false
         label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
         label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
          label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
          label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
          label.widthAnchor.constraint(equalToConstant: 170).isActive = true
        
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        separatorLine.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
         separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: self.frame.width/2 - 95).isActive = true
        
        separatorLine2.translatesAutoresizingMaskIntoConstraints = false
        separatorLine2.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        separatorLine2.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
         separatorLine2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLine2.widthAnchor.constraint(equalToConstant: self.frame.width/2 - 95).isActive = true
     }

         required init?(coder aDecoder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
     }