//
//  NL_createEventDetail.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/19/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import Firebase


var startDatesNewEvent = [String]()
var endDatesNewEvent = [String]()


class NL_createEventDetail: UIViewController, UIPopoverPresentationControllerDelegate{
    
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
    
//    we set the inputs as global variables such that we can access their contents outside the setup
    var locationInput = UITextField()
    var titleInput = UITextField()
    var startTimeInput = UITextField()
    var endTimeInput = UITextField()
    var searchPeriodInput = UITextField()
    var searchLabel = UILabel()
    var dateFormatter = DateFormatter()
    var collectionviewSearch: UICollectionView!
    var collectionviewDaysOfTheWeek: UICollectionView!
    var collectionViewDates: UICollectionView!
    let cellId = "cellId2"
    let cellId2 = "cellId3"
    let cellId3 = "cellId4"
    let searchPeriodChoices = ["1 Week","2 Weeks","1 Month","2 Months","3 Months"]
    let daysOfTheWeek = ["Mon","Tues","Wed","Thu","Fri","Sat","Sun"]
    var searchPeriodChoicesSelected = [0,0,0,0,0]
    var daysOfTheWeekSelected = [0,0,0,0,0,0,0]
    
//    variables for the views of calendar and filters
    var viewCalendar = UIView()
    var viewFilter = UIView()
    var btnCalendar = UIButton()
    var btnFilter = UIButton()
    
    
//   variables used to calculate the dates selected by the user
    var timePeriodsAdditionType = [Calendar.Component.day,Calendar.Component.day,Calendar.Component.month,Calendar.Component.month,Calendar.Component.month,Calendar.Component.day]
    var timePeriodsAddition = [7,14,1,2,3,7]

    
//    date fromatter used for the end time > start time checks
     var dateFormatterTZ = DateFormatter()
    
    
// variable used to setup the date pickers
    private var timePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        this stops the viewcontroller from being dismissed when the user swipes down
                if #available(iOS 13.0, *) {
                    self.isModalInPresentation = true
                } else {
                    // Fallback on earlier versions
                }
        
        createNextButton()
        
//        setup the page
        setupThePage()
        print("startDatesChosen \(startDatesChosen)")
        
        
//        setup the time pickers
        timePicker = UIDatePicker()
        timePicker?.datePickerMode = .time
        timePicker?.minuteInterval = 5
        if #available(iOS 13.4, *) {
            timePicker?.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        createTimePicker()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
//        dateformatter for the time checks
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        
        //        MUST ADD subview
        view.addSubview(inputTopView)
        view.addSubview(inputBottomView)
//        view.addSubview(inputBottomView2)
        
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
        
// populate the users title with the users
        getUserName{ (usersName) in
           
//        we need to split the user name
        let fullName = usersName
        let fullNameArr = fullName.components(separatedBy: " ")
        let name    = fullNameArr[0]
                       
            self.titleInput.text = ("\(name)'s \(eventTypeImages.userEventChoices[eventTypeInt])")
            
//        set the times of the event
        self.startTimeInput.text = newEventStartTimeLocal
        self.endTimeInput.text = newEventEndTimeLocal
            
        }
    }
        func setupThePage(){
//        set the title for the page
        let title = "Create Event"
        self.title = title
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = MyVariables.colourPlanrGreen
            navigationItem.backBarButtonItem = backItem
            

            
//        listener to detect when the location has been chosen
    NotificationCenter.default.addObserver(self, selector: #selector(setLocationLabel), name: .locationSet, object: nil)
            
//            listener to detect when the dates have been chosen
            NotificationCenter.default.addObserver(self, selector: #selector(reloadTheDates), name: .datesChosen, object: nil)
            
        }
    
    //    create the progress bar and title
        lazy var inputTopView: UIView = {
            print("setting up the inputTopView")
    //        set the variables for the setup
            let progressAmt = 0.5
            let headerLabelText = "Detail"
            let numberLabelText = "02"
            let instructionLabelText = "Add event details"
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
      print("screenHeight - topDistance - 100 \(screenHeight - topDistance - 100)")
        
//      set the variables for the setup
        let textBoxHeight = 70
        let sideInset = 16
        let sideInsetIcon = 24
        let separatorHeight = 1
        let collectionViewHeight = 30
        let collectionViewDatesHeight = 80
        let iconSize = textBoxHeight/3
        let timeInputWidth = (Int(screenWidth)/2 - sideInset*2)
        let timeInputWidthFull = timeInputWidth - Int(screenWidth)/15
        let spacer = CGFloat(5)
        let buttonHeight = CGFloat(50)
        let timeLabelHeight = CGFloat(10)
        let timeSpacer = CGFloat(15)
    
      //   setup the view for holding the progress bar and title
      let containerView2 = UIView()
      containerView2.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: screenHeight - topDistance - 100)
      containerView2.backgroundColor = UIColor.white
      containerView2.translatesAutoresizingMaskIntoConstraints = false
      
      //        trying to add a top view that represents the remainder of the screen
      let topView = UIView()
      topView.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: screenHeight - topDistance - 100)
      topView.backgroundColor = UIColor.white
      topView.translatesAutoresizingMaskIntoConstraints = false
      containerView2.addSubview(topView)
      topView.leftAnchor.constraint(equalTo: containerView2.leftAnchor).isActive = true
      topView.topAnchor.constraint(equalTo: containerView2.topAnchor).isActive = true
      topView.widthAnchor.constraint(equalTo: containerView2.widthAnchor).isActive = true
      topView.heightAnchor.constraint(equalToConstant: screenHeight - topDistance - 100).isActive = true
        
//        setup the title text field
        titleInput.translatesAutoresizingMaskIntoConstraints = false
        titleInput.placeholder = "Title"
        titleInput.adjustsFontSizeToFitWidth = true
        titleInput.font = UIFont.systemFont(ofSize: 15)
        titleInput.autocapitalizationType = .sentences
        topView.addSubview(titleInput)
        titleInput.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        titleInput.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        titleInput.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        titleInput.heightAnchor.constraint(equalToConstant: CGFloat(textBoxHeight)).isActive = true
        
//        create a separator line
        let separatorLine = UIView()
        separatorLine.backgroundColor = MyVariables.colourPlanrGreen
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLine)
        separatorLine.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        separatorLine.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        
