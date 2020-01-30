//
//  ManualAvailabilityViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 21/10/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import Instructions

var currentUsersAvailability = [Int]()

class ManualAvailabilityViewController: UIViewController,CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    
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
    
    
    @IBOutlet weak var availabilityCollectionView: UICollectionView!
    
    
    var temporaryCurrentUsersAvailability = [Int]()
    
    @IBOutlet weak var btnClose: UIButton!
    
    
    @IBOutlet weak var btnSave: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        availabilityCollectionView.delegate = self
        availabilityCollectionView.dataSource = self
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.allowTap = true
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        

        //        setup the navigation controller Planr text
        
        navigationItem.titleView = setAppHeader(colour: UIColor.black)
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        
        
        temporaryCurrentUsersAvailability = currentUsersAvailability
        print("temporaryCurrentUsersAvailability: \(temporaryCurrentUsersAvailability)")
        
        buttonSettings(uiButton: btnClose)
        buttonSettings(uiButton: btnSave)
                
    }
    
    
    @objc func saveAvailability() {
        commitUserAvailbilityData(userEventStoreID: currentUserAvailabilityDocID, finalAvailabilityArray2: temporaryCurrentUsersAvailability)
        
        let eventID = eventResultsArrayDetails[3][1] as! String
        let users = eventResultsArrayDetails[8][0] as! [String]
        let eventOwner = users[0]
        
        prepareForEventDetailsPage(eventID: eventID, isEventOwnerID: eventOwner, segueName: "", isSummaryView: false, performSegue: false){
            
            self.view.removeFromSuperview()
            
        }
  
    }
    
    
    
    @IBAction func btnCloseAvailabilityPressed(_ sender: UIButton) {
//        removes the view from the superView that it showing it
        

        self.view.removeFromSuperview()
    }
    
    
    
    @IBAction func btnSavePressed(_ sender: UIButton) {
     saveAvailability()
    }
    


    
    //    Defines where the coachmark will appear
    var pointOfInterest = UIView()
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        

        let hintLabels = ["Select each date to change it's availability, press save when finished"]
        
        let nextlabels = ["OK"]
        
        coachViews.bodyView.hintLabel.text = hintLabels[index]
        
        coachViews.bodyView.nextLabel.text = nextlabels[index]
//        coachViews.bodyView.nextLabel.isEnabled = false
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
    }
    
    

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        
        let hintPositions = [CGRect(x: 50, y: topDistance + 155, width: screenWidth - 100, height: 50)]
        
        pointOfInterest.frame = hintPositions[index]
        
        return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
    }
    
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        
        return 1
        
    }
    
        //    The coach marks must be called from the viewDidAppear and not the ViewDidLoad.
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            let selectDateCoachMarksCount = UserDefaults.standard.integer(forKey: "selectDateCoachMarksCount")
            let createEventCoachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
            
            print("selectDateCoachMarksCount \(selectDateCoachMarksCount)")
            
            
            if selectDateCoachMarksCount < 3 || createEventCoachMarksPermenant == true{
            
            coachMarksController.start(in: .window(over: self))
                
                UserDefaults.standard.set(selectDateCoachMarksCount + 1, forKey: "selectDateCoachMarksCount")
                
            }
            else{
                
            }
        }
        
        
        
    //    The view coachmarks should be removed once the view is removed
        override func viewWillDisappear( _ animated: Bool) {
            super.viewWillDisappear(animated)

            self.coachMarksController.stop(immediately: true)
        }
        

        let coachMarksController = CoachMarksController()

}




// Mark -collectionView extension


