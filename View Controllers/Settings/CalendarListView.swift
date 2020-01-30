//
//  CalendarListView.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 23/02/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI


class  CalendarListView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var eventStore = EKEventStore()
    
    //    List of calendars the user has selected
    let dateFormatter = DateFormatter()
    

    @IBOutlet var calendarTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Calendars"
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        calendarTableView.dataSource = self
        calendarTableView.delegate = self
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        self.calendarTableView.register(UITableViewCell.self, forCellReuseIdentifier: "calendarListCell")
        navigationController?.delegate = self
        
        checkCalendarStatus()
//        loadCalendars()
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        
        
    }
    
    //   function to check whether we already have access to the calendar, there are 4 outcomes
    //    notDetermined - we need to request access
    //    authorized - we already have access
    //    denied - we need to show that the app won function (to do)
    //    restrivted - we need to show that the app won function (to do)
    
    func checkCalendarStatus(){
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            print("We got access")
            loadCalendars()
            calendarTableView.reloadData()
        case EKAuthorizationStatus.denied:
            requestAccessToCalendar()
            print("No access")
            
        case .restricted:
            print("Access denied")
        }
        
    }
    
    //    requests access to the calendar
    
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                print("we got access")
                self.calendarTableView.reloadData()
            }
            else{
                print("no access")
            }
            
        })
        
        
    }
    
    
//    Creates an array of inegers that are used to track which calendars have been selected. Function loops through the number of calendars available to create an array of 1 to signify the calendars being selected
    func loadCalendars(){
        var calendars = [EKCalendar]()
        
        print("running func loadCalendars")
        
        calendars = eventStore.calendars(for: EKEntityType.event)
        
        let noCalendars = calendars.count
        print("number of calendars: \(noCalendars)")
        
//        If the calendar array hasnt been created previously then then the function creates a new array

            var n = 0
            var y = 0
            
            while n < noCalendars{
                
                print("calendar title: \(calendars[n].title), calendar struc title \(SelectedCalendarsStruct.calendarsStruct[y].title)")
                
            
                if calendars[n].title == SelectedCalendarsStruct.calendarsStruct[y].title{
                    
                    SelectedCalendarsStruct.selectedCalendarArray.append(1)
                    
                    y = 0
                    n = n + 1
                    
                    
                }
                else{
                    
                    if y == SelectedCalendarsStruct.calendarsStruct.count - 1{
                        
                        SelectedCalendarsStruct.selectedCalendarArray.append(0)
                        y = 0
                        n = n + 1
                        
                    }
                    else{
                    y = y + 1
                    }
   
                }
                 


            }
        

        }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var calendars = [EKCalendar]()
        
        calendars = eventStore.calendars(for: EKEntityType.event)
        
        return (calendars.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "calendarListCell")!
        
        var calendars = [EKCalendar]()
        
        calendars = eventStore.calendars(for: EKEntityType.event)
        
        let calendarName = calendars[(indexPath as NSIndexPath).row].title
        
        cell.textLabel?.text = calendarName
        cell.tintColor = UIColor.black
        
        if SelectedCalendarsStruct.selectedCalendarArray[indexPath.row] == 1 {
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
        
        
        if SelectedCalendarsStruct.selectedCalendarArray[indexPath.row] == 1 {
            
            
            SelectedCalendarsStruct.calendarsStruct.removeAll(where: {$0.title == calendars[indexPath.row].title})
            
            SelectedCalendarsStruct.selectedCalendarArray[indexPath.row] = 0
           

            
        }
        else {
            
            SelectedCalendarsStruct.calendarsStruct.append(calendars[indexPath.row])
            
            SelectedCalendarsStruct.selectedCalendarArray[indexPath.row] = 1
            
        }
        
//        used to remvove the calendars that have been deselected
        
        print("final array \(SelectedCalendarsStruct.calendarsStruct)")
//        createCalendarArray()
        calendarTableView.deselectRow(at: indexPath, animated: true)
        calendarTableView.reloadData()
        
    }
    
    
}


extension CalendarListView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {}
}
