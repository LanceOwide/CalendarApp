//
//  NL_selectCalendars.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/27/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class NL_selectCalendars: UIViewController {
    
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
    
//    variables
    var tableViewCalendar = UITableView()
    var cellId = "cellId"
    var eventStore = EKEventStore()
    var calendarsList = [EKCalendar]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setting up the page
        
        
        //        MUST ADD subview
                view.addSubview(inputTopView)
                view.addSubview(inputBottomView)

                        
        // Set its constraint to display it on screen
                inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: topDistance).isActive = true
                inputTopView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
                inputTopView.heightAnchor.constraint(equalToConstant: 80).isActive = true
                
        //        setup view for collectionView
                inputBottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                inputBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                inputBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
                inputBottomView.heightAnchor.constraint(equalToConstant: screenHeight - topDistance - 80).isActive = true
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = MyVariables.colourPlanrGreen
        navigationItem.backBarButtonItem = backItem
    }
    
//    we need to load the calendars before the page loads
    override func viewWillAppear(_ animated: Bool) {
        //        check we have access to calendars
                if checkCalendarStatus2() == true{
        //            load the calendars if we have acccess, otherwise a message asking for access will be displayed
//                    loadCalendars2()
                }
    }
    
    //    create the progress bar and title
        lazy var inputTopView: UIView = {
            print("setting up the inputTopView")
    //        set the variables for the setup
            let headerLabelText = "Select Calendars"
            let instructionLabelText = "Choose the calendars Planr will integrate with to determine your availability"
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
            let calendarImage = UIImageView()
            calendarImage.image = UIImage(named: "CalendarSelectedCode")
            calendarImage.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(calendarImage)
            calendarImage.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 16).isActive = true
            calendarImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
            calendarImage.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
            calendarImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
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
            instructionLabel.numberOfLines = 2
            instructionLabel.lineBreakMode = .byWordWrapping
            instructionLabel.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(instructionLabel)
            instructionLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset + 30)).isActive = true
            instructionLabel.widthAnchor.constraint(equalToConstant: screenWidth - 30 - CGFloat(sideInset)).isActive = true
            instructionLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40).isActive = true
            instructionLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            return containerView
        }()
    
    
    lazy var inputBottomView: UIView = {
            
            let textBoxHeight = 50
            let sideInset = 16
            let sideInsetIcon = 24
            let separatorHeight = 1
            let iconSize = textBoxHeight/3
            
            //   setup the view for holding the assets
            let containerView2 = UIView()
            containerView2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight - topDistance - 100)
            containerView2.backgroundColor = UIColor.white
            containerView2.translatesAutoresizingMaskIntoConstraints = false
            
            
            //        trying to add a top view that represents the remainder of the screen
             let topView = UIView()
             topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight - topDistance - 100)
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
            tableViewCalendar = UITableView(frame: .zero)
            tableViewCalendar.translatesAutoresizingMaskIntoConstraints = false
            tableViewCalendar.delegate = self
            tableViewCalendar.dataSource = self
            tableViewCalendar.register(NL_contactTableViewCell.self, forCellReuseIdentifier: cellId)
            tableViewCalendar.tableFooterView = UIView()
            tableViewCalendar.backgroundColor = .white
            tableViewCalendar.isScrollEnabled = true
            tableViewCalendar.rowHeight = 70
            tableViewCalendar.separatorStyle = .singleLine
            tableViewCalendar.separatorColor = MyVariables.colourPlanrGreen
            tableViewCalendar.isUserInteractionEnabled = true
            tableViewCalendar.allowsSelection = true
            tableViewCalendar.allowsMultipleSelection = false
            topView.addSubview(tableViewCalendar)
            tableViewCalendar.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
            tableViewCalendar.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
            tableViewCalendar.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(textBoxHeight) + CGFloat(separatorHeight*10)).isActive = true
            tableViewCalendar.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
            
            return containerView2
        }()

}

extension NL_selectCalendars: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var calendars = [EKCalendar]()
        
        calendars = SelectedCalendarsStruct.calendarsStruct
        
        return (calendars.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewCalendar.dequeueReusableCell(withIdentifier: cellId) as! NL_contactTableViewCell
        
//        pull the selected calendars from the user defaults
        
        let calendarIDArray = UserDefaults.standard.stringArray(forKey: "selectSaveCalendarIDs") ?? []
        
        
        var calendars = [EKCalendar]()
        
        calendars = SelectedCalendarsStruct.calendarsStruct
        
        let calendarName = calendars[indexPath.row].title
        
        cell.textLabel?.text = calendarName
        cell.tintColor = UIColor.black
        cell.addImageView.isHidden = true
        cell.eventImageView.isHidden = true
        
        
        if calendarIDArray.contains(SelectedCalendarsStruct.calendarsStruct[indexPath.row].calendarIdentifier) {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var calendars = [EKCalendar]()
        calendars = eventStore.calendars(for: EKEntityType.event)
        
        var calendarIDArray = UserDefaults.standard.stringArray(forKey: "selectSaveCalendarIDs") ?? []
        
        if calendarIDArray.contains(SelectedCalendarsStruct.calendarsStruct[indexPath.row].calendarIdentifier) {
            
            calendarIDArray.removeAll(where: {$0 == SelectedCalendarsStruct.calendarsStruct[indexPath.row].calendarIdentifier})
            
            SelectedCalendarsStruct.selectedSearchCalendars.removeAll(where: {$0.calendarIdentifier == SelectedCalendarsStruct.calendarsStruct[indexPath.row].calendarIdentifier})
            
        }
        else {
//            we append the calendar identifier
            calendarIDArray.append(SelectedCalendarsStruct.calendarsStruct[indexPath.row].calendarIdentifier)
//            we add the selected calendar to the list to search for
            SelectedCalendarsStruct.selectedSearchCalendars.append(SelectedCalendarsStruct.calendarsStruct[indexPath.row])
            
        }
//        used to remvove the calendars that have been deselected
        
        UserDefaults.standard.setValue(calendarIDArray, forKey: "selectSaveCalendarIDs")
        
        
        tableViewCalendar.deselectRow(at: indexPath, animated: true)
        tableViewCalendar.reloadData()
    }
}
