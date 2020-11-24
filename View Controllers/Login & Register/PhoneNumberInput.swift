//
//  PhoneNumberInput.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/07/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FlagPhoneNumber
import MBProgressHUD


var registeredPhoneNumber = String()
var registeredPhoneNumbers = [String]()

class PhoneNumberInput: UIViewController {
    
    
    @IBOutlet weak var phoneNumberTextField: FPNTextField!
    
    
    @IBOutlet weak var additionalNumberLabel: UILabel!
    
    
    @IBOutlet weak var additionalPhoneNumberTextField: FPNTextField!
    
    
    @IBOutlet weak var getActiviationCodeSettings: UIButton!
    
    
    @IBAction func getActivationCodeButton(_ sender: Any) {
        
        let phoneNumber1 = phoneNumberTextField.getFormattedPhoneNumber(format: .E164)
        let phoneNumber2 = additionalPhoneNumberTextField.getFormattedPhoneNumber(format: .E164)
        
        if phoneNumberTextField.text == ""{
            
            showProgressHUD(notificationMessage: "Please enter your phone number", imageName: "Unavailable", delay: 1)
            
            print(phoneNumberTextField.text ?? "")
        }
        else if phoneNumber1?.contains("null") == false && additionalPhoneNumberTextField.text == ""{
          
            let segueName = "getActiviationCode"
            performSegue(withIdentifier: segueName, sender: Any?.self)
            
        }
    
        else if  phoneNumber1?.contains("null") == true || phoneNumber2?.contains("null") == true {

                       showProgressHUD(notificationMessage: "Please ensure the phone numbers are valid", imageName: "Unavailable", delay: 1)
                }
            
        else if  phoneNumberTextField.text == additionalPhoneNumberTextField.text{
            
           showProgressHUD(notificationMessage: "You've entered the same number twice", imageName: "Unavailable", delay: 1)
            
        }
        else{
            
            let segueName = "getActiviationCode"
            performSegue(withIdentifier: segueName, sender: Any?.self)
            
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: MyVariables.colourPlanrGreen)
        
        
//        we hide the secondary number because we dont want the user to add a secondary number
        additionalPhoneNumberTextField.isHidden = true
        
        view.backgroundColor = .white
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        

        //        code for the setup of the country picker
        phoneNumberTextField.borderStyle = .roundedRect
        
        // Comment this line to not have access to the country list
//        phoneNumberTextField.parentViewController = self
        phoneNumberTextField.delegate = self
        
        phoneNumberTextField.font = UIFont.systemFont(ofSize: 14)
        
        
        // Custom the size/edgeInsets of the flag button
        phoneNumberTextField.flagButtonSize = CGSize(width: 35, height: 35)
//        phoneNumberTextField.flagbutton = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        // The placeholder is an example phone number of the selected country by default. You can add your own placeholder :
        phoneNumberTextField.hasPhoneNumberExample = true
        view.addSubview(phoneNumberTextField)
        
 
        additionalPhoneNumberTextField.borderStyle = .roundedRect
                
                // Comment this line to not have access to the country list
//                additionalPhoneNumberTextField.parentViewController = self
                additionalPhoneNumberTextField.delegate = self
                
                additionalPhoneNumberTextField.font = UIFont.systemFont(ofSize: 14)
        
        additionalPhoneNumberTextField.alpha = 0.9
        phoneNumberTextField.alpha = 0.9
                
                // Custom the size/edgeInsets of the flag button
                additionalPhoneNumberTextField.flagButtonSize = CGSize(width: 35, height: 35)
        //        phoneNumberTextField.flagbutton = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                // The placeholder is an example phone number of the selected country by default. You can add your own placeholder :
                additionalPhoneNumberTextField.hasPhoneNumberExample = true
                view.addSubview(additionalPhoneNumberTextField)
        
        
        
        
        additionalNumberLabel.adjustsFontSizeToFitWidth = true
        
        
        registeredPhoneNumbers.removeAll()
        
        
        //        setup next button
        
        buttonSettings(uiButton: getActiviationCodeSettings)
        
    }

    //    gets the inputs for the contry flags
    private func getCustomTextFieldInputAccessoryView(with items: [UIBarButtonItem]) -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar()
        
        toolbar.barStyle = UIBarStyle.default
        toolbar.items = items
        toolbar.sizeToFit()
        
        return toolbar
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "getActiviationCode"){
            
            if additionalPhoneNumberTextField.text == ""{
                
            
            let phoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil"
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    print(error)
                    
//                    show the user the error message
                    self.handleError(error)
                    
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                UserDefaults.standard.set(phoneNumber, forKey: "userPhoneNumber")
            }
            
          registeredPhoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
             registeredPhoneNumbers.append(registeredPhoneNumber)
  
            }
            
            else{
                
                let phoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil"
                  PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                      if let error = error {
                          print(error)
                        
                        print("error localizedDescription")
                          return
                      }
                      UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                  }
                  
                registeredPhoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
                   registeredPhoneNumbers.append(registeredPhoneNumber)
                
                registeredPhoneNumbers.append(additionalPhoneNumberTextField.getFormattedPhoneNumber(format: .E164)!)
                
                
                
            }
            
        }
    }
    
//    if the users presesses the back button we need to reset the registered numbers
    override func viewDidAppear(_ animated: Bool) {
        registeredPhoneNumbers.removeAll()
    }
    
}

extension PhoneNumberInput: FPNTextFieldDelegate {
    
    /// The place to present/push the listController if you choosen displayMode = .list
    func fpnDisplayCountryList() {
//       let navigationViewController = UINavigationController(rootViewController: listController)
//       
//       present(navigationViewController, animated: true, completion: nil)
    }
    
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

// Firebase error messsages handler
extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use with another account"
        case .userNotFound:
            return "Account not found for the specified user. Please check and try again"
        case .userDisabled:
            return "Your account has been disabled. Please contact support."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email"
        case .networkError:
            return "Network error. Please try again."
        case .weakPassword:
            return "Your password is too weak. The password must be 6 characters long or more."
        case .wrongPassword:
            return "Your password is incorrect. Please try again or use 'Forgot password' to reset your password"
        case .invalidVerificationCode:
            return "Your verification code is incorrect. Please try again"
        case .invalidPhoneNumber:
            return "Your phone number is invalid, please press back and try again"
        default:
            return "Unknown error occurred, please go back and try again"
        }
    }
}

//  handler to show message to the user if there is an error
extension UIViewController{
    func handleError(_ error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            print(errorCode.errorMessage)
            let alert = UIAlertController(title: "Error", message: errorCode.errorMessage, preferredStyle: .alert)

            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)

            alert.addAction(okAction)

            self.present(alert, animated: true, completion: nil)

        }
    }

}
