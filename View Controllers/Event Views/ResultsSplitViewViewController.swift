//
//  ResultsSplitViewViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 13/11/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Instructions


var availableUserArray = [Int]()
var nonAvailableArray = [Int]()
var notRespondedArray = [Int]()
var nonUserArray = [Int]()
var myArray = [[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]]
var vc = ViewController()
var eventIDChosen = String()
var inviteesNamesLocation = [String]()
var arrayForEventResultsPageFinal = [[Any]]()
var nonUserInviteeNames = Array<String>()
var numberOfNonInviteeUsers = Int()
var currentAvailability = [AvailabilityStruct]()
var allAvailablePositions = [Int]()
var someAvailablePositions = [Int]()
var selectedDate = String()


class ResultsSplitViewViewController: UIViewController, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    
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
    
    
    @IBOutlet weak var resultsCollectionView: UICollectionView!
    @IBOutlet weak var lblEventDescription: UILabel!
    @IBOutlet weak var lblEventLocation: UILabel!
    @IBOutlet weak var lblEventChosenDate: UILabel!
    @IBOutlet weak var editButtonSettings: UIButton!
    @IBOutlet weak var btnEditAvailability: UIButton!
    @IBOutlet weak var btnInviteNonUsers: UIButton!
    @IBOutlet weak var lblEditEvent: UILabel!
    @IBOutlet weak var lblInviteNonUsers: UILabel!
    @IBOutlet weak var lblEditAvailability: UILabel!
    
    
    @IBOutlet weak var imgMessageNotification: UIImageView!
    
    
    
    let redColour = UIColor.init(red: 255, green: 235, blue: 230)
    let greenColour = UIColor.init(red: 100, green: 250, blue: 100)
    let appColour = UIColor(red: 0, green: 176, blue: 156)
    let orangeColour = UIColor.orange
    var chosenDateForLabel = String()
    
    
    let coachMarksController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        set delegate for the collectionView
        resultsCollectionView.dataSource = self
        resultsCollectionView.delegate = self
        
        navigationItem.titleView = setAppHeader(colour: UIColor.black)
        
        //        ***For coachMarks
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.allowTap = true
        
        //        set label details
        let startTime = convertToLocalTime(inputTime: currentUserSelectedEvent.eventStartTime)
        let endTime = convertToLocalTime(inputTime: currentUserSelectedEvent.eventEndTime)
        lblEventDescription.text = currentUserSelectedEvent.eventDescription
        lblEventLocation.text = currentUserSelectedEvent.eventLocation
        if currentUserSelectedEvent.chosenDate == "2019-01-01" || currentUserSelectedEvent.chosenDate == ""{
            chosenDateForLabel = ("\(startTime) - \(endTime)")
        }
        else{
            chosenDateForLabel = ("\(dateTZToDisplayDate(date: currentUserSelectedEvent.chosenDate)): \(startTime) - \(endTime)")
        }
        lblEventChosenDate.text = chosenDateForLabel
        lblEventChosenDate.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 0.5)
        lblInviteNonUsers.text = "Invite non-users (\(currentUserSelectedEvent.nonUserNames.count))"

//        defines visible buttons based on whether the user created the event
        defineVisibleButtons()

        if summaryView == true{
            
            navigationItem.hidesBackButton = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneSelected))
        }
                
//        MARK: listener to detect when the event availability has been udpated by the user
        NotificationCenter.default.addObserver(self, selector: #selector(updateTables), name: .availabilityUpdated, object: nil)
     
//        end of viewDidLoad
    }
    
//    defines the visible buttons when the event owner or invitee select the event
    