extension ManualAvailabilityViewController:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    
    //    number of rows
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            
            let numberOfRows = temporaryCurrentUsersAvailability.count
            print("numberOfRows: \(numberOfRows)")
            
            return numberOfRows
        }
        
        
        //    number of columns
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            

            
             return 2
         }
         
    
    
         func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            guard let cell = availabilityCollectionView.dequeueReusableCell(withReuseIdentifier: "availabilityCell", for: indexPath) as? AvailabilityCollectionViewCell else{
                
                print("could not deque the cell")
                return UICollectionViewCell()
                
                
            }
            
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 0.5)
            cell.layer.shadowRadius = 4
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
             
            
    //        set the second column equal to the dates
            if indexPath.row == 1{
                
                cell.collectionViewLabel.text = arrayForEventResultsPageFinal[0][indexPath.section + 1] as? String
                
                cell.collectionViewLabel.font = UIFont(name: "Helvetica Neue", size: 15)
                
                cell.collectionViewLabel.textAlignment = .left
                

                cell.backgroundColor = UIColor.white
                cell.layer.borderWidth = 0
                cell.layer.borderColor = UIColor.clear.cgColor

            }
            
            
            if indexPath.row == 0{
                
                
                let redColour = UIColor.init(red: 255, green: 235, blue: 230)
                let greenColour = UIColor.init(red: 191, green: 241, blue: 160)
                

                
                    cell.collectionViewLabel.textAlignment = .left
//                cell.collectionViewLabel.translatesAutoresizingMaskIntoConstraints = false
                
                if temporaryCurrentUsersAvailability[indexPath.section] == 0 {
                    
                    
                    
                    cell.collectionViewLabel.text = "  ❌   "
                    
                    cell.collectionViewLabel.font = UIFont(name: "Helvetica Neue", size: 15)
                    
                    
                    cell.backgroundColor = redColour
                    
                    cell.layer.borderWidth = 3
                    

                }
                
                
                if temporaryCurrentUsersAvailability[indexPath.section] == 1 {
                    
                    cell.collectionViewLabel.text = "  ✔️   "
                    cell.backgroundColor = greenColour
                    
                    cell.collectionViewLabel.font = UIFont(name: "Helvetica Neue", size: 15)
                    
    
                }
                
                
                if temporaryCurrentUsersAvailability[indexPath.section] == 10{
                
                    cell.collectionViewLabel.font = UIFont(name: "Helvetica Neue", size: 20)
                cell.collectionViewLabel.text = "   ？ "
      
                cell.backgroundColor = UIColor.lightGray
                
                }
            }

            return cell
         }
        
    
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            var cellSize = CGSize()
            
            
            if indexPath.row == 1{
              cellSize = CGSize(width: 200 , height: 50)
            }
                
                
            if indexPath.row == 0{
                cellSize = CGSize(width: 50 , height: 50)
            }
            
            return cellSize
            
            }
        
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            print("User Selected: row: \(indexPath.row) section: \(indexPath.section)")
            
            if temporaryCurrentUsersAvailability[indexPath.section] == 0{
                print("Currently unavailable")
                
               temporaryCurrentUsersAvailability[indexPath.section] = 1
                
                availabilityCollectionView.deselectItem(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
                availabilityCollectionView.reloadData()
                
            }
            else if temporaryCurrentUsersAvailability[indexPath.section] == 1{
                print("Currently available")
                
                temporaryCurrentUsersAvailability[indexPath.section] = 10
                availabilityCollectionView.deselectItem(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
                availabilityCollectionView.reloadData()
                
            }
            else if temporaryCurrentUsersAvailability[indexPath.section] == 10{
                
                print("Currently not responded")
                
                temporaryCurrentUsersAvailability[indexPath.section] = 0
                availabilityCollectionView.deselectItem(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
                availabilityCollectionView.reloadData()
                
            }
            print("temporaryCurrentUsersAvailability: \(temporaryCurrentUsersAvailability)")
            availabilityCollectionView.reloadData()
            
            
        }
    
    //    Defines the headers for each section
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionHeaders = ["Edit Your Availability"]

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "editCollectionViewHeader", for: indexPath) as? EditAvailabilityCollectionReusableView{
            
            if indexPath.section == 0{
                
                sectionHeader.lblEditAvailability.isHidden = false
            
            sectionHeader.lblEditAvailability.text = sectionHeaders[indexPath.section]
            
            
            sectionHeader.lblEditAvailability.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 0.5)
            
            }
            else{
                sectionHeader.lblEditAvailability.isHidden = true
            }
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var headerSize = CGSize()
        
        if section == 0 {
        
            headerSize = CGSize(width: collectionView.bounds.size.width, height: 50)
            
        }
        else{
            
            headerSize = CGSize(width: collectionView.bounds.size.width, height: 0)
        }
        
        return headerSize
    }
    
    
}
