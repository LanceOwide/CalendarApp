//
//  SettingsPage.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 16/07/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

class SettingsPage: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    var settingsList = ["Select Calendars","Select Save Calendar","Account Settings","App Settings","About"]
    
    var settingsDetailsList = ["Select the calendars Planr will use to determine your availability","Select the calendar Planr will use to save events you've been invited to", "Update your name, email address and phone number", "Define settings for certain app features","Company information and privacy policy"]
    
    var segueList = ["selectCalendarSegue","saveToCalendarsSegue","accountSettings","appSettingsSegue","aboutSegue"]
    
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.rowHeight = 100
        
        self.title = "Settings"
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        cell = settingsTableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel?.text = settingsList[indexPath.row]
        cell.detailTextLabel?.text = settingsDetailsList[indexPath.row]
//        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.numberOfLines = 2
        cell.textLabel?.font = UIFont.systemFont(ofSize: 30)
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("selected cell \(indexPath.row)")
        
        if segueList[indexPath.row] == "" {
            
            print("Segue doesn't exist")
            
            settingsTableView.deselectRow(at: indexPath, animated: true)
            
        }
        else{
     
            performSegue(withIdentifier: segueList[indexPath.row], sender: Any.self)
            
            settingsTableView.deselectRow(at: indexPath, animated: true)
        }
  
    }
    

}