//        setup the location text field
//        let locationInput = UITextField()
           locationInput.translatesAutoresizingMaskIntoConstraints = false
           locationInput.placeholder = "Location"
           locationInput.adjustsFontSizeToFitWidth = true
           locationInput.font = UIFont.systemFont(ofSize: 15)
           locationInput.autocapitalizationType = .sentences
//        enable location popover
        locationInput.addTarget(self, action: #selector(myTargetFunction), for: .editingDidBegin)
           topView.addSubview(locationInput)
           locationInput.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
           locationInput.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInsetIcon)).isActive = true
           locationInput.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight) + CGFloat(separatorHeight)).isActive = true
           locationInput.heightAnchor.constraint(equalToConstant: CGFloat(textBoxHeight)).isActive = true
        
        
//        add the location icon to the view
        let lblLocationLabel = UIImageView()
        lblLocationLabel.image = UIImage(named: "LocationCode")
//        lblLocationLabel.font = UIFont.systemFont(ofSize: 14)
//        lblLocationLabel.textColor = MyVariables.colourLight
//        lblLocationLabel.textAlignment = .center
        lblLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(lblLocationLabel)
        lblLocationLabel.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
        lblLocationLabel.widthAnchor.constraint(equalToConstant: CGFloat(iconSize) - 5).isActive = true
        lblLocationLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight) + CGFloat(separatorHeight) + CGFloat(iconSize)).isActive = true
        lblLocationLabel.heightAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        
//        create a separator line
        let separatorLine2 = UIView()
        separatorLine2.backgroundColor = MyVariables.colourPlanrGreen
        separatorLine2.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLine2)
        separatorLine2.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        separatorLine2.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        separatorLine2.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)).isActive = true
        separatorLine2.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        
        
//        start time update
        let startTimeLbl = UILabel()
        startTimeLbl.text = "Start time:"
        startTimeLbl.font = UIFont.systemFont(ofSize: 14)
        startTimeLbl.textColor = MyVariables.colourLight
        startTimeLbl.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(startTimeLbl)
        startTimeLbl.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        startTimeLbl.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
        startTimeLbl.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)*2 + timeSpacer).isActive = true
        startTimeLbl.heightAnchor.constraint(equalToConstant: CGFloat(timeLabelHeight)).isActive = true
        
        
//        setup the start time input
        startTimeInput.translatesAutoresizingMaskIntoConstraints = false
        startTimeInput.placeholder = "Start time"
        startTimeInput.adjustsFontSizeToFitWidth = true
        startTimeInput.font = UIFont.systemFont(ofSize: 15)
        startTimeInput.autocapitalizationType = .sentences
        topView.addSubview(startTimeInput)
        startTimeInput.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        startTimeInput.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
        startTimeInput.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)*2 + timeSpacer).isActive = true
        startTimeInput.heightAnchor.constraint(equalToConstant: CGFloat(textBoxHeight)).isActive = true
        
        
        //        end time update
        let endTimeLbl = UILabel()
        endTimeLbl.text = "End time:"
        endTimeLbl.font = UIFont.systemFont(ofSize: 14)
        endTimeLbl.textColor = MyVariables.colourLight
        endTimeLbl.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(endTimeLbl)
        endTimeLbl.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
        endTimeLbl.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
        endTimeLbl.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)*2 + timeSpacer).isActive = true
        endTimeLbl.heightAnchor.constraint(equalToConstant: CGFloat(timeLabelHeight)).isActive = true
        
