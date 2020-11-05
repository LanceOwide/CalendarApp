//
//  NL_CreateEvent.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/18/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit


var newEventDescription = String()
var newEventLocation = String()
var newEventStartTime = "06:00"
var newEventEndTime = "06:00"
var newEventStartTimeLocal = "06:00"
var newEventEndTimeLocal = "06:00"
//stores the the name of the pictures used to describe the event type
var eventType = String()
var eventTypeInt = Int()
// list of the images names used for the eventType


//variable to hold the
var searchPeriodText = String()

//    variables to hold the start and end dates for the potential dates the user has chosen
var startDatesChosen = [String]()
var endDatesChosen = [String]()

class NL_CreateEvent: UIViewController {
    
//    get the top distance of the page
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
    
//    userful varialbes
    var selectedArray = [0,0,0,0,0,0,0,0]
    var collectionview: UICollectionView!
    let cellId = "cellId"
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
        setupThePage()
//        MUST ADD subview
        view.addSubview(inputTopView)
        view.addSubview(inputBottomView)
        
//        this stops the viewcontroller from being dismissed when the user swipes down
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        // Set its constraint to display it on screen
        inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: barHeight).isActive = true
        inputTopView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputTopView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
//        setup view for collectionView
        inputBottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputBottomView.topAnchor.constraint(equalTo: view.topAnchor, constant: barHeight + 100).isActive = true
        
        
//        reset the gloabl arrays
         calendarArray2.removeAll()
         calendarTitleArray.removeAll()
        searchPeriodChoicesSelected.removeAll()
        daysOfTheWeekSelected.removeAll()
        startDatesChosen.removeAll()
        endDatesChosen.removeAll()
        
//        we reset the start time to ensure we don't acidentally use the last event start time the user opened
        currentUserSelectedEvent.eventStartTime = ""
    }
    
   
    
    func setupThePage(){
        
//        set the title for the page
    let title = "Create Event"
    self.title = title
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = MyVariables.colourPlanrGreen
        navigationItem.backBarButtonItem = backItem
        
        
        //            create a button to dismiss the  viewController
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem?.tintColor = MyVariables.colourPlanrGreen
    }
    
    
//    create the progress bar and title
    lazy var inputTopView: UIView = {
        print("setting up the inputTopView")
//        set the variables for the setup
        let progressAmt = 0.25
        let headerLabelText = "Quick Create Menu"
        let numberLabelText = "01"
        let instructionLabelText = "Choose one of the below"
     
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
        headerLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 16 + 30).isActive = true
        headerLabel.widthAnchor.constraint(equalToConstant: screenWidth - 30 - 16).isActive = true
        headerLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
        headerLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
//        set the instruction
        let instructionLabel = UILabel()
        instructionLabel.text = instructionLabelText
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        instructionLabel.textColor = MyVariables.colourLight
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(instructionLabel)
        instructionLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 16 + 30).isActive = true
        instructionLabel.widthAnchor.constraint(equalToConstant: screenWidth - 30 - 16).isActive = true
        instructionLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40).isActive = true
        instructionLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return containerView
    }()
    
//    setup the view of the collectionview
    
    
    lazy var inputBottomView: UIView = {
        print("screenHeight - topDistance - 100 \(screenHeight - topDistance - 100)")
      
        //   setup the view for holding the progress bar and title
        let containerView2 = UIView()
        containerView2.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: screenHeight - topDistance - 100)
        containerView2.backgroundColor = UIColor.white
        containerView2.translatesAutoresizingMaskIntoConstraints = false
        
        //        trying to add a top view
        let topView = UIView()
        topView.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: screenHeight - topDistance - 100)
        topView.backgroundColor = UIColor.white
        topView.translatesAutoresizingMaskIntoConstraints = false
        containerView2.addSubview(topView)
        topView.leftAnchor.constraint(equalTo: containerView2.leftAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: containerView2.topAnchor).isActive = true
        topView.widthAnchor.constraint(equalTo: containerView2.widthAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: screenHeight - topDistance - 100).isActive = true
        
        //        setup the collectionView 
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = .white
        collectionview.register(createEventCell.self, forCellWithReuseIdentifier: cellId)
        collectionview.isScrollEnabled = true
        collectionview.isUserInteractionEnabled = true
        collectionview.allowsSelection = true
        collectionview.allowsMultipleSelection = false
        topView.addSubview(collectionview)
        collectionview.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 16).isActive = true
        collectionview.widthAnchor.constraint(equalToConstant: screenWidth - 16 - 16).isActive = true
        collectionview.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        collectionview.heightAnchor.constraint(equalToConstant: screenHeight - topDistance - 100).isActive = true
        
        return containerView2
    }()
//    add the inputTopView
    override var inputAccessoryView: UIView? {
        get {
            return inputTopView
        }
    }
    //    function to add the next button when the user selects a
        func createNextButton(){
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
            navigationItem.rightBarButtonItem?.tintColor = MyVariables.colourPlanrGreen
            
        }
        
    //    function for taking the user to the next page
        @objc func nextTapped(){
          performSegue(withIdentifier: "toCreateEvent2", sender:self)
            
        }
    
    //    function for taking the user to the next page
    @objc func closeTapped(){
        self.dismiss(animated: true)
        
    }
    
    
}

//extension for the collectionview containing the event choices
extension NL_CreateEvent: UICollectionViewDelegate, UICollectionViewDataSource {
    
//    number of selections for the user
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let nummberOfItems = eventTypeImages.userEventChoices.count
        print("number of cells \(nummberOfItems)")
        return nummberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! createEventCell
        
        cell.eventImageView.image = UIImage(named: eventTypeImages.userEventChoicesimages[indexPath.row])
        cell.cellText.text = eventTypeImages.userEventChoices[indexPath.row]
        
//        set the border colour to the cell based on the selectedArray, which is set when the user selects a cell
        if selectedArray[indexPath.row] == 1{
            cell.eventImageView.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
            cell.eventImageView.layer.borderWidth = 3
        }
        else{
            cell.eventImageView.layer.borderColor = MyVariables.colourBackground.cgColor
            cell.eventImageView.layer.borderWidth = 0
        }

    
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        to track when a user has selected a cell we use the following array
        selectedArray = [0,0,0,0,0,0,0,0]
//        set the selected row to 1
        selectedArray[indexPath.row] = 1
        
//        add the next button so the user can progress
        createNextButton()
        
//        set the eventType to the string of the event type being used for that eventType
        eventType = eventTypeImages.userEventChoices[indexPath.row]
        eventTypeInt = indexPath.row
        
//        set the times for the event
        newEventStartTimeLocal = eventTypeImages.userEventChoicesStartTime[indexPath.row]
        newEventEndTimeLocal = eventTypeImages.userEventChoicesEndTime[indexPath.row]
        
//        we set the background color for the cell in the cell setup, so we must reload the collectionview
        collectionView.reloadData()
 
    }


}

extension NL_CreateEvent: UICollectionViewDelegateFlowLayout {

// sets the size of the cell
func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
       return CGSize(width: 100, height: 100)
   }

func collectionView(_ collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
                    insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
}

func collectionView(_ collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
                    minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
}

func collectionView(_ collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
                    minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 20
}
}
