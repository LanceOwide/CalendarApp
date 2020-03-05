//
//  PhoneNumberCode.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/07/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class PhoneNumberCode: UIViewController {
    
    var myAddedUserID = ""
    var ref: DocumentReference? = nil
    
    @IBOutlet weak var textCodeInput: UITextField!

    
    
    @IBOutlet weak var btnCompleteSettings: UIButton!
    
    
    
    @IBOutlet weak var resendButton: UIButton!
    
    
    
    @IBAction func resendButtonPressed(_ sender: UIButton) {
        
        
        PhoneAuthProvider.provider().verifyPhoneNumber(registeredPhoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
        
        
        
    }
    
 
    @IBAction func btnCompletePressed(_ sender: UIButton) {


        print(registeredPhoneNumber)
        print(registeredEmail)
        print(registeredName)

        if textCodeInput.text != "" {
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Loading"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
            loadingNotification.mode = MBProgressHUDMode.customView
            

        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")

        print(verificationID!)

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
                
                existingUserLoggedIn = false

            let uid = Auth.auth().currentUser?.uid
                
            user = Auth.auth().currentUser?.uid

            let dbStore = Firestore.firestore()
                
                self.getUserPushTokenGlobal()
                
//            check if the users phonenumber already exists in our database
                
                dbStore.collection("users").whereField("phoneNumber", isEqualTo: Auth.auth().currentUser?.phoneNumber! as Any).getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("Error getting documents: \(error!)")
                }
                else {
                    if querySnapshot!.isEmpty {
                        
                        
                        print("user not in the DB")
                        
                        //        LO: this says what we are going to be saving down to the DB
                                    let userDictionary = ["phoneNumber": Auth.auth().currentUser?.phoneNumber! as Any,"name": registeredName, "email": registeredEmail, "uid": uid as Any, "phoneNumbers": registeredPhoneNumbers] as [String : Any]

                        //            Add the information to the database
                                    self.ref = dbStore.collection("users").addDocument(data: userDictionary as [String : Any])

                                    print("registeredPhoneNumbers.count: \(registeredPhoneNumbers.count)")

                                    if registeredPhoneNumbers.count == 1{

                                        print("1 registered number")

                                        self.checkForPhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0]) {
                                            print("Temporary invited added to database 1 number")
                                            self.deletePhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0])
                                        }
                                    }
                                    else{

                                        self.checkForPhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0]) {
                                            print("Temporary invited added to database 2 numbers - number 1")
                                            self.deletePhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0])
                                        }

                                        self.checkForPhoneNumberInvited(phoneNumber: registeredPhoneNumbers[1]) {
                                            print("Temporary invited added to database 2 numbers - number 2")
                                            self.deletePhoneNumberInvited(phoneNumber: registeredPhoneNumbers[1])
                                        }

                                    }
                                    print("signed in")
                                    print("Segue to homepage")
                                        
                                    loadingNotification.hide(animated: true)

                                    // User is signed in
                                    // ...

                        //                self.performSegue(withIdentifier: "userRegistered2", sender: self)
                        
                    }
                    else{
                        print("user already in the DB")
                        
                     loadingNotification.hide(animated: true)
                        
                    }
                    
                    }}

            }

            }

        }

        else{

//        pop-up to let the user know they need to input the text code

            showProgressHUD(notificationMessage: "Please enter the text code", imageName: "Unavailable", delay: 1)

        }
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        

        
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait

        view.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        
        //        setup next button
        
        buttonSettings(uiButton: btnCompleteSettings)
        buttonSettings(uiButton: resendButton)
        
        resendButton.isHidden = true
        
        
        perform(#selector(showResendButton), with: self, afterDelay: 20)
        
        textCodeInput.alpha = 0.9
        
        
    }
    
    
    @objc func showResendButton() {
        resendButton.isHidden = false
    }
    

    
}