//        setup the end time input
        endTimeInput.translatesAutoresizingMaskIntoConstraints = false
        endTimeInput.placeholder = "End time"
        endTimeInput.adjustsFontSizeToFitWidth = true
        endTimeInput.font = UIFont.systemFont(ofSize: 15)
        endTimeInput.autocapitalizationType = .sentences
        topView.addSubview(endTimeInput)
        endTimeInput.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
        endTimeInput.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
        endTimeInput.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)*2 + timeSpacer).isActive = true
        endTimeInput.heightAnchor.constraint(equalToConstant: CGFloat(textBoxHeight)).isActive = true
        
//        create a separator line
        let separatorLine3 = UIView()
        separatorLine3.backgroundColor = MyVariables.colourPlanrGreen
        separatorLine3.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLine3)
        separatorLine3.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
        separatorLine3.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
        separatorLine3.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*2).isActive = true
        separatorLine3.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        
//        create a separator line
        let separatorLine4 = UIView()
        separatorLine4.backgroundColor = MyVariables.colourPlanrGreen
        separatorLine4.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLine4)
        separatorLine4.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        separatorLine4.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
        separatorLine4.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*2).isActive = true
        separatorLine4.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        
        
//        add the time icon to the view
        let lblEndimeLabel = UIImageView()
        lblEndimeLabel.image = UIImage(named: "TimeCode")
        lblEndimeLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(lblEndimeLabel)
        lblEndimeLabel.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
        lblEndimeLabel.widthAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        let half = CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)*2
        lblEndimeLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: half + CGFloat(iconSize) + timeSpacer).isActive = true
        lblEndimeLabel.heightAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        
//        add the time icon to the view
        let lblStartTimeLabel = UIImageView()
        lblStartTimeLabel.image = UIImage(named: "TimeCode")
        lblStartTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(lblStartTimeLabel)
        lblStartTimeLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(timeInputWidthFull - iconSize/2)).isActive = true
        lblStartTimeLabel.widthAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        lblStartTimeLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: half + CGFloat(iconSize) + timeSpacer).isActive = true
        lblStartTimeLabel.heightAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        
        
//        we have two views the user can use, view
//        1. A calendar on which they can select the dates they want
//        2. A filter view allowing the user to select from the filters they already have
        
//        let separatorLineBtnCalendarTop = UIView()
//        separatorLineBtnCalendarTop.backgroundColor = MyVariables.colourPlanrGreen
//        separatorLineBtnCalendarTop.translatesAutoresizingMaskIntoConstraints = false
//        topView.addSubview(separatorLineBtnCalendarTop)
//        separatorLineBtnCalendarTop.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
//        separatorLineBtnCalendarTop.widthAnchor.constraint(equalToConstant: screenWidth - CGFloat(sideInset)*2).isActive = true
//        separatorLineBtnCalendarTop.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*3 + CGFloat(spacer)).isActive = true
//        separatorLineBtnCalendarTop.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        
//        add the buttons for each selection
        topView.addSubview(btnCalendar)
        btnCalendar.setTitle("  Select Dates", for: .normal)
        btnCalendar.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btnCalendar.setTitleColor(.black, for: .normal)
        btnCalendar.contentHorizontalAlignment = .left
        btnCalendar.addTarget(self, action: #selector(showDateSelectors), for: .touchUpInside)
        btnCalendar.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInsetIcon) + CGFloat(sideInset)).isActive = true
        btnCalendar.widthAnchor.constraint(equalToConstant: screenWidth - CGFloat(sideInset)*2 - CGFloat(sideInsetIcon)*2).isActive = true
        btnCalendar.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*4 + spacer).isActive = true
        btnCalendar.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btnCalendar.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        let separatorLineBtnCalendar = UIView()
        separatorLineBtnCalendar.backgroundColor = MyVariables.colourPlanrGreen
        separatorLineBtnCalendar.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLineBtnCalendar)
        separatorLineBtnCalendar.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        separatorLineBtnCalendar.widthAnchor.constraint(equalToConstant: screenWidth - CGFloat(sideInset)*2).isActive = true
        separatorLineBtnCalendar.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*3 + buttonHeight + CGFloat(spacer)).isActive = true
        separatorLineBtnCalendar.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
    
        
        
//        add the calendar icon to the view
        let lblCalendarView = UIImageView()
        lblCalendarView.image = UIImage(named: "CalendarCode")
        lblCalendarView.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(showDateSelectors))
        lblCalendarView.addGestureRecognizer(singleTap)
        lblCalendarView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(lblCalendarView)
        lblCalendarView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        lblCalendarView.widthAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        let half2 = CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*2
        lblCalendarView.topAnchor.constraint(equalTo: topView.topAnchor, constant: half2 + CGFloat(iconSize)).isActive = true
        lblCalendarView.heightAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        
//        add an indicator icon to the select dates view
        let lblCalendarIndicator = UILabel()
        lblCalendarIndicator.text = ">"
        lblCalendarIndicator.font = UIFont.systemFont(ofSize: 15)
        lblCalendarIndicator.textAlignment = .center
        lblCalendarIndicator.textColor = MyVariables.colourLight
        lblCalendarIndicator.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(lblCalendarIndicator)
        lblCalendarIndicator.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
        lblCalendarIndicator.widthAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        lblCalendarIndicator.topAnchor.constraint(equalTo: topView.topAnchor, constant: half2 + CGFloat(iconSize)).isActive = true
        lblCalendarIndicator.heightAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        
        
        