//    Segue to edit the event page
        @objc func doneSelected(){
            performSegue(withIdentifier: "issueWithArraySegue", sender: (Any).self)
  
        }
    
    @objc func updateTables(){
        
        print("updated availability notification triggered")
//        need to pull the new data from CoreData
        currentUserSelectedAvailability = serialiseAvailability(eventID: currentUserSelectedEvent.eventID)
        self.prepareForEventDetailsPageCD(segueName: "", isSummaryView: true, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
            self.resultsCollectionView.reloadData()
        }
    }
    
    @objc func editSelected(){
        
//        performSegue(withIdentifier: "chatSegue", sender: self)
    
        newEventLongitude = 0.0
        newEventLatitude = 0.0
        chosenMapItemManual = ""
        
//        let vc = EventEditViewController()
        
        performSegue(withIdentifier: "splitEditButtonSegue", sender: self)
        
        
    }
    
    
    func defineVisibleButtons(){
        
        if selectEventToggle == 1{
            btnInviteNonUsers.isHidden = false
            editButtonSettings.isHidden = false
            lblInviteNonUsers.isHidden = false
            lblEditEvent.isHidden = false
            
            //        setup the navigation bar chat icon
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editSelected))
            
            //        get user names for those events where we are owner
            
            if currentUserSelectedEvent.nonUserNames.count == 0{
                
              btnInviteNonUsers.isHidden = true
                lblInviteNonUsers.isHidden = true
            }
            else{
                
                btnInviteNonUsers.isHidden = false
                lblInviteNonUsers.isHidden = false
                
            }
            
        }
        
        else{
            btnInviteNonUsers.isHidden = true
            editButtonSettings.isHidden = false
            lblInviteNonUsers.isHidden = true
            lblEditEvent.isHidden = false
        }
    }
    
    
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
        
        print("allAvailablePositionsArray: \(allAvailablePositionsArray) someAvailablePositionsArray: \(someAvailablePositionsArray)")
        return (allAvailablePositionsArray, someAvailablePositionsArray)
    }
    

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
    
    @IBAction func editEventButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "chatSegue", sender: self)
        
        
    }
    
    
    @IBAction func editAvailabilityButtonPressed(_ sender: UIButton) {

        let popOverVC = storyboard?.instantiateViewController(withIdentifier: "editAvailabilityController") as! ManualAvailabilityViewController

        self.addChild(popOverVC)
           popOverVC.view.frame = self.view.frame
           self.view.addSubview(popOverVC.view)
           popOverVC.didMove(toParent: self)
          
    }
    
    
    
    @IBAction func inviteNonUsersPressed(_ sender: UIButton) {
        
//        get the nonusers mobile phone numbers from FB
        
        getNonUsers(eventID: currentUserSelectedEvent.eventID){
           (usersName, usersNumbers) in
    
            self.inviteFriendsPopUp(notExistingUserArray: usersNumbers, nonExistingNameArray: usersName)
        }
    }
    
    
    
    @IBAction func btnAutoResponPressed(_ sender: Any) {
        
    
        uploadCurrentUsersAvailability(eventID: currentUserSelectedEvent.eventID)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        //        check if we should be displaying a new chat notification
                if chatNotificationiDs.contains(currentUserSelectedEvent.eventID) == true{
                    imgMessageNotification.isHidden = false
                    imgMessageNotification.layer.cornerRadius = 15
                    imgMessageNotification.layer.borderWidth = 1.0
                    imgMessageNotification.layer.borderColor = UIColor.red.cgColor
                    imgMessageNotification.layer.masksToBounds = true
                    
        //        remove the event chat notifications for this event
                    removeEventIDChatNotifications(eventID: currentUserSelectedEvent.eventID)
                    
                }
                else{
                   imgMessageNotification.isHidden = true
                }
    }
    
}

extension ResultsSplitViewViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let numberOfSections = 2
        
        return numberOfSections
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        print("countedResultArrayFraction: \(countedResultArrayFraction)")

        
        var numberOfItemsInSection = Int()
        
        let fullAvailabilityCount = countedResultArrayFraction.filter { $0 == 1 }.count
//        print("fullAvailabilityCount: \(fullAvailabilityCount)")
        
        let nonFullAvailabilityCount = (countedResultArrayFraction.count - fullAvailabilityCount)
//        print("nonFullAvailabilityCount: \(nonFullAvailabilityCount)")
        
        if section == 0{
            
            numberOfItemsInSection = fullAvailabilityCount
            
        }
        else if section == 1{
            
          numberOfItemsInSection = nonFullAvailabilityCount
            
        }
        
        print("numberOfItemsInSection: \(numberOfItemsInSection)")
        
        return numberOfItemsInSection
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "resultsCollectionViewCell", for: indexPath) as? ResultsCollectionViewCell else{
            fatalError()
        }
        
         allAvailablePositions = getPositionOfAllAvailable(array: countedResultArrayFraction).allAvailablePositionsArray
        
         someAvailablePositions = getPositionOfAllAvailable(array: countedResultArrayFraction).someAvailablePositionsArray
        
        
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
        
        
        cell.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        cell.layer.shadowRadius = 4
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        cell.backgroundColor = UIColor.white
        

        
        
        if indexPath.section == 0{
            
            cell.lbl1ResultsCollectionView.text = ("\(arrayForEventResultsPageFinal[0][allAvailablePositions[indexPath.row] + 1] as! String)")
            
            cell.lblFraction.isHidden = true

            cell.layer.shadowColor = greenColour.cgColor
        
            
            
        }
        else if indexPath.section == 1{
            
            
            cell.lbl1ResultsCollectionView.text = ("\(arrayForEventResultsPageFinal[0][someAvailablePositions[indexPath.row] + 1] as! String)")
            
            cell.lblFraction.isHidden = false
            
            cell.lblFraction.text = arrayForEventResultsPageFinal[1][someAvailablePositions[indexPath.row] + 1] as! String
            

            cell.layer.shadowColor = orangeColour.cgColor
            
        }

        
        
        return cell
    }
    
    
