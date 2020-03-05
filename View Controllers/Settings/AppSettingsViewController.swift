//
//  AppSettingsViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 22/10/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase

var justSignedOutBool = false


class AppSettingsViewController: UIViewController {

    
    
    @IBOutlet weak var toolTipToggle: UISwitch!
    
    
    @IBOutlet weak var signOutButton: UIButton!
    
    
    
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        
        Auth.auth().removeStateDidChangeListener(authListener!)
        UserDefaults.standard.set("", forKey: "authVerificationID")
        
        authStatusListener = false

//        when the user logs out we want to delete all their app data, otherwise logging in with another users credentials will not work
        deleteAllRecords(entityName:"CoreDataAvailability")
        deleteAllRecords(entityName:"CoreDataEvent")
        
            let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            
          performSegue(withIdentifier: "signOutSegue", sender: self)
            
            justSignedOutBool = true
            
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
        
    }
    

    
    @IBAction func toolTipSwitch(_ sender: UISwitch) {
        
        if (sender.isOn == true){
            UserDefaults.standard.set(true, forKey: "permenantToolTips")
        }
        
        if (sender.isOn == false){
            UserDefaults.standard.set(false, forKey: "permenantToolTips")
        }
        
        
        
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "App Settings"
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        
        buttonSettings(uiButton: signOutButton)
        
        
        
        if UserDefaults.standard.bool(forKey: "permenantToolTips") == true {
            
            toolTipToggle.isOn = true
        }
        else{
            
            toolTipToggle.isOn = false
            
        }
        
        
        
        
    }
    



}