//        collectionViewDates
//        add the collection view to display the selected dates
        let layout3: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout3.scrollDirection = .horizontal
//        layout3.sectionHeadersPinToVisibleBounds = true
        collectionViewDates = UICollectionView(frame: .zero, collectionViewLayout: layout3)
        collectionViewDates.translatesAutoresizingMaskIntoConstraints = false
        collectionViewDates.delegate = self
        collectionViewDates.dataSource = self
        collectionViewDates.backgroundColor = .white
        collectionViewDates.register(createEventDatesCell.self, forCellWithReuseIdentifier: cellId3)
        collectionViewDates.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionViewDates.isScrollEnabled = true
        collectionViewDates.isUserInteractionEnabled = true
        collectionViewDates.allowsSelection = true
        collectionViewDates.allowsMultipleSelection = false
        topView.addSubview(collectionViewDates)
        collectionViewDates.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        collectionViewDates.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        collectionViewDates.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*3 + buttonHeight + CGFloat(spacer)*3).isActive = true
        collectionViewDates.heightAnchor.constraint(equalToConstant: CGFloat(collectionViewDatesHeight)).isActive = true
        
        
//        MARK: we do not use these anymore
//        setup the collectionView for the search periods
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionviewSearch = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionviewSearch.translatesAutoresizingMaskIntoConstraints = false
        collectionviewSearch.delegate = self
        collectionviewSearch.dataSource = self
        collectionviewSearch.backgroundColor = .white
        collectionviewSearch.register(createEventSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionviewSearch.isScrollEnabled = true
        collectionviewSearch.isUserInteractionEnabled = true
        collectionviewSearch.allowsSelection = true
        collectionviewSearch.allowsMultipleSelection = false
        topView.addSubview(collectionviewSearch)
        collectionviewSearch.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        collectionviewSearch.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        collectionviewSearch.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3.5 + CGFloat(collectionViewDatesHeight) + CGFloat(separatorHeight)*3).isActive = true
        collectionviewSearch.heightAnchor.constraint(equalToConstant: CGFloat(collectionViewHeight)).isActive = true
        collectionviewSearch.isHidden = true
        
        //        create a separator line
        let separatorLine5 = UIView()
        separatorLine5.backgroundColor = MyVariables.colourPlanrGreen
        separatorLine5.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLine5)
        separatorLine5.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        separatorLine5.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        let half3 = CGFloat(textBoxHeight)*3.5 + CGFloat(separatorHeight)*3
        separatorLine5.topAnchor.constraint(equalTo: topView.topAnchor, constant: half3 + CGFloat(collectionViewHeight)*1.5 + CGFloat(collectionViewDatesHeight)).isActive = true
        separatorLine5.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        separatorLine5.isHidden = true
        
//        add the collectionView for the days of the week
        //        setup the collectionView for the search periods
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.scrollDirection = .vertical
        collectionviewDaysOfTheWeek = UICollectionView(frame: .zero, collectionViewLayout: layout2)
        collectionviewDaysOfTheWeek.translatesAutoresizingMaskIntoConstraints = false
        collectionviewDaysOfTheWeek.delegate = self
        collectionviewDaysOfTheWeek.dataSource = self
        collectionviewDaysOfTheWeek.backgroundColor = .white
        collectionviewDaysOfTheWeek.register(dotwCell.self, forCellWithReuseIdentifier: cellId2)
        collectionviewDaysOfTheWeek.isScrollEnabled = true
        collectionviewDaysOfTheWeek.isUserInteractionEnabled = true
        collectionviewDaysOfTheWeek.allowsSelection = true
        collectionviewDaysOfTheWeek.allowsMultipleSelection = true
        topView.addSubview(collectionviewDaysOfTheWeek)
        collectionviewDaysOfTheWeek.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        collectionviewDaysOfTheWeek.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        collectionviewDaysOfTheWeek.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*4.5 + CGFloat(separatorHeight)*3 + CGFloat(collectionViewDatesHeight)).isActive = true
        collectionviewDaysOfTheWeek.heightAnchor.constraint(equalToConstant: CGFloat(textBoxHeight)).isActive = true
        collectionviewDaysOfTheWeek.isHidden = true
        

        return containerView2
    }()
    
    
    @objc func showDateSelectors(){
        print("user selected the select dates button")
        
//        pop to the select dates page
                let secondStoryBoard = UIStoryboard(name: "NL-CreateEvent", bundle: nil)
                if let viewController = secondStoryBoard.instantiateViewController(withIdentifier: "NL_createEventSelectDates") as? NL_createEventSelectDates {
                    self.present(viewController, animated: true, completion: nil)
                }
    }
    
    