//    Defines the headers for each section
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionHeaders = ["Everyone's available","Partial availability"]

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionViewHeader", for: indexPath) as? ResultsCollectionReusableView{
            
            
            sectionHeader.lblHeader.text = sectionHeaders[indexPath.section]
            
            
            sectionHeader.lblHeader.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 0.5)
            
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        

        print("indexPath: row: \(indexPath.row) section: \(indexPath.section)")
        
        if indexPath.section == 0{
            
//            set the selected date to the display date of cell the user selected
            selectedDate = ("\(arrayForEventResultsPageFinal[0][allAvailablePositions[indexPath.row] + 1] as! String)")
            print("selected Date \(selectedDate)")
//            get index of the selected date
//            let index = arrayForEventResultsPageFinal[0].index(of: selectedDate)
            getUserAvailabilityArrays(position: allAvailablePositions[indexPath.row] + 1)
            
            
        }
        else if indexPath.section == 1{
//            set the selected date to the display date of cell the user selected
            selectedDate = ("\(arrayForEventResultsPageFinal[0][someAvailablePositions[indexPath.row] + 1] as! String)")
            print("selected Date \(selectedDate)")
            getUserAvailabilityArrays(position: someAvailablePositions[indexPath.row] + 1)
        }

        let popOverVC = storyboard?.instantiateViewController(withIdentifier: "popUpInviteesView") as! SelectDateViewController



     self.addChild(popOverVC)

        popOverVC.view.frame = self.view.frame

        self.view.addSubview(popOverVC.view)

        popOverVC.didMove(toParent: self)
        
    }
    
    
        //    MARK: - three mandatory methods for choach tips
            
            func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
                
                let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
                
                let hintLabels = ["Your friends have been notified of the event, thier availability will automatically be visible here","Once you've chosen the date for your event, select it and press save, we'll notify your friends","Your availability has been automatically determined from the events in your calendar, you can manually amend it here","Each event has a dedicated group chat (for arguing about where to go)"]
                
                let nextlabels = ["OK","OK","OK","OK","OK"]
                
                coachViews.bodyView.hintLabel.text = hintLabels[index]
                
                coachViews.bodyView.nextLabel.text = nextlabels[index]
    //            coachViews.bodyView.nextLabel.isEnabled = false
                
                return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
                
            }
            
            
            func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
                
                
                //    Defines where the coachmark will appear
                let pointOfInterest = UIView()
                
                
                let hintPositions = [CGRect(x: 0, y: topDistance + 195, width: screenWidth, height: screenHeight - topDistance - screenHeight/2),CGRect(x: 0, y: topDistance + 195, width: screenWidth, height: screenHeight - topDistance - screenHeight/2),CGRect(x: screenWidth/2 - 45, y: topDistance + 105, width: 90, height: 80),CGRect(x: screenWidth/2 - 165, y: topDistance + 105, width: 90, height: 80)]
                
                pointOfInterest.frame = hintPositions[index]
                
                
                return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
            }
            
            
            
        //    The number of coach marks we wish to display
            func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
                return 4
            }
        
    //    When a coach mark appears
        func coachMarksController(_ coachMarksController: CoachMarksController, willShow coachMark: CoachMark, at index: Int){
            
            print("Coach Index appeared \(index)")
   
        }
        
    //    when a coach mark dissapears
        func coachMarksController(_ coachMarksController: CoachMarksController, willHide coachMark: CoachMark, at index: Int){
            

           print("Coach Index disappeared \(index)")
            
            
            if index == 3 {
                
    //            add non user invitees
                   if nonExistingUsers.count > 0{
                       
                       self.inviteFriendsPopUp(notExistingUserArray: nonExistingNumbers, nonExistingNameArray: nonExistingUsers)
                    
                    nonExistingUsers.removeAll()
                       
                   }
                   else{
                    
                    
                }
                
            }
            
            else{
                print("coachmarks still to present")
            }
            
        }


            
            //    The coach marks must be called from the viewDidAppear and not the ViewDidLoad.
            override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                            
                
                let createEventCoachMarksCount = UserDefaults.standard.integer(forKey: "createEventCoachMarksCount")
                let createEventCoachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
                
                print("createEventCoachMarksCount \(createEventCoachMarksCount)")
                
                
                if summaryView == true && createEventCoachMarksCount < 2 || createEventCoachMarksPermenant == true{
                
                coachMarksController.start(in: .window(over: self))
                    
                    UserDefaults.standard.set(createEventCoachMarksCount + 1, forKey: "createEventCoachMarksCount")
                    
                }

                else{
                    
    //                add non user invitees
                    if nonExistingUsers.count > 0{
                        
                        self.inviteFriendsPopUp(notExistingUserArray: nonExistingNumbers, nonExistingNameArray: nonExistingUsers)
                        
                        
                        nonExistingUsers.removeAll()
                    }
                    
                }
            }

        
        //    The view coachmarks should be removed once the view is removed
        override func viewWillDisappear( _ animated: Bool) {
            super.viewWillDisappear(animated)

            coachMarksController.stop(immediately: true)
        }
    
    
//    function to remove the event from the list of events with chat notifications
    
    func removeEventIDChatNotifications(eventID: String){
     
        chatNotificationiDs.removeAll{$0 == eventID}
        
    }
    
}



