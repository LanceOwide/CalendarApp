//
//  AccountSettings.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 29/07/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FlagPhoneNumber
import MBProgressHUD


class AccountSettings: UIViewController {
    
    var currentEmail = String()
    var currentName = String()

    @IBOutlet weak var updateNameField: UITextField!
    
    @IBOutlet weak var updateEmailField: UITextField!
    
    
    @IBOutlet weak var primaryPhoneNumber: FPNTextField!
    
    @IBOutlet weak var secondaryPhoneNumber: FPNTextField!
    

    @IBAction func saveUserInformationButton(_ sender: Any) {
        
        updateUserInformation()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Account Settings"
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        getCurrentDetails()
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        
        
        //        code for the setup of the country picker
                primaryPhoneNumber.borderStyle = .roundedRect
                
                // Comment this line to not have access to the country list
                primaryPhoneNumber.parentViewController = self
                primaryPhoneNumber.delegate = self
                
                primaryPhoneNumber.font = UIFont.systemFont(ofSize: 14)
                
                
                // Custom the size/edgeInsets of the flag button
                primaryPhoneNumber.flagButtonSize = CGSize(width: 35, height: 35)
        //        phoneNumberTextField.flagbutton = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                // The placeholder is an example phone number of the selected country by default. You can add your own placeholder :
                primaryPhoneNumber.hasPhoneNumberExample = true
                view.addSubview(primaryPhoneNumber)
        
        
        //        code for the setup of the country picker
                secondaryPhoneNumber.borderStyle = .roundedRect
                
                // Comment this line to not have access to the country list
                secondaryPhoneNumber.parentViewController = self
                secondaryPhoneNumber.delegate = self
                
                secondaryPhoneNumber.font = UIFont.systemFont(ofSize: 14)
                
                
                // Custom the size/edgeInsets of the flag button
                secondaryPhoneNumber.flagButtonSize = CGSize(width: 35, height: 35)
        //        phoneNumberTextField.flagbutton = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                // The placeholder is an example phone number of the selected country by default. You can add your own placeholder :
                secondaryPhoneNumber.hasPhoneNumberExample = true
                view.addSubview(secondaryPhoneNumber)
    
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
//    function to pull down the current email and name of the user
    func getCurrentDetails(){
        
        print("Getting current user settings")
        print("user: \(user!)")
        
        dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
                    
                    self.currentName = (document.get("name") as? String)!
                    print("currentName \(self.currentName)")
                    self.currentEmail = (document.get("email") as? String)!
                    
                    let phoneNumbers = document.get("phoneNumbers") as! [String]
                    
                    
                    print("currentEmail \(self.currentEmail)")
                    print("currentPhoneNumber \(phoneNumbers)")
                    
                    self.updateEmailField.text = self.currentEmail
                    self.updateNameField.text = self.currentName
                    
                    self.primaryPhoneNumber.set(phoneNumber: phoneNumbers[0])
                                       
                    if phoneNumbers.count == 1 {
                        
                        self.secondaryPhoneNumber.text = ""
                        
                    }
                    else{
                        
                        self.secondaryPhoneNumber.set(phoneNumber: phoneNumbers[1])
                
                    }
                    

    
                }}}}
    
//    function udpates the user information in the users table and n the eventRequest table
    func updateUserInformation(){
        
        var phoneNumbersToUpdate = [String]()
        
        phoneNumbersToUpdate.removeAll()
        
        let phoneNumber1 = primaryPhoneNumber.getFormattedPhoneNumber(format: .E164)
        let phoneNumber2 = secondaryPhoneNumber.getFormattedPhoneNumber(format: .E164)
        
        
        
        if primaryPhoneNumber.text == "" {
            
            showProgressHUD(notificationMessage: "Phone number 1 must be populated", imageName: "Unavailable", delay: 1)
        }
            
        else if phoneNumber1?.contains("null") == true {
          
            
            showProgressHUD(notificationMessage: "Please check phone number 1 is valid", imageName: "Unavailable", delay: 1)
            
        }
        else if secondaryPhoneNumber.text != "" && phoneNumber2?.contains("null") == true{
            
           showProgressHUD(notificationMessage: "Please check phone number 2 is valid", imageName: "Unavailable", delay: 1)
            
        }
  
        else{
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Updating Settings"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
            loadingNotification.mode = MBProgressHUDMode.customView
        
        

        dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
                    
                    
                  let documentID = document.documentID
                    
                    
                    
                    
                    if self.secondaryPhoneNumber.text == ""{
                         phoneNumbersToUpdate.append(self.primaryPhoneNumber.getFormattedPhoneNumber(format: .E164) ?? "")
                        
                    }
                    else{
                        
                        phoneNumbersToUpdate.append(self.primaryPhoneNumber.getFormattedPhoneNumber(format: .E164) ?? "")
                        
                        phoneNumbersToUpdate.append(self.secondaryPhoneNumber.getFormattedPhoneNumber(format: .E164) ?? "")
                        
                    }
                    
                    
                    dbStore.collection("users").document(documentID).setData(["name" : self.updateNameField.text!], merge: true)
                    
                    dbStore.collection("users").document(documentID).setData(["email" : self.updateEmailField.text!], merge: true)
                    
                    dbStore.collection("users").document(documentID).setData(["phoneNumbers" : phoneNumbersToUpdate], merge: true)
                    
                    print("users name and email updated")
                    
                    loadingNotification.hide(animated: true)
                    
                    
                    self.showProgressHUD(notificationMessage: "Settings updated", imageName: "icons8-double-tick-100", delay: 2)
                    
                    
                }}}
        
//        updates the user default 'name'
        UserDefaults.standard.set(updateNameField.text!, forKey: "name")
        
        print("users user default name updated")
 
    }
    }
    
    

}

extension AccountSettings: FPNTextFieldDelegate {
    
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
