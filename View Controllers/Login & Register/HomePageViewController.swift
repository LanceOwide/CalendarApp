//
//  HomePageViewController.swift
//  calandarAppPlayground
//
//  Created by Lance Owide on 25/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase


var authListener: AuthStateDidChangeListenerHandle?
var authStatusListener = false


class HomePageViewController: UIViewController {
    
    
    @IBOutlet weak var openingTitleLabel: UILabel!
    
    @IBOutlet weak var loginButtonSettings: UIButton!
    
    
    
    @IBOutlet weak var oldUserButton: UIButton!
    
    
    @IBOutlet weak var txtPrivacy: UITextView!
    
    

    @IBAction func oldUserButtonPressed(_ sender: UIButton) {
        
            checkLogIn()
            performSegue(withIdentifier: "oldUserSegue", sender: self)
               
    }
    
    
    
    
    @IBAction func loginButton(_ sender: Any) {
        

            checkLogIn()

            performSegue(withIdentifier: "newUserSegue", sender: self)
            
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        
//        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: true, isBackButtonHidden: true, tintColour: UIColor.black)

        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        
        
        //        setup register button
        buttonSettings(uiButton: loginButtonSettings)
        buttonSettings(uiButton: oldUserButton)
        
        
            navigationItem.hidesBackButton = true
        
        
//        setup the privacy policy statement
        
        setupPrivacyStatement(UITextView: txtPrivacy)
        
        
//        only check the users authentication state if they haven't just logged out, the check should log in the user in automatically
        
        if justSignedOutBool == false{
            
            print("user hasn't just signed out")
          
            checkLogIn()
        }
        else{
            
            print("user has just signed out")
            
        }

        
        let welcomeText = NSMutableAttributedString(string: "Plan",
                                                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 70),NSAttributedString.Key.foregroundColor: UIColor.white])
        
        welcomeText.append(NSMutableAttributedString(string: "r",
                                                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 70),NSAttributedString.Key.foregroundColor: UIColor.white]))
        
        
        openingTitleLabel.attributedText = welcomeText
        loginButtonSettings.backgroundColor = UIColor.white
        
        
    }
    
    
//    This listener will detect if the users login status changes
    func checkLogIn(){
        
        if authStatusListener == true{
            
        }
        else{
            
        authStatusListener = true
            
            print("listener activated")
        
        authListener = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                
                print("Auth: \(auth)")
                print("User: \(String(describing: user))")
                
                self.performSegue(withIdentifier: "existingUserSegue2", sender: self)
            } else {
                
//                we should probably log out the user here and return to home page
                

            }}}}
    
    
    func setupPrivacyStatement(UITextView: UITextView){
      
       let string = "View our privacy and data policy"
       
       let attributedLinkString = NSMutableAttributedString(string: string, attributes:[NSAttributedString.Key.link: URL(string: "https://planr.me/Planr-App-Privacy-Policy/")!])
       
       UITextView.isUserInteractionEnabled = true
       UITextView.isEditable = false
        UITextView.textColor = UIColor.white
        
        UITextView.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        UITextView.linkTextAttributes = [ .foregroundColor: UIColor.white ]
       UITextView.attributedText = attributedLinkString
        
        
    }
    

}
