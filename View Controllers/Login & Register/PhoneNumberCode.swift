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

var userJustRegistered  = false

class PhoneNumberCode: UIViewController {
    
    var myAddedUserID = ""
    var ref: DocumentReference? = nil
    
    @IBOutlet weak var textCodeInput: UITextField!

    
    
    @IBOutlet weak var btnCompleteSettings: UIButton!
    
    
    @IBOutlet weak var txtTermsOfService: UITextView!
    
    @IBOutlet weak var resendButton: UIButton!
    
    
    
    @IBAction func resendButtonPressed(_ sender: UIButton) {
        
        
        PhoneAuthProvider.provider().verifyPhoneNumber(registeredPhoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error)
                
                self.handleError(error)
                
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
            loadingNotification.label.text = "Logging you in"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
            loadingNotification.mode = MBProgressHUDMode.customView
            

        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")

        print(verificationID!)
            
        userJustRegistered = true

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: textCodeInput.text!)

        Auth.auth().signIn(with: credential) { (authResult, error) in
            if error != nil {
                print(error!)
                
                print(error!._code)
                
                loadingNotification.hide(animated: true)

//                show the user the error message
                self.handleError(error!)
                
                return

            }
            else{
                
                existingUserLoggedIn = false

            let uid = Auth.auth().currentUser?.uid
                user = uid
                

            let dbStore = Firestore.firestore()
                
                self.getUserPushTokenGlobal()
                
//            check if the users phonenumber already exists in our database
                dbStore.collection("users").whereField("phoneNumber", isEqualTo: Auth.auth().currentUser?.phoneNumber! as Any).getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("Error getting documents: \(error!)")
                }
                else {
                    if querySnapshot!.isEmpty {
//                        use this global variable to stop the immediate check of whether the user is the database
                        userJustRegistered = true
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
                                            self.deletePhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0]){
                                                self.checkForPhoneNumberInvitedArray(phoneNumber: registeredPhoneNumbers[0]){
                                                    self.deletePhoneNumberInvitedArray(phoneNumber: registeredPhoneNumbers[0]){
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else{

                                        self.checkForPhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0]) {
                                            print("Temporary invited added to database 2 numbers - number 1")
                                            self.deletePhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0]){
                                                
                                            }
                                        }

                                        self.checkForPhoneNumberInvited(phoneNumber: registeredPhoneNumbers[1]) {
                                            print("Temporary invited added to database 2 numbers - number 2")
                                            self.deletePhoneNumberInvited(phoneNumber: registeredPhoneNumbers[1]){
                                                
                                            }
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
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: MyVariables.colourPlanrGreen)
        
        
//        setup the terms of service link
        
        setupTermsOfService(UITextView: txtTermsOfService)
        
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait

        view.backgroundColor = .white
        
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
    
    
    func setupTermsOfService(UITextView: UITextView){

      //        eventListenerEngaged = false
      //        availabilityListenerEngaged = false
       let string = "By registering you agree to our Terms of Service"
       
       let attributedLinkString = NSMutableAttributedString(string: string, attributes:[NSAttributedString.Key.link: URL(string: "https://planr.me/terms-of-service/")!])
       
       UITextView.isUserInteractionEnabled = true
       UITextView.isEditable = false
        UITextView.textColor = UIColor.white
        
        UITextView.backgroundColor = .white
        UITextView.linkTextAttributes = [ .foregroundColor: MyVariables.colourPlanrGreen ]
       UITextView.attributedText = attributedLinkString
        
        
    }
    
}
