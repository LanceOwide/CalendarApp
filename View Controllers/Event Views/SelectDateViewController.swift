//
//  SelectDateViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 20/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import Instructions

class SelectDateViewController: UIViewController, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    var dateChosen = ""
    var dateChosenPosition = Int()

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
    
    
    @IBOutlet weak var closeButton: UIButton!
    
    
    @IBOutlet weak var selectDateButton: UIButton!

    
    let redColour = UIColor.init(red: 255, green: 235, blue: 230)
    let greenColour = UIColor.init(red: 191, green: 241, blue: 160)
    let yellowColour = UIColor.init(red: 250, green: 219, blue: 135)
    let orangeColour = UIColor.init(red: 250, green: 200, blue: 135)
    

    @IBOutlet weak private var selectDateTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentDate = arrayForEventResultsPageFinal[0][popUpLocation[1]] as! String
        
        
        let vc = splitViewController
        
        vc?.title = currentDate
        
//        self.title = currentDate
        
        
        //        setup the navigation bar
//        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false)
        
        selectDateTableView.dataSource = self
        selectDateTableView.delegate = self
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.allowTap = true
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDateSelected))
        
        
    buttonSettings(uiButton: closeButton)
    buttonSettings(uiButton: selectDateButton)
        
//    labelSettings(uiLabel: lblCurrentDate)
        
        
    
        
        print("currentDate: \(currentDate)")
        
        
//        lblCurrentDate.text = currentDate
        
        
        visibleButtons()
        
//        end of viewDidLoad
        
    }
    
    
    
//    defines which buttons are visible for the each user
    func visibleButtons(){
    
    if selectEventToggle == 1{
        
        selectDateButton.isHidden = false
        
        }
    else{
        
        selectDateButton.isHidden = true
        
        }
    }
    
    
    
@objc func saveDateSelected() {
    
    
    dateChosen = eventResultsArrayDetails[0][popUpLocation[1]] as! String
    
    let currentDate = arrayForEventResultsPageFinal[0][popUpLocation[1]] as! String
    
    dateChosenPosition = popUpLocation[1] - 1
    
    
    // create the alert
            let alert = UIAlertController(title: "Select Date \(currentDate)", message: "You're about to select this date for your event, would you like to continue?", preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: { action in
                
                
            }))
            alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { action in
                
                print("saveDateSelected \(self.dateChosen)")
                
                let chosenDateYear = String(self.dateChosen[0...3])
                let chosenDateMonth = String(self.dateChosen[5...6])
                let chosenDateDay = String(self.dateChosen[8...9])
                
                let chosenDateYearInt = Int(chosenDateYear)!
                let chosenDateMonthInt = Int(chosenDateMonth)!
                let chosenDateDayInt = Int(chosenDateDay)!
                    
                dbStore.collection("eventRequests").document(eventResultsArrayDetails[3][1] as! String).setData(["chosenDate" : self.dateChosen, "chosenDateMonth" : chosenDateMonthInt, "chosenDateYear" : chosenDateYearInt, "chosenDateDay": chosenDateDayInt], merge: true)
                
                
                        
                dbStore.collection("eventRequests").document(eventResultsArrayDetails[3][1] as! String).setData(["chosenDatePosition" : self.dateChosenPosition], merge: true)
                    
                    
                print("date submitted to the eventRequest table: \(self.dateChosen)")
                    
                    //            Adds the chosen date to each individuals user event store
                    dbStore.collection("userEventStore").whereField("eventID", isEqualTo: eventResultsArrayDetails[3][1] as! String).getDocuments { (querySnapshot, error) in
                        if error != nil {
                            print("Error getting documents: \(error!)")
                        }
                        else {
                            
                            for document in querySnapshot!.documents {
                                //                    print("\(document.documentID) => \(document.data())")
                                
                                var documentIdentifier : String
                                
                                documentIdentifier = document.documentID
                                

                                
                                dbStore.collection("userEventStore").document(documentIdentifier).setData(["chosenDate" : self.dateChosen, "chosenDateMonth" : chosenDateMonthInt, "chosenDateYear" : chosenDateYearInt, "chosenDateDay": chosenDateDayInt, "chosenDateSeen": false], merge: true)
                                
                                
                                
                                print("chosen dates added to the userEventStore")
                            
                                
                            }}
                        
                    }
                    
                    
                self.performSegue(withIdentifier: "dateChosenSave", sender: Any.self)
                    
            }))
            
            // show the alert
            
            self.present(alert, animated: true, completion: nil)

    }
    
    
    
    @IBAction func closeView(_ sender: UIButton) {
        
        self.view.removeFromSuperview()
        
    }
    
    
    @IBAction func btnSelectDateSelected(_ sender: UIButton) {
        
     saveDateSelected()
        
    }
    
    
    
