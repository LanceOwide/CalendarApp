//
//  NL_editAvailability.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 9/13/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import Firebase

class NL_editAvailability: UIViewController {

    /// Get distance from top, based on status bar and navigation
    public var topDistance : CGFloat{
         get{
             if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                 return 0
             }else{
                let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
                let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                print("statusBarHeight \(statusBarHeight) barHeight \(barHeight)")
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
    
    
    //    add the collectionView
    var availabilityCollectionView: UICollectionView!
    let cellId = "cellId"
    var btnSave = UIButton()
//    to hold the users temporary availability before we save it
    var temporaryCurrentUsersAvailability = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
       //        MUST ADD subview
        view.addSubview(inputTopView)
//        view.addSubview(inputBottomView)
        
        // Set its constraint to display it on screen
        inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: barHeight).isActive = true
        inputTopView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputTopView.heightAnchor.constraint(equalToConstant: screenHeight - barHeight).isActive = true
        
        
        //        set the users availability
        prepareUserAvailability{
            self.availabilityCollectionView.reloadData()
        }

    }
    
    
    //    create the progress bar and title
        lazy var inputTopView: UIView = {
            print("setting up the inputTopView")
    //        set the variables for the setup
            let pageTitleHeight = CGFloat(50)
            let titleHeight = CGFloat(30)
            let sideInset = CGFloat(16)
            let closeSize = CGFloat(28)
            let spacer = CGFloat(100)
            let spacerTop = CGFloat(50)
            let saveButtonHeight = CGFloat(100)
            let btnSaveWidth = CGFloat(screenWidth - 75)
            let btnSaveHeight = CGFloat(52)


         
            //   setup the view for holding the progress bar and title
            let containerView = UIView()
            containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight - barHeight)
            containerView.backgroundColor = UIColor.white
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
    //        trying to add a top view
            let topView = UIView()
            topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight - barHeight)
            topView.backgroundColor = UIColor.white
            topView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(topView)
            topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            topView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            

//            page title
            let pageTitle = UILabel()
            topView.addSubview(pageTitle)
            pageTitle.text = "Choose Your Available Dates"
            pageTitle.textAlignment = .center
            pageTitle.font = UIFont.systemFont(ofSize: 18)
            pageTitle.translatesAutoresizingMaskIntoConstraints = false
            pageTitle.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
            pageTitle.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset).isActive = true
            pageTitle.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
            pageTitle.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
            
//            add the close button
            let closeButton = UIButton()
            topView.addSubview(closeButton)
            closeButton.setImage(UIImage(named: "closeButtonCode"), for: .normal)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset).isActive = true
            closeButton.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset).isActive = true
            closeButton.widthAnchor.constraint(equalToConstant: closeSize).isActive = true
            closeButton.heightAnchor.constraint(equalToConstant: closeSize).isActive = true
            closeButton.addTarget(self, action: #selector(closeSeclected), for: .touchUpInside)
            
            
//        setup the collectionView
             let layout = UICollectionViewFlowLayout()
             layout.scrollDirection = .vertical
            availabilityCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
             availabilityCollectionView.register(NL_editAvailabilityCell.self, forCellWithReuseIdentifier: cellId)
             availabilityCollectionView.backgroundColor = .white
             availabilityCollectionView.isScrollEnabled = true
             availabilityCollectionView.isUserInteractionEnabled = true
            availabilityCollectionView.delegate = self
            availabilityCollectionView.dataSource = self
            topView.addSubview(availabilityCollectionView)
            availabilityCollectionView.leftAnchor.constraint(equalTo: topView.leftAnchor,constant: sideInset).isActive = true
            availabilityCollectionView.topAnchor.constraint(equalTo: topView.topAnchor,constant: titleHeight + spacer).isActive = true
             availabilityCollectionView.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
            availabilityCollectionView.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: saveButtonHeight + spacerTop).isActive = true
            availabilityCollectionView.translatesAutoresizingMaskIntoConstraints = false
            
            topView.addSubview(btnSave)
            btnSave.translatesAutoresizingMaskIntoConstraints = false
            btnSave.setTitle("Save", for: .normal)
            btnSave.titleLabel?.textAlignment = .center
            btnSave.setTitleColor(.white, for: .normal)
            btnSave.backgroundColor = MyVariables.colourPlanrGreen
            btnSave.widthAnchor.constraint(equalToConstant: btnSaveWidth).isActive = true
            btnSave.heightAnchor.constraint(equalToConstant: btnSaveHeight).isActive = true
            btnSave.bottomAnchor.constraint(equalTo: topView.bottomAnchor,constant: -spacer).isActive = true
            btnSave.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
            btnSave.addTarget(self, action: #selector(saveSelected), for: .touchUpInside)
            
            
            return containerView
        }()
        
    //    setup the view of the collectionview
    
    //    function to dismiss the event view on pressing the close button
    @objc func closeSeclected(){
        
        self.dismiss(animated: true)
    }
    
    @objc func saveSelected(){
        print("user selected save")
        Analytics.logEvent(firebaseEvents.eventEditAvailability, parameters: ["Test": ""])
        
        let eventID = currentUserSelectedEvent.eventID
        
        let availability = AutoRespondHelper.serialiseAvailabilitywUserAuto(eventID: eventID, userID: user!)
        
        if availability.count == 0{
//            we need add an error messsage
            self.dismiss(animated: true)
        }
        else{
            let documentID = availability[0].documentID
              
              commitUserAvailbilityData(userEventStoreID: documentID, finalAvailabilityArray2: temporaryCurrentUsersAvailability, eventID: eventID)
              
              
              
              updateUsersAvailability(documentID: documentID, eventID: eventID, uid: user!, userAvailability: temporaryCurrentUsersAvailability)

              currentUserSelectedAvailability = serialiseAvailability(eventID: currentUserSelectedEvent.eventID)
              prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: true){
//                post a notification to ask the eventView to reload
                NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                  
                  self.dismiss(animated: true)
              }
        }
        
    }
    
    
    //    function to create an array of not responded users, for each
        func prepareUserAvailability(completionHandler: @escaping () -> ()){
            print("running func - createArrayIfUserHasntResponded")
            currentUserSelectedAvailability = serialiseAvailability(eventID: currentUserSelectedEvent.eventID)
    //        get the users current availability
            let t = currentUserSelectedAvailability.filter(){$0.uid == user!}
            print("t \(t)")
            
//            check that the user has an availability for the event if not we run somehting went wrong
            if t.count == 0{
                completionHandler()
                somethingWentWrong(eventID: currentUserSelectedEvent.eventID, eventInfo: true, availabilityInfo: true, loginfo: "running func - createArrayIfUserHasntResponded - no availability returned for the user", viewController: self)
                
            }
            else{
            let currentUserAvailability = t[0].userAvailability
            print("currentUserAvailability: \(currentUserAvailability)")

    //        we need to check if the user hasn't responded to the event temporaryCurrentUsersAvailability
            if currentUserAvailability[0] == 99{

            let numberOfDays = currentUserSelectedEvent.endDateArray.count
            var nonRespondedArray = [Int]()
            var n = 0
            
    //        add 10 to the array for each day in the array
            while n < numberOfDays{
                
                nonRespondedArray.append(10)
                n = n + 1
            }
            temporaryCurrentUsersAvailability = nonRespondedArray
                completionHandler()
            }
            else{
    //            the use has responded and their availability is set to their response
                temporaryCurrentUsersAvailability = currentUserAvailability
                completionHandler()
            }
            }
        }
}
    