//    function for the location popup to be displayed
    @objc func myTargetFunction(textField: UITextField) {
        print("myTargetFunction to display the map running")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let popController = storyboard.instantiateViewController(withIdentifier: "locationSearchTableNavigation") as! UINavigationController
            
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover

        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        
        popController.popoverPresentationController?.delegate = self


        // present the popover
        self.present(popController, animated: true, completion: nil)
    }
//    set the location in the creation page
    @objc func setLocationLabel() {
     locationInput.text = locationPassed
     }
    
//    reload the dates view to show the newly selected dates
        @objc func reloadTheDates() {
            collectionViewDates.reloadData()
         }
    
//    setup the time pickers for the end and start time
        func createTimePicker(){
            //        assign date picker to our text input
            startTimeInput.inputView = timePicker
            endTimeInput.inputView = timePicker
            //        add a toolbar to the datepicker
            let toolBar = UIToolbar()
            toolBar.sizeToFit()

            //        add a done button to the toolbar
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClickedTime))
            doneButton.tintColor = MyVariables.colourPlanrGreen
            
    //        Adds space to the left of the done button, pushing the button to the right
            let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
            toolBar.setItems([flexSpace, doneButton], animated: false)
        
            startTimeInput.inputAccessoryView = toolBar
            endTimeInput.inputAccessoryView = toolBar
        }
    
//    function to determine what happens when the user selects a time on the time pickers
    @objc func doneClickedTime(){
        
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if startTimeInput.isFirstResponder{
            startTimeInput.text = dateFormatter.string(from: timePicker!.date)
            newEventStartTimeLocal = startTimeInput.text!
            let dateStartDate = dateFormatter.date(from: startTimeInput.text!)
            let adjStartTimeDate = dateStartDate!.addingTimeInterval(TimeInterval(-secondsFromGMT))
            let adjStartTimeString = dateFormatter.string(from: adjStartTimeDate)
            newEventStartTime = adjStartTimeString
            print("newEventStartTime \(newEventStartTime)")
            self.view.endEditing(true)
        }
        
        if endTimeInput.isFirstResponder{
            endTimeInput.text = dateFormatter.string(from: timePicker!.date)
            newEventEndTimeLocal = endTimeInput.text!
            let dateEndDate = dateFormatter.date(from: endTimeInput.text!)
            let adjEndTimeDate = dateEndDate!.addingTimeInterval(TimeInterval(-secondsFromGMT))
            let adjEndTimeString = dateFormatter.string(from: adjEndTimeDate)
            newEventEndTime = adjEndTimeString
            print("newEventEndTime \(newEventEndTime)")
            self.view.endEditing(true)
        }
    }
    
    
    
//    function to show the calendar view for the serach period selector
    @objc func calendarViewTarget(){
        print("user tapped on the calendar")
        
    }
    
    
    //    function to add the next button when the user selects next