//    Mark: Defines where the coachmark will appear
    
        var pointOfInterest = UIView()
        let coachMarksController = CoachMarksController()
        
        func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
            
            
            let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
            

            let hintLabels = ["Invitees availability status is displayed here","Have you chosen this as the date for your event? Select it to notify your invitees"]
            
            let nextlabels = ["OK","OK"]
            
            coachViews.bodyView.hintLabel.text = hintLabels[index]
            
            coachViews.bodyView.nextLabel.text = nextlabels[index]
    //        coachViews.bodyView.nextLabel.isEnabled = false
            
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
            
        }
        
        

        func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
            
            let hintPositions = [CGRect(x: 50, y: topDistance + 100, width: screenWidth - 100, height: screenHeight - topDistance - 155 - 100),CGRect(x: screenWidth - 100, y: topDistance + 50, width: 50, height: 50)]
            
            pointOfInterest.frame = hintPositions[index]
            
            return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
        }
        
        
        
        func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
            
            return 2
            
        }
        
            //    The coach marks must be called from the viewDidAppear and not the ViewDidLoad.
            override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                let manualEditCoachMarksCount = UserDefaults.standard.integer(forKey: "manualEditCoachMarksCount")
                let createEventCoachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
                
                print("manualEditCoachMarksCount \(manualEditCoachMarksCount)")
                
                
                if manualEditCoachMarksCount < 3 || createEventCoachMarksPermenant == true{
                
                coachMarksController.start(in: .window(over: self))
                    
                    UserDefaults.standard.set(manualEditCoachMarksCount + 1, forKey: "manualEditCoachMarksCount")
                    
                }
                else{
                    
                }
            }
            
            
            
        //    The view coachmarks should be removed once the view is removed
            override func viewWillDisappear( _ animated: Bool) {
                super.viewWillDisappear(animated)

                self.coachMarksController.stop(immediately: true)
            }
            

              
    
    }


extension SelectDateViewController:UITableViewDelegate, UITableViewDataSource{
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         
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
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var headersList = [String]()
        headersList.removeAll()
        
        let currentDate = arrayForEventResultsPageFinal[0][popUpLocation[1]] as! String
        
        
        let headersListStatic = ["Available - \(currentDate)","Unavailable - \(currentDate)","Not Responded - \(currentDate)","Non User - \(currentDate)"]
        
        
        
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
        
        
        
        return headersList[section]
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
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
        
        
        print("number of sections n: \(n)")
        
        
        return n
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = selectDateTableView.dequeueReusableCell(withIdentifier: "chooseDateCell", for: indexPath)
        
        var arrays = [[Int]]()
        arrays.removeAll()
        
        if availableUserArray.count > 0{
            
            arrays.append(availableUserArray)
            
        }
        if nonAvailableArray.count > 0 {
            
            arrays.append(nonAvailableArray)
            
        }
        if notRespondedArray.count > 0{

           
            arrays.append(notRespondedArray)
            
        }
        if nonUserArray.count > 0{
            
            arrays.append(nonUserArray)

        }

//        if indexPath.section == 0{
                   
            cell.textLabel?.text = arrayForEventResultsPageFinal[arrays[indexPath.section][indexPath.row]][0] as? String
                   
//               }
//               else if indexPath.section == 1{
//
//            cell.textLabel?.text = arrayForEventResultsPageFinal[nonAvailableArray[indexPath.row]][0] as? String
//
//                   }
//               else if indexPath.section == 2{
//
//            cell.textLabel?.text = arrayForEventResultsPageFinal[nonUserArray[indexPath.row]][0] as? String
//
//               }
//               else if indexPath.section == 3{
//
//            cell.textLabel?.text = arrayForEventResultsPageFinal[availableUserArray[indexPath.row]][0] as? String
//
//               }
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.clipsToBounds = true

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

 

    }
    
  


}