//manage the collectionView
extension NL_editAvailability: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let numberOfDates = temporaryCurrentUsersAvailability.count
        
        return numberOfDates
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NL_editAvailabilityCell
        
//        date adjustment for display
        let dateFormatterTZ = DateFormatter()
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterDisplay = DateFormatter()
        dateFormatterDisplay.dateFormat = "dd MMM"
        dateFormatterDisplay.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatterTZ.date(from: currentUserSelectedEvent.startDateArray[indexPath.row])
        let dateString = dateFormatterDisplay.string(from: date!)
        
        cell.label.text = dateString
        cell.clipsToBounds = true
        cell.label.clipsToBounds = true
        
        if temporaryCurrentUsersAvailability[indexPath.row] == 0 {
            cell.label.backgroundColor = .white
            cell.label.textColor = MyVariables.colourPlanrGreen
                    }
                    
        if temporaryCurrentUsersAvailability[indexPath.row] == 1 {
            cell.label.backgroundColor = MyVariables.colourPlanrGreen
            cell.label.textColor = .white
                    }
                    
                    
        if temporaryCurrentUsersAvailability[indexPath.row] == 10 || temporaryCurrentUsersAvailability[indexPath.row] == 99{
            cell.label.backgroundColor = .lightGray
            cell.label.textColor = .white
                    }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        we choose not to cycle through the unchosen selection, only letting the user chose 1 or 0.
        
        if temporaryCurrentUsersAvailability[indexPath.row] == 0{
            print("Currently unavailable")
            
           temporaryCurrentUsersAvailability[indexPath.row] = 1
            
            availabilityCollectionView.deselectItem(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
            availabilityCollectionView.reloadData()
            
        }
        else if temporaryCurrentUsersAvailability[indexPath.row] == 1{
            print("Currently available")
            
            temporaryCurrentUsersAvailability[indexPath.row] = 0
            availabilityCollectionView.deselectItem(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
            availabilityCollectionView.reloadData()
            
        }
        else if temporaryCurrentUsersAvailability[indexPath.row] == 10 || temporaryCurrentUsersAvailability[indexPath.section] == 99{
            
            print("Currently not responded")
            
            temporaryCurrentUsersAvailability[indexPath.row] = 1
            availabilityCollectionView.deselectItem(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
            availabilityCollectionView.reloadData()
            
        }
        print("temporaryCurrentUsersAvailability: \(temporaryCurrentUsersAvailability)")
        availabilityCollectionView.reloadData()
    }
    
// sets the size of the cell
    func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize()
        size = CGSize(width: 72, height: 57)
        
        return size
    }
    

}



