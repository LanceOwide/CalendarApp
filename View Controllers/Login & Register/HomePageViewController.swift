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

        
        view.backgroundColor = .white
        
//        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: true, isBackButtonHidden: true, tintColour: MyVariables.colourPlanrGreen)

        
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
                                                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 70),NSAttributedString.Key.foregroundColor: MyVariables.colourPlanrGreen])
        
        welcomeText.append(NSMutableAttributedString(string: "r",
                                                     attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 70),NSAttributedString.Key.foregroundColor: MyVariables.colourPlanrGreen]))
        
        
        openingTitleLabel.attributedText = welcomeText
        loginButtonSettings.backgroundColor = UIColor.white
        
        
    }
    
    
//    This listener will detect if the users login status changes
    func checkLogIn(){
        
        print("running func checkLogIn")
        
        if authStatusListener == true{
            
        }
        else{
        authStatusListener = true
        print("checkLogIn listener activated")
        authListener = Auth.auth().addStateDidChangeListener { auth, userDetail in
            print("Auth state change event triggered")
            if userDetail != nil {
                
                print("Auth: \(auth)")
                print("User: \(String(describing: userDetail?.uid))")
                
                user = userDetail?.uid
                
//                segway the user to the new homePage
                if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_HomePage") as? NL_HomePage {
//                    we have to set the navigation bar to be visible before we show the page
                        self.navigationController?.pushViewController(viewController, animated: true)
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.navigationController?.navigationItem.setHidesBackButton(true, animated: true)
                        
                }
            } else {
                print("checkLogIn user details were nil")
                
//                we should probably log out the user here and return to home page
                
            }}}}
    
    
    func setupPrivacyStatement(UITextView: UITextView){
        
//        eventListenerEngaged = false
//        availabilityListenerEngaged = false
      
       let string = "View our privacy and data policy"
       
       let attributedLinkString = NSMutableAttributedString(string: string, attributes:[NSAttributedString.Key.link: URL(string: "https://planr.me/Planr-App-Privacy-Policy/")!])
       
       UITextView.isUserInteractionEnabled = true
       UITextView.isEditable = false
        UITextView.textColor = UIColor.white
        
        UITextView.backgroundColor = .white
        UITextView.linkTextAttributes = [ .foregroundColor: MyVariables.colourPlanrGreen ]
       UITextView.attributedText = attributedLinkString
        
        
    }
    

}
