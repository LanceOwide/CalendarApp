//
//  NL_editEvent.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 9/23/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import Firebase

class NL_editEvent: UIViewController, UIPopoverPresentationControllerDelegate {
    
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
      let cellIdTV = "cellIdTV"
      let searchPeriodChoices = ["1 Week","2 Weeks","1 Month","2 Months","3 Months"]
      let daysOfTheWeek = ["Mon","Tues","Wed","Thu","Fri","Sat","Sun"]
      var searchPeriodChoicesSelected = [0,0,0,0,0]
      var daysOfTheWeekSelected = [0,0,0,0,0,0,0]
      
  //    variables for the views of calendar and filters
      var viewCalendar = UIView()
      var viewFilter = UIView()
      var btnCalendar = UIButton()
      var btnFilter = UIButton()
      var btnSelectUsers = UIButton()
    
      var tableViewContacts: UITableView!
    
    
      
      
  //   variables used to calculate the dates selected by the user
      var timePeriodsAdditionType = [Calendar.Component.day,Calendar.Component.day,Calendar.Component.month,Calendar.Component.month,Calendar.Component.month,Calendar.Component.day]
      var timePeriodsAddition = [7,14,1,2,3,7]

      
  //    date fromatter used for the end time > start time checks
       var dateFormatterTZ = DateFormatter()
      
      
  // variable used to setup the date pickers
      private var timePicker: UIDatePicker?
      
