//
//  saveCalendarViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 30/10/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import EventKit


var defaultSaveCalendar = [EKCalendar]()


class saveCalendarViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var saveCalendarTableView: UITableView!
    
    var calendarsList = [EKCalendar]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Save Calendars"

        
        saveCalendarTableView.delegate = self
        saveCalendarTableView.dataSource = self
        saveCalendarTableView.allowsMultipleSelection = false
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        checkCalendarStatus()
        calendarListAllowsModify()
        

        // end of view did load
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
                self.saveCalendarTableView.reloadData()
            }
            else{
                print("no access")
            }
            
        })
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        return (calendarsList.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = saveCalendarTableView.dequeueReusableCell(withIdentifier: "selectSaveCalendarCell")!
        
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
        
        let calendarName = calendarsList[(indexPath as NSIndexPath).row].title
        
        cell.textLabel?.text = calendarName
        cell.tintColor = UIColor.black
        
        
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
            
            saveCalendarTableView.deselectRow(at: indexPath, animated: true)
            
            saveCalendarTableView.reloadData()

    }
    
    func calendarListAllowsModify(){
        
        for calendars in eventStore.calendars(for: EKEntityType.event){
            
            if calendars.allowsContentModifications == true{
                
                calendarsList.append(calendars)
                
            }
            else{
                
                print("calendar not allowing modifications")
                
            }
            
            
        }
        
        
        
    }
    

}
