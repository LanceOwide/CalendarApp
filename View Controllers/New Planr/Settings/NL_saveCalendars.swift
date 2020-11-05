//
//  NL_saveCalendars.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/27/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class NL_saveCalendars: UIViewController {
    
    
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
        
//        setup the screen
        calendarListAllowsModify()
        
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
    
    
    
    
    //    create the progress bar and title
        lazy var inputTopView: UIView = {
            print("setting up the inputTopView")
    //        set the variables for the setup
            let headerLabelText = "Select Save Calendars"
            let instructionLabelText = "Choose the calendar Planr will integrate with to save your events"
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
    
    
//    check which calendars we can make modifications to
    func calendarListAllowsModify(){
        
        for calendars in eventStore.calendars(for: EKEntityType.event){
            
            if calendars.allowsContentModifications == true{
                
                calendarsList.append(calendars)
                
            }
            else{
                
                print("calendar not allowing modifications")
                
            }}}
}

extension NL_saveCalendars: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (calendarsList.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewCalendar.dequeueReusableCell(withIdentifier: cellId) as! NL_contactTableViewCell
        
        var currentSaveCalendar = [EKCalendar]()
        
        
        let defaultSaveEvents = eventStore.defaultCalendarForNewEvents
        
        print("defaultSaveEvents: \(String(describing: defaultSaveEvents))")
        
        if defaultSaveCalendar.isEmpty == true{
            
            print("no default calendar selected")

            currentSaveCalendar.append(defaultSaveEvents!)
            
            
        }
        else{
            
            currentSaveCalendar = defaultSaveCalendar
            
        }
        
        calendars = eventStore.calendars(for: EKEntityType.event)
        
        let calendarName = calendarsList[indexPath.row].title
        
        cell.textLabel?.text = calendarName
        cell.tintColor = UIColor.black
        cell.eventImageView.isHidden = true
        cell.addImageView.isHidden = true
        
        
        if calendarsList[indexPath.row].calendarIdentifier == currentSaveCalendar[0].calendarIdentifier {
            cell.accessoryType = .checkmark
        }
        
        else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defaultSaveCalendar.removeAll()
        
        defaultSaveCalendar.insert(calendarsList[indexPath.row], at: 0)
        
        UserDefaults.standard.set(calendarsList[indexPath.row].calendarIdentifier, forKey: "saveToCalendar")
        
        tableViewCalendar.deselectRow(at: indexPath, animated: true)
        
        tableViewCalendar.reloadData()
    }
}
