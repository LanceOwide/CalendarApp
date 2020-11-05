//
//  RegisterViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 25/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FlagPhoneNumber
import MBProgressHUD


var registeredName = String()
var registeredEmail = String()

class RegisterViewController: UIViewController {
  
    var settings = dbStore.settings
    
    
    @IBOutlet var registerEmail: UITextField!
    
    @IBOutlet var registerName: UITextField!
    
    
    
    @IBOutlet weak var headerLabel: UILabel!
    
    
    @IBOutlet weak var registerEmailNextButtonSettings: UIButton!
    

    @IBAction func registerEmailNextButton(_ sender: Any) {
        print(registerName.text as Any)
        print(registerEmail.text as Any)
        
        if registerName.text == "" {
            
            showProgressHUD(notificationMessage: "Please enter your name", imageName: "Unavailable", delay: 1)
            
        }
        
       else if registerEmail.text == "" {
            
            showProgressHUD(notificationMessage: "Please enter your email", imageName: "Unavailable", delay: 1)
            
        }
        
            
        else if isValidEmail(emailStr: registerEmail.text!) == false{
            
            
            showProgressHUD(notificationMessage: "Please enter a valid email address", imageName: "Unavailable", delay: 1)
    
        }
        
        else{
            registeredName = registerName.text!.capitalized
            registeredEmail = registerEmail.text!
            
            UserDefaults.standard.set(registerName.text, forKey: "name")
            
            self.performSegue(withIdentifier: "registerEmailName", sender: self)
  
        }}
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: MyVariables.colourPlanrGreen)
        
        
//        sets the background colour of the view
        view.backgroundColor = .white
//        setBackgroundColour(currentView: view)
        
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        

        dbStore.settings = settings
        
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
//        self.view.addGestureRecognizer(tapGesture)
        
        
        //        setup next button
        buttonSettings(uiButton: registerEmailNextButtonSettings)
        
        
        registerName.alpha = 0.90
        registerEmail.alpha = 0.90
        
        registerName.autocapitalizationType = .words
        
        
        let welcomeText = NSMutableAttributedString(string: "Plan",
                                                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 60),NSAttributedString.Key.foregroundColor: MyVariables.colourPlanrGreen])
        
        welcomeText.append(NSMutableAttributedString(string: "r",
                                                     attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 60),NSAttributedString.Key.foregroundColor: MyVariables.colourPlanrGreen]))
        
        headerLabel.attributedText = welcomeText
        
        
    }
    

    

     func isValidEmail(emailStr:String) -> Bool {

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    

    

        }