      override func viewDidLoad() {
          super.viewDidLoad()
          
          createNextButton()
          
  //        setup the page
          setupThePage()
          print("startDatesChosen \(startDatesChosen)")
        
        calendarArray2.removeAll()
          
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
          view.addSubview(inputBottomView)
  //        view.addSubview(inputBottomView2)
                            
    //        setup view for collectionView
                inputBottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                inputBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                inputBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
                inputBottomView.topAnchor.constraint(equalTo: view.topAnchor, constant: barHeight + 10).isActive = true
          
  // populate the users title with the users
          getUserName{ (usersName) in
             
  //        we need to split the user name
          let fullName = usersName
          let fullNameArr = fullName.components(separatedBy: " ")
          let name    = fullNameArr[0]
                         
            self.titleInput.text = ("\(name)'s \(eventTypeImages.userEventChoices[eventTypeInt])")
          }
        
        
//        populate the event details
        titleInput.text = currentUserSelectedEvent.eventDescription
        locationInput.text = currentUserSelectedEvent.eventLocation
        startTimeInput.text = convertToLocalTime(inputTime: currentUserSelectedEvent.eventStartTime)
        endTimeInput.text = convertToLocalTime(inputTime: currentUserSelectedEvent.eventEndTime)
        
//        setup the tableView and reload the data once we set the user information
        setUpTheInviteeTableView{
            self.tableViewContacts.reloadData()
        }
        
//        add an observer to update the tableview when the user selects new invitees
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: .editEventUsersChosen, object: nil)

      }
    
    
          func setupThePage(){
  //        set the title for the page
          let title = "Edit Event"
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
              let headerLabelText = "Edit Event"
              let instructionLabelText = "Edit event details"
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
              
            
              
              //        setup the item label
              let headerLabel = UILabel()
              headerLabel.text = headerLabelText
              headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
              headerLabel.translatesAutoresizingMaskIntoConstraints = false
              topView.addSubview(headerLabel)
              headerLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
              headerLabel.widthAnchor.constraint(equalToConstant: screenWidth - CGFloat(sideInset)).isActive = true
              headerLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
              headerLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
              
      //        set the instruction
              let instructionLabel = UILabel()
              instructionLabel.text = instructionLabelText
              instructionLabel.font = UIFont.systemFont(ofSize: 14)
              instructionLabel.textColor = MyVariables.colourLight
              instructionLabel.translatesAutoresizingMaskIntoConstraints = false
              topView.addSubview(instructionLabel)
              instructionLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
              instructionLabel.widthAnchor.constraint(equalToConstant: screenWidth - CGFloat(sideInset)).isActive = true
              instructionLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40).isActive = true
              instructionLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
              return containerView
          }()
      
      
  //    setup the inputs for the detials
      lazy var inputBottomView: UIView = {
        print("screenHeight - topDistance - 100 \(screenHeight - topDistance - 100)")
          
  //      set the variables for the setup
          let textBoxHeight = 70
          let textLblHeight = 15
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
        
        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = "Title"
        titleLbl.textColor = MyVariables.colourLight
        titleLbl.adjustsFontSizeToFitWidth = true
        titleLbl.font = UIFont.systemFont(ofSize: 15)
        topView.addSubview(titleLbl)
        titleLbl.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        titleLbl.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        titleLbl.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        titleLbl.heightAnchor.constraint(equalToConstant: CGFloat(textLblHeight)).isActive = true
          
  //        setup the title text field
          titleInput.translatesAutoresizingMaskIntoConstraints = false
        titleInput.text = currentUserSelectedEvent.eventDescription
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
          separatorLine.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight) - spacer*2).isActive = true
          separatorLine.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        
        
        let locationLbl = UILabel()
        locationLbl.translatesAutoresizingMaskIntoConstraints = false
        locationLbl.text = "Location"
        locationLbl.textColor = MyVariables.colourLight
        locationLbl.adjustsFontSizeToFitWidth = true
        locationLbl.font = UIFont.systemFont(ofSize: 15)
        topView.addSubview(locationLbl)
        locationLbl.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        locationLbl.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
        locationLbl.topAnchor.constraint(equalTo: topView.topAnchor,constant: CGFloat(textBoxHeight) + CGFloat(separatorHeight*3)).isActive = true
        locationLbl.heightAnchor.constraint(equalToConstant: CGFloat(textLblHeight)).isActive = true
          
  //        setup the location text field
  //        let locationInput = UITextField()
             locationInput.translatesAutoresizingMaskIntoConstraints = false
             locationInput.text = currentUserSelectedEvent.eventLocation
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
          separatorLine2.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight) - spacer*2).isActive = true
          separatorLine2.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        
        let startTimeLbl = UILabel()
        startTimeLbl.translatesAutoresizingMaskIntoConstraints = false
        startTimeLbl.text = "Start Time"
        startTimeLbl.textColor = MyVariables.colourLight
        startTimeLbl.adjustsFontSizeToFitWidth = true
        startTimeLbl.font = UIFont.systemFont(ofSize: 15)
        topView.addSubview(startTimeLbl)
        startTimeLbl.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        startTimeLbl.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
        startTimeLbl.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)*5).isActive = true
        startTimeLbl.heightAnchor.constraint(equalToConstant: CGFloat(textLblHeight)).isActive = true
          
          
  //        setup the start time input
              startTimeInput.translatesAutoresizingMaskIntoConstraints = false
              startTimeInput.text = convertToLocalTime(inputTime: currentUserSelectedEvent.eventStartTime)
              startTimeInput.adjustsFontSizeToFitWidth = true
              startTimeInput.font = UIFont.systemFont(ofSize: 15)
              startTimeInput.autocapitalizationType = .sentences
              topView.addSubview(startTimeInput)
              startTimeInput.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
              startTimeInput.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
              startTimeInput.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)*2).isActive = true
              startTimeInput.heightAnchor.constraint(equalToConstant: CGFloat(textBoxHeight)).isActive = true
        
        let endTimeLbl = UILabel()
        endTimeLbl.translatesAutoresizingMaskIntoConstraints = false
        endTimeLbl.text = "End Time"
        endTimeLbl.textColor = MyVariables.colourLight
        endTimeLbl.adjustsFontSizeToFitWidth = true
        endTimeLbl.font = UIFont.systemFont(ofSize: 15)
        topView.addSubview(endTimeLbl)
        endTimeLbl.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
        endTimeLbl.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
        endTimeLbl.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)*5).isActive = true
        endTimeLbl.heightAnchor.constraint(equalToConstant: CGFloat(textLblHeight)).isActive = true
          
  //        setup the end time input
          endTimeInput.translatesAutoresizingMaskIntoConstraints = false
          endTimeInput.text = convertToLocalTime(inputTime: currentUserSelectedEvent.eventEndTime)
          endTimeInput.adjustsFontSizeToFitWidth = true
          endTimeInput.font = UIFont.systemFont(ofSize: 15)
          endTimeInput.autocapitalizationType = .sentences
          topView.addSubview(endTimeInput)
          endTimeInput.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
          endTimeInput.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
          endTimeInput.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)*5).isActive = true
          endTimeInput.heightAnchor.constraint(equalToConstant: CGFloat(textBoxHeight)).isActive = true
          
  //        create a separator line
          let separatorLine3 = UIView()
          separatorLine3.backgroundColor = MyVariables.colourPlanrGreen
          separatorLine3.translatesAutoresizingMaskIntoConstraints = false
          topView.addSubview(separatorLine3)
          separatorLine3.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
          separatorLine3.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
          separatorLine3.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*2 - spacer*2).isActive = true
          separatorLine3.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
          
  //        create a separator line
          let separatorLine4 = UIView()
          separatorLine4.backgroundColor = MyVariables.colourPlanrGreen
          separatorLine4.translatesAutoresizingMaskIntoConstraints = false
          topView.addSubview(separatorLine4)
          separatorLine4.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
          separatorLine4.widthAnchor.constraint(equalToConstant: CGFloat(timeInputWidthFull)).isActive = true
          separatorLine4.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*2 - spacer*2).isActive = true
          separatorLine4.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
          
          
  //        add the time icon to the view
          let lblEndimeLabel = UIImageView()
          lblEndimeLabel.image = UIImage(named: "TimeCode")
          lblEndimeLabel.translatesAutoresizingMaskIntoConstraints = false
          topView.addSubview(lblEndimeLabel)
          lblEndimeLabel.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
          lblEndimeLabel.widthAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
          let half = CGFloat(textBoxHeight)*2 + CGFloat(separatorHeight)*2
          lblEndimeLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: half + CGFloat(iconSize)).isActive = true
          lblEndimeLabel.heightAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
          
  //        add the time icon to the view
          let lblStartTimeLabel = UIImageView()
          lblStartTimeLabel.image = UIImage(named: "TimeCode")
          lblStartTimeLabel.translatesAutoresizingMaskIntoConstraints = false
          topView.addSubview(lblStartTimeLabel)
          lblStartTimeLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(timeInputWidthFull - iconSize/2)).isActive = true
          lblStartTimeLabel.widthAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
          lblStartTimeLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: half + CGFloat(iconSize)).isActive = true
          lblStartTimeLabel.heightAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
          
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
          lblCalendarView.topAnchor.constraint(equalTo: topView.topAnchor, constant: half2 + CGFloat(iconSize) - spacer).isActive = true
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
        
        let half3 = CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*3 + buttonHeight + CGFloat(spacer)*3 + CGFloat(collectionViewDatesHeight)
        
        topView.addSubview(btnSelectUsers)
        btnSelectUsers.setTitle("  Select Invitees", for: .normal)
        btnSelectUsers.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btnSelectUsers.setTitleColor(.black, for: .normal)
        btnSelectUsers.contentHorizontalAlignment = .left
        btnSelectUsers.addTarget(self, action: #selector(showUserSelectors), for: .touchUpInside)
        btnSelectUsers.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInsetIcon) + CGFloat(sideInset)).isActive = true
        btnSelectUsers.widthAnchor.constraint(equalToConstant: screenWidth - CGFloat(sideInset)*2 - CGFloat(sideInsetIcon)*2).isActive = true
        btnSelectUsers.topAnchor.constraint(equalTo: topView.topAnchor, constant: half3 + 10).isActive = true
        btnSelectUsers.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btnSelectUsers.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        let userImage = UIImageView()
        userImage.image = UIImage(named: "accountSettingsCode")
        userImage.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(userImage)
        userImage.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        userImage.widthAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        userImage.topAnchor.constraint(equalTo: topView.topAnchor, constant: half3 + CGFloat(iconSize)).isActive = true
        userImage.heightAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        
        let lblCalendarIndicator2 = UILabel()
        lblCalendarIndicator2.text = ">"
        lblCalendarIndicator2.font = UIFont.systemFont(ofSize: 15)
        lblCalendarIndicator2.textAlignment = .center
        lblCalendarIndicator2.textColor = MyVariables.colourLight
        lblCalendarIndicator2.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(lblCalendarIndicator2)
        lblCalendarIndicator2.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -CGFloat(sideInset)).isActive = true
        lblCalendarIndicator2.widthAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        lblCalendarIndicator2.topAnchor.constraint(equalTo: topView.topAnchor, constant: half3 + CGFloat(iconSize)).isActive = true
        lblCalendarIndicator2.heightAnchor.constraint(equalToConstant: CGFloat(iconSize)).isActive = true
        
        let separatorLineBtnCalendar2 = UIView()
        separatorLineBtnCalendar2.backgroundColor = MyVariables.colourPlanrGreen
        separatorLineBtnCalendar2.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLineBtnCalendar2)
        separatorLineBtnCalendar2.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        separatorLineBtnCalendar2.widthAnchor.constraint(equalToConstant: screenWidth - CGFloat(sideInset)*2).isActive = true
        separatorLineBtnCalendar2.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*3 + buttonHeight + CGFloat(spacer)*5 + CGFloat(collectionViewDatesHeight)).isActive = true
        separatorLineBtnCalendar2.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        separatorLineBtnCalendar2.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorLineBtnCalendar3 = UIView()
        separatorLineBtnCalendar3.backgroundColor = MyVariables.colourPlanrGreen
        separatorLineBtnCalendar3.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLineBtnCalendar3)
        separatorLineBtnCalendar3.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        separatorLineBtnCalendar3.widthAnchor.constraint(equalToConstant: screenWidth - CGFloat(sideInset)*2).isActive = true
        separatorLineBtnCalendar3.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*3 + buttonHeight*2 + CGFloat(spacer)*5 + CGFloat(collectionViewDatesHeight)).isActive = true
        separatorLineBtnCalendar3.heightAnchor.constraint(equalToConstant: CGFloat(separatorHeight)).isActive = true
        separatorLineBtnCalendar3.translatesAutoresizingMaskIntoConstraints = false
        
        
        //        setup the collectionView for the contacts
        tableViewContacts = UITableView(frame: .zero)
        tableViewContacts.translatesAutoresizingMaskIntoConstraints = false
        tableViewContacts.delegate = self
        tableViewContacts.dataSource = self
        tableViewContacts.register(NL_contactTableViewCell.self, forCellReuseIdentifier: cellIdTV)
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
        tableViewContacts.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight)*3 + CGFloat(separatorHeight)*3 + buttonHeight*2 + CGFloat(spacer)*8 + CGFloat(collectionViewDatesHeight)).isActive = true
        tableViewContacts.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        

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
    
    
    @objc func showUserSelectors(){
        print("user selected the select dates button")
        
//        pop to the select dates page
                let secondStoryBoard = UIStoryboard(name: "NL_Events", bundle: nil)
                if let viewController = secondStoryBoard.instantiateViewController(withIdentifier: "NL_editEventInvitees") as? NL_editEventInvitees {
                    
                    
                    
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
              
      //        Adds space to the left of the done button, pushing the button to the right
              let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
              toolBar.setItems([flexSpace, doneButton], animated: false)
          
              startTimeInput.inputAccessoryView = toolBar
              endTimeInput.inputAccessoryView = toolBar
          }
      
  //    function to determine what happens when the user selects a time on the time pickers
      @objc func doneClickedTime(){
          
          dateFormatter.dateFormat = "HH:mm"
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
              navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(nextTapped))
              navigationItem.rightBarButtonItem?.tintColor = MyVariables.colourPlanrGreen
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "x", style: .plain, target: self, action: #selector(closeTapped))
    navigationItem.leftBarButtonItem?.tintColor = MyVariables.colourPlanrGreen
          }
    
    
    @objc func closeTapped(){
        self.dismiss(animated: true)
    }
    
    @objc func updateTableView(){
        
        tableViewContacts.reloadData()
        
    }
      
      
      //    function for taking the user to the next page
          @objc func nextTapped(){
  //            prior to sending the user to the next page, we need to check the validity of the information they inputted
  //            utils for calling the alert
              let utils = Utils();
  //            adjsut the time based on where the user is
              var hoursFromGMTString = String()
              let hoursFromGMT = secondsFromGMT / 3600
              if hoursFromGMT >= 0{
                  hoursFromGMTString = ("+\(hoursFromGMT)")
              }
              else{
                 hoursFromGMTString = ("\(hoursFromGMT)")
              }
              
  //            1. did the user add a title
              if self.titleInput.text == ""{
                      let button = AlertButton(title: "OK", action: {
                          print("OK clicked");
                      }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                  
                  let alertPayload = AlertPayload(title: "Event Title!", titleColor: UIColor.red, message: "Your event needs a Title, please add one.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                  
                      utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true);
              }
  //                2. did the user add a location
              else if self.locationInput.text == ""{
                  
                      let button = AlertButton(title: "OK", action: {
                          print("OK clicked");
                      }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                  
                  let alertPayload = AlertPayload(title: "Event Location!", titleColor: UIColor.red, message: "Your event needs a Location, please add one.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                  
                      utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true);
                  
              }
  //            3.1 did the user add an event start time
              else if self.startTimeInput.text == ""{
                  let button = AlertButton(title: "OK", action: {
                          print("OK clicked");
                      }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                  
                  let alertPayload = AlertPayload(title: "Event Start Time!", titleColor: UIColor.red, message: "Your event needs a Start Time, please add one.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                  
                      utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true);
              }
              
  //            3.2 did the user add an event end time
              else if self.endTimeInput.text == ""{
                             let button = AlertButton(title: "OK", action: {
                                     print("OK clicked");
                                 }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                             
                             let alertPayload = AlertPayload(title: "Event End Time!", titleColor: UIColor.red, message: "Your event needs an End Time, please add one.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                             
                                 utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true);
              }
  //            3.3 is the start date before the end date
              
              else if self.dateFormatterTZ.date(from: ("\("2000-01-01") \(self.endTimeInput.text!) GMT\(hoursFromGMTString)"))! <= self.dateFormatterTZ.date(from: "\("2000-01-01") \(self.startTimeInput.text!) GMT\(hoursFromGMTString)")!{
                  
                  let button = AlertButton(title: "OK", action: {
                          print("OK clicked");
                      }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                  
                  let alertPayload = AlertPayload(title: "Event Time!", titleColor: UIColor.red, message: "Your event End Time is before the Start Time, please amend.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                  
                      utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true);
              }
  //            4.do the inputs chosen retrun any dates
  //            4.1 run the find dates prior to our check
              else if startDatesChosen.count == 0{
                  let button = AlertButton(title: "OK", action: {
                          print("OK clicked");
                      }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                  
                  let alertPayload = AlertPayload(title: "No Event Dates!", titleColor: UIColor.red, message: "No dates in search period, ensure there are dates in the period.", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
                  
                      utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true)
              }
              else{
  
//            we passed all the checks
//            1. run the save the event information func
            saveTheEventInformation()
              }
            
      }
    
    
    func saveTheEventInformation(){
                print("contactsSelected: \(contactsSelected)")
                
//            MARK: loop through a series of checks to update the users invited to the event and save down the event
        //        0. if the user didn't make any change to users so the event we can save down the new event information
                    if deletedUserIDs.count == 0 && deletedNonUserInviteeNames.count == 0 && contactsSelected.count == 0{
                        print("user didn't change the invitees")
                        commitDataToDB(deletedUsers: false, deletedNonUser: false, addedNewInvitees: false, nonUserNames: [""], userNames: [""], userIDs: currentUserSelectedEvent.users, deletedUserIDs: deletedUserIDs)
                    }
                    else{
        //        1. Did the user delete users and non users and not add anyone?
                if deletedUserIDs.count != 0 && deletedNonUserInviteeNames.count != 0 && contactsSelected.count == 0{
                    deletedUsers{
                        self.deletedNonUsers {
//                            create a list of users we want to send an amended notification to, this is the user now include in the event, we need to remove anyone the user has deleted
                            var currentUsers = currentUserSelectedEvent.users
//                            we remove any deleted users from our list of userIDs
                            for user in deletedUserIDs{
                                if let index = currentUsers.index(of: user){
                                    currentUsers.remove(at: index)
                                }
                            }
                            self.commitDataToDB(deletedUsers: true, deletedNonUser: true, addedNewInvitees: false, nonUserNames: [""], userNames: [""], userIDs: currentUsers, deletedUserIDs: deletedUserIDs)
//            5. reset the tracking array
                                        deletedUserIDs.removeAll()
                        }
                    }
                }
        //        2. Did the user delete users and not add anyone?
                        if deletedUserIDs.count != 0 && contactsSelected.count == 0{
                            deletedUsers{
//                            create a list of users we want to send an amended notification to, this is the user now include in the event, we need to remove anyone the user has deleted
                        var currentUsers = currentUserSelectedEvent.users
//                            we remove any deleted users from our list of userIDs
                            for user in deletedUserIDs{
                                    if let index = currentUsers.index(of: user){
                                            currentUsers.remove(at: index)
                                                }
                                    }
                                self.commitDataToDB(deletedUsers: true, deletedNonUser: false, addedNewInvitees: false, nonUserNames: [""], userNames: [""], userIDs: currentUsers, deletedUserIDs: deletedUserIDs)
//            5. reset the tracking array
                                    deletedUserIDs.removeAll()
                            }
                        }
                        
        //        3. Did the user delete non users and not add anyone?
                        if deletedNonUserInviteeNames.count != 0 && contactsSelected.count == 0{
                            deletedNonUsers {
                                self.commitDataToDB(deletedUsers: false, deletedNonUser: true, addedNewInvitees: false, nonUserNames: [""], userNames: [""], userIDs: currentUserSelectedEvent.users, deletedUserIDs: deletedUserIDs)
                            }
                        }
        //        4. Did the user add somone new to the event?
                        if contactsSelected.count != 0{
        //                    check if the user also deleted anyone
                            if deletedUserIDs.count != 0{
                                deletedUsers{}
                                
                            }
                            if deletedNonUserInviteeNames.count != 0{
                                deletedNonUsers {}
                            }
                                   print("the user has added new invitees")
                                        
//                1. get the phone numbers and names of the new users added
                            self.getSelectedContactsPhoneNumbers2{selectedPhoneNumbers,selectedNames in

                                        
//                2. confirm which of the new invitees are users or not and add them to the arrya
                                self.createUserIDArrays(phoneNumbers: selectedPhoneNumbers, names: selectedNames) { (nonExistentArray, existentArray, userNameArray, nonExistentNameArray) in
                                                        
                                        print("nonExistentArray \(nonExistentArray)")
                                        print("existentArray \(existentArray)")
                                                        
                        //           3. adds the non users to the database
                                        self.addNonExistingUsers2(phoneNumbers: nonExistentArray, eventID: currentUserSelectedEvent.eventID, names: nonExistentNameArray)
                                                        
                        //            4. Adds the user event link to the userEventStore. this also adds the required availability notification
                                    self.userEventLinkArray(userID: existentArray, userName: userNameArray, eventID: currentUserSelectedEvent.eventID){
                                                            
                                                        }
//           5. Add the new user names and IDs to the database
                                    self.commitDataToDB(deletedUsers: false, deletedNonUser: false, addedNewInvitees: true, nonUserNames: nonUserInviteeNames + nonExistentNameArray, userNames: inviteesNames + userNameArray, userIDs: inviteesUserIDs + existentArray, deletedUserIDs: deletedUserIDs)
                                    
//                                    post a notification to tell the new users to download the userAvailability Arrays
                                    for avail in currentUserSelectedAvailability{
                                        self.availabilityCreatedNotification(userIDs: existentArray, availabilityDocumentID: avail.documentID)
                                    }

                                                        print("new users added")
                                                        
                                        //            remove the selected contacts from the array
                                                     contactsSelected.removeAll()
                                                        inviteesNamesNew.removeAll()
                                                        selectedContacts.removeAll()
                                    }
                            
                        }
                    }
        }
        
    }
    
    //    fucntion to commit data to the database
    func commitDataToDB(deletedUsers: Bool, deletedNonUser: Bool, addedNewInvitees: Bool, nonUserNames: [String], userNames: [String], userIDs: [String], deletedUserIDs: [String]){
            print("running func commitDataToDB - inputs: deletedUsers: \(deletedUsers) deletedNonUser: \(deletedNonUser) nonUserNames: \(nonUserNames) addedNewInvitees:\(addedNewInvitees) userNames:\(userNames) userIDs \(userIDs)")
            
//            variable to hold the userIDs of the users we need to send notifications to
            
            
            
//           1. we save down the new list of users, we have to do this first to avoid any issues with data being pulled before we have updated the database
            //                            did the user delete users
                if deletedUsers == true{
//                    remove the users from the event request
                dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).setData(["users": inviteesUserIDs, "currentUserNames": inviteesNames], merge: true)
                                            
                            }
            //                         did the user delete non users
                if deletedNonUser == true{
                dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).setData(["nonUserNames": nonUserInviteeNames], merge: true)
                            }
                if addedNewInvitees == true{
                dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).setData(["users": userIDs, "currentUserNames": userNames, "nonUserNames": nonUserNames], merge: true)
                                        }
            
//            utilisities for the notifications
            let utils = Utils()
            
            //            set the global settings for saving the new data
                            
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
                        
                        for date in startDatesChosen{
            //                we need to add the time chosen by the user to the date array startDatesChosen, 2020-09-24 00:00 CDT
                            let yyyymmdd = date[0...9]
                            let tz = date[17...19]
                            startDatesNewEvent.append("\(yyyymmdd) \(newEventStartTimeLocal) \(tz)")
                            endDatesNewEvent.append("\(yyyymmdd) \(newEventEndTimeLocal) \(tz)")
                        }
                      
                      let endDateString = endDatesNewEvent.last![0...9]
                      let startDateString = startDatesNewEvent.first![0...9]
                      
          //            we commit the new data into the database
          //            commit the updated event information to the database, we merge the data, if there are changes to the user invitees we deal with this later in the code
                      dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).setData(["eventDescription" : newEventDescription, "location" : newEventLocation, "endTimeInput" :newEventEndTime, "startTimeInput" :newEventStartTime, "endDateInput" : endDateString, "startDateInput" : startDateString, "daysOfTheWeek" : daysOfTheWeekNewEvent, "startDates": startDatesNewEvent, "endDates": endDatesNewEvent, "locationLongitude": newEventLongitude, "locationLatitude": newEventLatitude], merge: true)
                      
              //            updated the realtime database
                      let rRef = Database.database().reference()
                      rRef.child("events/\(currentUserSelectedEvent.eventID)/eventDescription").setValue(newEventDescription)
                      
//            check whether the user changed the dates for the event and ask them if they would like to ask users to refresh their availability
                      print("startDatesNewEvent: \(startDatesNewEvent) != currentUserSelectedEvent.startDateArray \(currentUserSelectedEvent.startDateArray)|| endDatesNewEvent: \(endDatesNewEvent) != currentUserSelectedEvent.endDateArray: \(currentUserSelectedEvent.endDateArray)")
                      if startDatesNewEvent != currentUserSelectedEvent.startDateArray || endDatesNewEvent != currentUserSelectedEvent.endDateArray{
                          
          //                we ask the user if they would like to refresh the users availability
                          
          //                MARK: button 1 do not update availability
                          let button = AlertButton(title: "Yes", action: {
                              print("Yes clicked")
              //               update the availability information
                            
                            self.eventAmendedNotification(userIDs: userIDs, eventID: currentUserSelectedEvent.eventID, amendWithAvailability: true)
                              
                              dbStore.collection("eventRequests").document(currentUserSelectedEvent.eventID).updateData(["chosenDate" : FieldValue.delete(), "chosenDateDay" : FieldValue.delete(), "chosenDateMonth" : FieldValue.delete(), "chosenDateYear" : FieldValue.delete(), "chosenDatePosition" : FieldValue.delete()])
                              
          //                              post a notification to the real time DB to trigger the push notification
                              let ref = Database.database().reference()
                              let userIDs = currentUserSelectedEvent.users
                                              
          //                                loop through each user ID and post to the database
                              for i in userIDs{
          //                                    dont post a notification for the current user
                              if i == user!{
                                  }
                          else{
          //                                        add the notification to the realtime database
                      ref.child("userEventLink/\(i)/amendedEvent/\(currentUserSelectedEvent.eventID)").setValue(currentUserSelectedEvent.eventID)
                                      }
                              }
                  let button11 = AlertButton(title: "OK", action: {
                                                      print("OK clicked")
                  //                update the information and save it down
                                                      self.dismiss(animated: true)
                                                  }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                                              
                      let alertPayload11 = AlertPayload(title: "Event Saved!", titleColor: UIColor.red, message: "Your event has been saved.", messageColor: MyVariables.colourPlanrGreen, buttons: [button11], backgroundColor: UIColor.clear, inputTextHidden: true)
                                              
                                  utils.showAlert(payload: alertPayload11, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true)
                              
                              
                              
                          }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                          
          //                MARK: button 2 do not update availability
                          let button2 = AlertButton(title: "No", action: {
                              print("No clicked")
          //                update the information and save it down
                              
          //                AmendNotifiction  - post to the eventNotification to table that the event has been amended
                      self.eventAmendedNotification(userIDs: userIDs, eventID: currentUserSelectedEvent.eventID, amendWithAvailability: false)
                              
                              
          //            show the user a notification letting them know the data was updated and dismiss the screen
                      let button21 = AlertButton(title: "OK", action: {
                                              print("OK clicked")
          //                update the information and save it down
                                              self.dismiss(animated: true)
                                          }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                                      
                      let alertPayload21 = AlertPayload(title: "Event Saved!", titleColor: UIColor.red, message: "Your event has been saved.", messageColor: MyVariables.colourPlanrGreen, buttons: [button21], backgroundColor: UIColor.clear, inputTextHidden: true)
                                      
                          utils.showAlert(payload: alertPayload21, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true)
                          }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected)
                      
                      let alertPayload = AlertPayload(title: "Event Timings Chnaged!", titleColor: UIColor.red, message: "Your event time or dates have changed, would you like Planr to refresh your invitee availability?", messageColor: MyVariables.colourPlanrGreen, buttons: [button,button2], backgroundColor: UIColor.clear, inputTextHidden: true)
                      
                          utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true);
                          
                      }
                      
          //            the user did not update the event timings so we simply let them know the event was udpated
                      else{
                          let button11 = AlertButton(title: "OK", action: {
                                                              print("OK clicked")
                          //                update the information and save it down
                                                              self.dismiss(animated: true)
                                                          }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
                                                      
                              let alertPayload11 = AlertPayload(title: "Event Saved!", titleColor: UIColor.red, message: "Your event has been saved.", messageColor: MyVariables.colourPlanrGreen, buttons: [button11], backgroundColor: UIColor.clear, inputTextHidden: true)
                                                      
                              utils.showAlert(payload: alertPayload11, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true)
                      }
            
            //                            we need to check if the user deleted anyone from the event
                var usersToSendAmendNotification2 = [String]()
                if deletedUsers == true{ usersToSendAmendNotification2 = inviteesUserIDs}
                else{ usersToSendAmendNotification2 = userIDs}
            
            self.eventAmendedNotification(userIDs: usersToSendAmendNotification2, eventID: currentUserSelectedEvent.eventID, amendWithAvailability: false)
                   
            }
        
        
    //    delete data for users of the app that have been removed
        func deletedUsers(completion: @escaping () -> Void){
            
                        print("user deleted invitees that are already users \(deletedUserIDs)")
                  
            //            1. deletes the userEventStore
                                deleteUserEventLinkArray(userID: deletedUserIDs, eventID: currentUserSelectedEvent.eventID)
            //            2. clear the user
//                                deleteEventStoreAvailability(eventID: currentUserSelectedEvent.eventID)
            //            3. post a deleted notification for these users, so their app deletes the event
                                eventDeletedNotification(userIDs: deletedUserIDs, eventID: currentUserSelectedEvent.eventID)

            //            4. post delete notification for the users availability, so other users delete the removed users thier availability deleted
                                    for i in deletedUserIDs{
                                    let filteredAvailability = currentUserSelectedAvailability.filter {$0.uid == i}
                                    let filteredAvailabilityDocumentID = filteredAvailability[0].documentID
                                    availabilityDeletedNotification(userIDs: inviteesUserIDs, availabilityDocumentID: filteredAvailabilityDocumentID)
//                                        we also need to tell the deleted user to remove the availability for the event
                                        deleteRemoveUserAvailabilityNotification(userID: i)
                                        
//                                        delete the users ID in the messages tree of the DB
                                        let ref = Database.database().reference()
                                        ref.child("messageNotifications/\(currentUserSelectedEvent.eventID)/\(i)").removeValue()   
                                    }
            completion()
            
        }
        
    //    delete data for non users of that app that have been removed
        func deletedNonUsers(completion: @escaping () -> Void){
            
            print("user deleted invitees that are not users \(deletedNonUserInviteeNames)")
                           
            //                1. remove the non user invitees
                         deleteNonUsers(eventID: currentUserSelectedEvent.eventID, userNames: deletedNonUserInviteeNames)
            //                2. reset the tracking array
                            deletedNonUserInviteeNames.removeAll()
            completion()
            
        }
    
    
    func setUpTheInviteeTableView(completion: @escaping () -> Void){
        inviteesNames = currentUserSelectedEvent.currentUserNames
        nonUserInviteeNames = currentUserSelectedEvent.nonUserNames
        inviteesNamesLocation = currentUserSelectedEvent.users
        
        print("inviteesNames \(inviteesNames) nonUserInviteeNames \(nonUserInviteeNames)")
        
        completion()
    }
    
  }


  // setup the collectionView
  extension NL_editEvent: UICollectionViewDelegate, UICollectionViewDataSource {
      
  //    we only have one section in each collectionView
      func numberOfSections(in collectionView: UICollectionView) -> Int {
          return 1
      }
      
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          
        var numberOfItems = Int()
        

        if collectionView == collectionViewDates{
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
          
  //            we don't do anything when the user selects a date in the collectionView
           if collectionView == collectionViewDates{
              print("user selected a date - we do nothing")
          }
      }
  }

  // setup the collectionView layout

  extension NL_editEvent: UICollectionViewDelegateFlowLayout {
      
      
      // sets the size of the cell based on the collectionView
      func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
          var size = CGSize()
          
        if collectionView == collectionViewDates{
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


extension NL_editEvent: UITableViewDataSource, UITableViewDelegate{

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    var numberOfRows = Int()
    
    let combinedInvitees = inviteesNames + nonUserInviteeNames + inviteesNamesNew
    numberOfRows = combinedInvitees.count
    
    print("numberOfRows \(numberOfRows)")

    
    return numberOfRows
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdTV) as! NL_contactTableViewCell
    
    let combinedInvitees = inviteesNames + nonUserInviteeNames + inviteesNamesNew
    print("combinedInvitees \(combinedInvitees)")
    
    cell.cellText.text = combinedInvitees[indexPath.row]
    cell.addImageView.image = UIImage(named: "deleteCode")
    
//    we do not want the cell to be highlighted when the user selects it
    cell.selectionStyle = .none

        return cell
    
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 70
    
    ;//Choose your custom row height
}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let utils = Utils()
        
        if indexPath.row == 0{
//         the user has tried to delete themselves, we tell them not to do this
            
            let button = AlertButton(title: "OK", action: {
                print("OK clicked");
            }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
        
        let alertPayload = AlertPayload(title: "Not Allowed!", titleColor: UIColor.red, message: "You can't delete yourself from the event", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear, inputTextHidden: true)
        
            utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true);
        }
        else{
        
        //  which row was the button tapped on
        print("Button tapped on row \(indexPath.row)")
        
//        number of invitees already invited who are alrady users
        let originalInvitees = inviteesNames.count - 1
        print("originalInvitees: \(originalInvitees)")
//        the position of the start of the non user names that have been invited
        let nonUserInvitees = nonUserInviteeNames.count + originalInvitees
        print("nonUserInvitees: \(nonUserInvitees)")
//        total number of invitees
        let combinedInvitees = inviteesNames + nonUserInviteeNames + inviteesNamesNew
        print("combinedInvitees: \(combinedInvitees)")
        
//            if the index path is less than or euqal to the position of the user invitees than we know the user had removed a user invitee
        if indexPath.row <= originalInvitees {
        deletedInviteeNames.append(inviteesNames[indexPath.row])
        print("deleted invitee: \(inviteesNames[indexPath.row])")

            
        deletedUserIDs.append(inviteesNamesLocation[indexPath.row])
            print("deletedUserIDs: \(deletedUserIDs)")
            
        inviteesNames.remove(at: indexPath.row)
            
        let indexOfItem = inviteesUserIDs.index(of: inviteesNamesLocation[indexPath.row])!
        inviteesUserIDs.remove(at: indexOfItem)
        inviteesNamesLocation.remove(at: indexPath.row)
       
            
        print("new invitee names \(inviteesNames)")
        print("new invitee uid \(inviteesUserIDs)")
        tableViewContacts.reloadData()
//        remove the selected status of the user
        }
        
//        if the index path is greater than the original invitees but less the non user invitees, the user removed a non user invitee
        if originalInvitees < indexPath.row && indexPath.row  <= nonUserInvitees{
            
            
            deletedNonUserInviteeNames.append(combinedInvitees[indexPath.row])
            print("deletedNonUserInviteeNames: \(deletedNonUserInviteeNames)")
            let indexOfItem = nonUserInviteeNames.index(of: combinedInvitees[indexPath.row])!
            nonUserInviteeNames.remove(at: indexOfItem)
            print("nonUserInviteeNames: \(nonUserInviteeNames)")
            tableViewContacts.reloadData()
            
        }
        
//            the user has removed one of the newly added users
        if indexPath.row > nonUserInvitees{
            
          inviteesNamesNew.remove(at: indexPath.row - (nonUserInvitees + 1))
            contactsSelected.remove(at: indexPath.row - (nonUserInvitees + 1))
            tableViewContacts.reloadData()
            
        }
    }
    }
}