func createNextButton(){
    
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
            navigationItem.rightBarButtonItem?.tintColor = MyVariables.colourPlanrGreen
        }
    
    
    //    function for taking the user to the next page
        @objc func nextTapped(){
//            prior to sending the user to the next page, we need to check the validity of the information they inputted
//            utils for calling the alert
            let utils = Utils()
//            adjsut the time based on where the user is
            var hoursFromGMTString = String()
            let hoursFromGMT = secondsFromGMT / 3600
            if hoursFromGMT >= 0{
                hoursFromGMTString = ("+\(hoursFromGMT)")
            }
            else{
               hoursFromGMTString = ("\(hoursFromGMT)")
            }
////            we need to run the find dates to check if the user has chosen compatible dates
//            findDates {
            
            print("startTimeInput.text \(startTimeInput.text)")
            
//            1. did the user add a title
            if self.titleInput.text == ""{
                Analytics.logEvent(firebaseEvents.createEventTitleMissing, parameters: ["user": user])
                    let button = AlertButton(title: "OK", action: {
                        print("OK clicked")
                    }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                
                let alertPayload = AlertPayload(title: "Event Title!", titleColor: UIColor.red, message: "Your event needs a Title, please add one.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                
                    utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: false)
            }
//                2. did the user add a location
            else if self.locationInput.text == ""{
                Analytics.logEvent(firebaseEvents.createEventLocationMissing, parameters: ["user": user])
                
                    let button = AlertButton(title: "OK", action: {
                        print("OK clicked");
                    }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                
                let alertPayload = AlertPayload(title: "Event Location!", titleColor: UIColor.red, message: "Your event needs a Location, please add one.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                
                    utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: false);
                
            }
//            3.1 did the user add an event start time
            else if self.startTimeInput.text == ""{
                Analytics.logEvent(firebaseEvents.createEventStartTimeMissing, parameters: ["user": user])
                let button = AlertButton(title: "OK", action: {
                        print("OK clicked");
                    }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                
                let alertPayload = AlertPayload(title: "Event Start Time!", titleColor: UIColor.red, message: "Your event needs a Start Time, please add one.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                
                    utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true);
            }
            
//            3.2 did the user add an event end time
            else if self.endTimeInput.text == ""{
                Analytics.logEvent(firebaseEvents.createEventEndTimeMissing, parameters: ["user": user])
                           let button = AlertButton(title: "OK", action: {
                                   print("OK clicked");
                               }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                           
                           let alertPayload = AlertPayload(title: "Event End Time!", titleColor: UIColor.red, message: "Your event needs an End Time, please add one.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                           
                               utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true);
            }
//            3.3 is the start date before the end date
            
            else if self.dateFormatterTZ.date(from: ("\("2000-01-01") \(self.endTimeInput.text!) GMT\(hoursFromGMTString)"))! <= self.dateFormatterTZ.date(from: "\("2000-01-01") \(self.startTimeInput.text!) GMT\(hoursFromGMTString)")!{
                Analytics.logEvent(firebaseEvents.createEventEndBeforeStartTime, parameters: ["user": user])
                
                let button = AlertButton(title: "OK", action: {
                        print("OK clicked");
                    }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                
                let alertPayload = AlertPayload(title: "Event Time!", titleColor: UIColor.red, message: "Your event End Time is before the Start Time, please amend.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                
                    utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true);
            }
//            4.do the inputs chosen retrun any dates
//            4.1 run the find dates prior to our check
            else if startDatesChosen.count == 0{
                Analytics.logEvent(firebaseEvents.createEventNoDatesSelected, parameters: ["user": user])
                let button = AlertButton(title: "OK", action: {
                        print("OK clicked");
                    }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                
                let alertPayload = AlertPayload(title: "No Event Dates!", titleColor: UIColor.red, message: "No dates in search period, ensure there are dates in the period.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                
                    utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true)
            }
//            if everything completes without issue we send the user to the next page
            else{
//                set the global variables
                newEventDescription = self.titleInput.text ?? ""
                newEventLocation = self.locationInput.text ?? ""
                searchPeriodText = self.searchLabel.text ?? ""
                
//                set the time for the event
                newEventStartTimeLocal = self.startTimeInput.text!
                let dateStartDate = self.dateFormatter.date(from: self.startTimeInput.text!)
                let adjStartTimeDate = dateStartDate!.addingTimeInterval(TimeInterval(-secondsFromGMT))
                let adjStartTimeString = self.dateFormatter.string(from: adjStartTimeDate)
                newEventStartTime = adjStartTimeString
                print("newEventStartTime \(newEventStartTime)")
                
                newEventEndTimeLocal = self.endTimeInput.text!
                let dateEndDate = self.dateFormatter.date(from: self.endTimeInput.text!)
                let adjEndTimeDate = dateEndDate!.addingTimeInterval(TimeInterval(-secondsFromGMT))
                let adjEndTimeString = self.dateFormatter.string(from: adjEndTimeDate)
                newEventEndTime = adjEndTimeString
                print("newEventEndTime \(newEventEndTime)")
            
//            calculate the start and end dates for based on the dates chosen
//                we remove the dates before we add them back
                    startDatesNewEvent.removeAll()
                    endDatesNewEvent.removeAll()
                
            for date in startDatesChosen{

//                we need to add the time chosen by the user to the date array startDatesChosen, 2020-09-24 00:00 CDT
                let yyyymmdd = date[0...9]
                let tz = date[17...19]
                
                startDatesNewEvent.append("\(yyyymmdd) \(newEventStartTimeLocal) \(tz)")
                endDatesNewEvent.append("\(yyyymmdd) \(newEventEndTimeLocal) \(tz)")
            }
            print("startDatesNewEvent: \(startDatesNewEvent) endDatesNewEvent: \(endDatesNewEvent)")
                
                self.performSegue(withIdentifier: "addInviteeSegue", sender:self)
//        }
            }
    }
    
////    fucntion to determine the dates applicable for the search period chosen by the user
//    func findDates(completion: @escaping () -> Void){
////        check if the user has chosen any days of the week or search period
//        let dowCheck = daysOfTheWeekSelected.filter({ $0 == 1 }).count
//        let datesCheck = searchPeriodChoicesSelected.filter({ $0 == 1 }).count
//
//        if dowCheck == 0 || datesCheck == 0{
//            print("user not made enough selections to calcaulte the dates")
//            startDatesChosen.removeAll()
//            endDatesChosen.removeAll()
//            completion()
//        }
//        else{
////            get start date and end date
//            let currentDate = Date()
////            get the index of the selected search period
//            let index = searchPeriodChoicesSelected.index(of: 1)
//            let newEndDate = dateInXDays(increment: timePeriodsAddition[index!], additionType: timePeriodsAdditionType[index!])
//
////            input the above into the get dates function
//            var dateFormatterInputString = DateFormatter()
//            dateFormatterInputString.locale = Locale(identifier: "en_US_POSIX")
//            dateFormatterInputString.dateFormat = "yyyy-MM-dd"
//            let startDateInput = dateFormatterInputString.string(from: currentDate)
//            let endDateInput = dateFormatterInputString.string(from: newEndDate)
//
////            convert the day of the week selected index into a days of the week array, the day of the week input has sunday as the first day of the array, we need to adapt our selected array to the days of the week array
//            var DOTW = [Int]()
//            var n = 1
//            var y = 0
//            for i in daysOfTheWeekSelected{
//                if n == 7{
//                    if i == 1{
//                        DOTW.insert(0, at: 0)
//                        print("DOTW \(DOTW)")
//                    }
//                    else{
//                       DOTW.insert(10, at: 0)
//                        print("DOTW \(DOTW)")
//                    }
//                }
//                else{
//                if i == 1{
//                    DOTW.insert(n, at: y)
//                    n = n + 1
//                    y = y + 1
//                    print("DOTW \(DOTW)")
//                }
//                else{
//                   DOTW.insert(10, at: y)
//                    n = n + 1
//                    y = y + 1
//                    print("DOTW \(DOTW)")
//                }
//                }
//            }
////            set the day of the week equal to the global variable such that we use them when we create the event
//            daysOfTheWeekNewEvent = DOTW
//
//            getStartAndEndDates3(startDate: startDateInput, endDate: endDateInput, startTime: "00:00", endTime: "01:00", daysOfTheWeek: DOTW){(startDates,endDates) in
////        set the global variables
//                startDatesChosen = startDates
//                endDatesChosen = endDates
////                we set the global new dates for the event creation
//                let startDate = startDatesChosen.first
//                let endDate = endDatesChosen.last
//                newEventEndDate =  String(endDate![0...9])
//                newEventStartDate = String(startDate![0...9])
//
//                completion()
//            }
//
//        }
//
//    }
}


// setup the collectionView
extension NL_createEventDetail: UICollectionViewDelegate, UICollectionViewDataSource {
    
//    we only have one section in each collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var numberOfItems = Int()
        
        if collectionView == collectionviewSearch{
        numberOfItems = searchPeriodChoices.count
        print("collectionView number of items \(numberOfItems)")
        }
        else if collectionView == collectionviewDaysOfTheWeek{
            numberOfItems = daysOfTheWeek.count
        }
//            set the dates count and set the backgorund message
        else if collectionView == collectionViewDates{
            if startDatesChosen.count == 0{
                collectionView.setEmptyMessage(message: "Select dates above", messageAlignment: .left)
                numberOfItems = startDatesChosen.count
            }
            else{
//                reset the background image
                collectionView.restore()
                numberOfItems = startDatesChosen.count
            }
            return numberOfItems
        }
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = UICollectionViewCell()
        
        if collectionView == collectionviewSearch{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! createEventSearchCell
        
        cell.cellText.text = searchPeriodChoices[indexPath.row]
        cell.cellText.textColor = MyVariables.colourPlanrGreen
        cell.cellText.font = UIFont.systemFont(ofSize: 14)
        cell.layer.backgroundColor = MyVariables.colourSelected.cgColor
        cell.textView.layer.backgroundColor = MyVariables.colourSelected.cgColor
        cell.cellText.backgroundColor = MyVariables.colourSelected
        
//            add the border for the selected
            if searchPeriodChoicesSelected[indexPath.row] == 1{
                cell.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
                    cell.layer.borderWidth = 3
                }
                else{
                    cell.layer.borderColor = MyVariables.colourBackground.cgColor
                    cell.layer.borderWidth = 0
                }
        
        print("searchPeriodChoices\([indexPath.row]) \(searchPeriodChoices[indexPath.row])")
        
        return cell
        }
        else if collectionView == collectionviewDaysOfTheWeek{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId2, for: indexPath) as! dotwCell
            
            cell.cellText.text = daysOfTheWeek[indexPath.row]
            cell.cellText.textColor = MyVariables.colourPlanrGreen
            cell.cellText.font = UIFont.systemFont(ofSize: 14)
            cell.cellText.backgroundColor = MyVariables.colourSelected
            cell.layer.backgroundColor = MyVariables.colourSelected.cgColor
            cell.textView.layer.backgroundColor = MyVariables.colourSelected.cgColor
            
            //            add the border for the selected
            if daysOfTheWeekSelected[indexPath.row] == 1{
                cell.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
                    cell.layer.borderWidth = 3
                }
                else{
                    cell.layer.borderColor = MyVariables.colourBackground.cgColor
                    cell.layer.borderWidth = 0
                }
            return cell
        }
        
//        setup the cell for the dates view
        if collectionView == collectionViewDates{
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId3, for: indexPath) as! createEventDatesCell
           
//            setup the cell look
            cell.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            
//           we need to convert the start dates into a format we can display
            let dateIndex = startDatesChosen[indexPath.row]
            let dateIndexDate = dateFormatterTZ.date(from: dateIndex)
            let month = dateIndexDate!.get(.month) - 1
            let day = dateIndexDate!.get(.weekday)
            let dayInt = dateIndexDate!.get(.day)
            
//            arrays to convert the dates into strings
            let monthArray = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
            let weekDays = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
            
            cell.monthText.text = ("\(monthArray[month])")
            cell.monthText.textColor = MyVariables.colourLight
            cell.monthText.font = UIFont.systemFont(ofSize: 13)
            
            cell.dayText.text = ("\(dayInt)")
            cell.dayText.font = UIFont.systemFont(ofSize: 20)
            
            cell.dowText.text = ("\(weekDays[day-1])")
            cell.dowText.textColor = MyVariables.colourLight
            cell.dowText.font = UIFont.systemFont(ofSize: 13)
            
            
            return cell
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if the collectionView is the one for searchPeriods then update the array and reload the table
        if collectionView == collectionviewSearch{
            print("user selected a period searchPeriodChoicesSelected[indexPath.row] \(searchPeriodChoicesSelected[indexPath.row])")
//            reset the array
            searchPeriodChoicesSelected = [0,0,0,0,0]
            searchPeriodChoicesSelected[indexPath.row] = 1
            collectionviewSearch.reloadData()
            
//            we need to get the end date for the period selected by the user
            let currentDate = Date()
            let dateFormatterDisplay = DateFormatter()
            dateFormatterDisplay.dateFormat = "dd MMM YYYY"
            dateFormatterDisplay.locale = Locale(identifier: "en_US_POSIX")
//            function to calcaulte the end of the period selected by the user
            let newEndDate = dateInXDays(increment: timePeriodsAddition[indexPath.row], additionType: timePeriodsAdditionType[indexPath.row])
//            convert this into a display date
            let newEndDateDisplay = dateFormatterDisplay.string(from: newEndDate)
            print("newEndDate: \(newEndDateDisplay)")
//            get the current date
            let today = dateFormatterDisplay.string(from: currentDate)
            searchLabel.text = ("\(today) - \(newEndDateDisplay)")
//            we also change the font of the label to black
            searchLabel.textColor = .black
            
//            calculate the date for the selection
//            findDates{
////                reload the tables of dates once complete
//                self.collectionViewDates.reloadData()
//            }
            
            
        }
        else if collectionView == collectionviewDaysOfTheWeek{
//            we can select multiple day of the week, hence we need to change the original selection
            print("user selected a day of the week daysOfTheWeekSelected[indexPath.row] \(daysOfTheWeekSelected[indexPath.row])")
            if daysOfTheWeekSelected[indexPath.row] == 1{
                daysOfTheWeekSelected[indexPath.row] = 0
            }
            else{
              daysOfTheWeekSelected[indexPath.row] = 1

            }
////            calculate the date for the selection
//            findDates{
//                self.collectionviewDaysOfTheWeek.reloadData()
//                //                reload the tables of dates once complete
//                self.collectionViewDates.reloadData()
//            }
        }
//            we don't do anything when the user selects a date in the collectionView
        else if collectionView == collectionViewDates{
            print("user selected a date - we do nothing")
        }
    }
    
    
}

// setup the collectionView layout

extension NL_createEventDetail: UICollectionViewDelegateFlowLayout {
    
    
    // sets the size of the cell based on the collectionView
    func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize()
        
        if collectionView == collectionviewSearch{
            size = CGSize(width: 70, height: 30)
        }
        else if collectionView == collectionviewDaysOfTheWeek{
            size = CGSize(width: 50, height: 30)
        }
        else if collectionView == collectionViewDates{
            size = CGSize(width: 80, height: 80)
        }
           return size
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
        return 5
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == collectionViewDates{
            if kind == UICollectionView.elementKindSectionHeader {
         let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeader
                
//                if the user hasnt made a selection, we dont want to show anything
                if startDatesChosen.count == 0{
                   sectionHeader.label.text = ""
                }
                else{
                    sectionHeader.label.text = ("\(startDatesChosen.count) Options")}
                
         return sectionHeader
    } else { print("this wasnt a collectionView header kind - \(kind)")
         return UICollectionReusableView()
            }}
         return UICollectionReusableView()
    }
    
//    defines the size of the header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView == collectionViewDates{
        
        return CGSize(width: 80, height: 30)
        }
        else{
            return CGSize(width: 0, height: 0)
        }
    }
    
}

//function to add a message when there is no data in the collectionView of dates
extension UICollectionView {

    func setEmptyMessage(message: String, messageAlignment: NSTextAlignment) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = MyVariables.colourLight
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 2;
        messageLabel.textAlignment = messageAlignment;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

//class for the section header of the collectionView
class SectionHeader: UICollectionReusableView {
     var label: UILabel = {
     let label: UILabel = UILabel()
    label.textColor = MyVariables.colourLight
     label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
     label.sizeToFit()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
     return label
 }()

override init(frame: CGRect) {
     super.init(frame: frame)

     addSubview(label)

     label.translatesAutoresizingMaskIntoConstraints = false
    label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
     label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
     label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
     label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension Notification.Name {
     static let datesChosen = Notification.Name("datesChosen")

}
