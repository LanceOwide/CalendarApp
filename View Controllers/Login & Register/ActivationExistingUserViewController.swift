//
//  ActivationExistingUserViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 24/10/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD


var existingUserLoggedIn = false


class ActivationExistingUserViewController: UIViewController {
    
    @IBOutlet weak var textCodeInput: UITextField!

    @IBOutlet weak var resendCodeButton: UIButton!
    
    
    @IBOutlet weak var loginButtonOldUserSettings: UIButton!
    
    
     
    
    @IBAction func loginButtonOldUser(_ sender: UIButton) {
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
        loadingNotification.label.text = "Loading"
        loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
        loadingNotification.mode = MBProgressHUDMode.customView
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID!,
                verificationCode: textCodeInput.text!)
               Auth.auth().signIn(with: credential) { (authResult, error) in
                       if error != nil {
                           print(error!)
                        
                        loadingNotification.hide(animated: true)
                        
                        self.showProgressHUD(notificationMessage: "Verification code did not match, please retry", imageName: "Unavailable", delay: 2)
                        
                           return
                       }
                       else{
                        print("Logging in")
                        
                        existingUserLoggedIn = true
                        
                        loadingNotification.hide(animated: true)
                        
                        UserDefaults.standard.set(loginPhoneNumber, forKey: "userPhoneNumber")
                        
//                        self.performSegue(withIdentifier: "existingUserLoggedIn", sender: self)
        
    }
        
        
    }
    
    }

    
    
    @IBAction func resendButtonPressed(_ sender: UIButton) {
    
    PhoneAuthProvider.provider().verifyPhoneNumber(loginPhoneNumber, uiDelegate: nil) { (verificationID, error) in
        if let error = error {
            print(error)
            return
        }
        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
    }
    
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        view.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        //        move the view up when the keyboard is active
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        buttonSettings(uiButton: loginButtonOldUserSettings)
        buttonSettings(uiButton: resendCodeButton)
        
        
        resendCodeButton.isHidden = true
        
        perform(#selector(showResendButton), with: self, afterDelay: 20)
        
        

    }
    
    
    @objc func showResendButton() {
          resendCodeButton.isHidden = false
      }
    
    
    

}
