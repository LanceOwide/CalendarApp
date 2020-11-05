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
        
//        we need to check if the verificationID was not returned then we should show an error message
        if verificationID == nil{
//            if there was no verification message, we show a message and send the user back to the homePage
            
            loadingNotification.hide(animated: true)
            
//            initialise utils
            let utils = Utils()
//            we only show an OK button
            let button = AlertButton(title: "OK", action: {
                print("OK clicked")
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
                    if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }}
            }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected)
                
            let alertPayload = AlertPayload(title: "Login Issue!", titleColor: UIColor.red, message: "We are having issues logging you in. Please ensure, you have entered the correct text code, your phone number is correct and that you have signal, then pease try again. If this continues, please contact issues@planr.me", messageColor: MyVariables.colourPlanrGreen, buttons: [button], backgroundColor: UIColor.clear)
                
            utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0)
                        
        }
        else{
        
        let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID!,
                verificationCode: textCodeInput.text!)
        
               Auth.auth().signIn(with: credential) { (authResult, error) in
                       if error != nil {
                        let authError = error! as NSError
                        
                           print("there was an error logging in \(authError)")
                        
                        loadingNotification.hide(animated: true)
                        
                        self.showProgressHUD(notificationMessage: "Verification code did not match, please retry", imageName: "Unavailable", delay: 2)
                        
                           return
                       }
                       else{
                        print("Logging in with authResult \(authResult.debugDescription) user credentials - \(String(describing: authResult?.credential))")
                        
                        user = Auth.auth().currentUser?.uid
                        print("user - \(String(describing: user))")
                        
                        existingUserLoggedIn = true
                        
                        loadingNotification.hide(animated: true)
                        
                        UserDefaults.standard.set(loginPhoneNumber, forKey: "userPhoneNumber")
                        
//                        instantiate the home page
                        if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_HomePage") as? NL_HomePage {
                            if let navigator = self.navigationController {
                                print("user logged in, pushing them to the hom page")
                            navigator.pushViewController(viewController, animated: true)
                        }}
        }}}
    }

    
    
    @IBAction func resendButtonPressed(_ sender: UIButton) {
    
    PhoneAuthProvider.provider().verifyPhoneNumber(loginPhoneNumber, uiDelegate: nil) { (verificationID, error) in
        if let error = error {
            print(error)
            
            self.loginNotWorking()
            
            return
        }
        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
    }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        view.backgroundColor = .white
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: MyVariables.colourPlanrGreen)
        

        
        buttonSettings(uiButton: loginButtonOldUserSettings)
        buttonSettings(uiButton: resendCodeButton)
        
        
        resendCodeButton.isHidden = true
        
        perform(#selector(showResendButton), with: self, afterDelay: 20)
        
        

    }
    
    
    @objc func showResendButton() {
          resendCodeButton.isHidden = false
      }
    
    
    

}
