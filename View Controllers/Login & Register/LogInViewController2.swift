//
//  LogInViewController2.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 24/10/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FlagPhoneNumber
import MBProgressHUD


var loginPhoneNumber = String()

class LogInViewController2: UIViewController {
    
    
    @IBOutlet weak var phoneNumberTextField: FPNTextField!
    

    
    @IBOutlet weak var getActivationCodeButton: UIButton!
    
    
    @IBAction func getActivationCodePressed(_ sender: UIButton) {
        
        
        let phoneNumber1 = phoneNumberTextField.getFormattedPhoneNumber(format: .E164)
 
        if phoneNumberTextField.text == ""{
            
            print(phoneNumberTextField.text ?? "")
            
            showProgressHUD(notificationMessage: "Please enter your phone number", imageName: "Unavailable", delay: 1)

        }
        else if phoneNumber1?.contains("null") == true{
          
            print(phoneNumberTextField.text ?? "")
            
            showProgressHUD(notificationMessage: "Please enter a valid phone number", imageName: "Unavailable", delay: 1)
        }
        
        else{
            
               self.performSegue(withIdentifier: "existingUserActivationSegue", sender: self)
            
            
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
        
        phoneNumberTextField.delegate = self
        
        //        code for the setup of the country picker
                phoneNumberTextField.borderStyle = .roundedRect
                
                // Comment this line to not have access to the country list
                phoneNumberTextField.parentViewController = self
//                phoneNumberTextField.delegate = self
                
                phoneNumberTextField.font = UIFont.systemFont(ofSize: 14)
                
                
                // Custom the size/edgeInsets of the flag button
                phoneNumberTextField.flagButtonSize = CGSize(width: 35, height: 35)
        //        phoneNumberTextField.flagbutton = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                // The placeholder is an example phone number of the selected country by default. You can add your own placeholder :
                phoneNumberTextField.hasPhoneNumberExample = true
                view.addSubview(phoneNumberTextField)
        
        
        
            buttonSettings(uiButton: getActivationCodeButton)
        
        
    }
    
    
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if(segue.identifier == "existingUserActivationSegue"){
              

              let phoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil"
            
            loginPhoneNumber = phoneNumber
              PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                  if let error = error {
                      print(error)
                      return
                  }
                  UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
              }
              
  
          }
      }
    
    

}

extension LogInViewController2: FPNTextFieldDelegate {
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "Available") : #imageLiteral(resourceName: "Unavailable"))
        
        print(
            isValid,
            textField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil",
            textField.getFormattedPhoneNumber(format: .International) ?? "International: nil",
            textField.getFormattedPhoneNumber(format: .National) ?? "National: nil",
            textField.getFormattedPhoneNumber(format: .RFC3966) ?? "RFC3966: nil",
            textField.getRawPhoneNumber() ?? "Raw: nil"
        )
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
    
}

