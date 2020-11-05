//
//  NL_AccountSettings.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/26/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FlagPhoneNumber
import FirebaseStorage


class NL_AccountSettings: UIViewController {
    
//    variables
    var currentEmail = String()
    var currentName = String()
    var updateNameField = UITextField()
    var updateEmailField = UITextField()
    var primaryPhoneNumber = FPNTextField()
    var secondaryPhoneNumber = FPNTextField()
    var personImageView = UIImageView()
    var lblEditBtn = UIButton()
    
    
    var imagePicker: ImagePicker!
    
    
    //    get the top distance of the page
      /// Get distance from top, based on status bar and navigation
      public var topDistance : CGFloat{
           get{
               if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                   return 0
               }else{
                  let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
                  let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                  return barHeight + statusBarHeight
               }
           }
      }
    

    override func viewDidLoad() {
        super.viewDidLoad()
                
        
        view.addSubview(inputTopView)
        // Set its constraint to display it on screen
        inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: topDistance).isActive = true
        inputTopView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        inputTopView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

 
//        get the current users details and populate the page
        getCurrentDetails()
        
//        set the delegate of the image picker, allowing the current page to show the image picker
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
//        setup the page
            setupThePage()

        
    }
    
    func setupThePage(){
        
        self.title = "Account Settings"
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = MyVariables.colourPlanrGreen
        navigationItem.backBarButtonItem = backItem
        
//        add save button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem?.tintColor = MyVariables.colourPlanrGreen
        
        let userImage = fetchImage(uid: user!)
        if userImage.count != 0{
            print("userImage.count \(userImage.count)")
            let image = userImage[0]
            personImageView.image = UIImage(data: image.userImage!)
        }
    }
    
    @objc func saveTapped(){
        var phoneNumbersToUpdate = [String]()
        //            utils for calling the alert
        let utils = Utils();
                
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
                    
//                    show a notification to let the user know we are updating the database
                    let alertPayload = AlertPayload(title: "Updating!", titleColor: UIColor.red, message: "We are updating your information.", messageColor: MyVariables.colourPlanrGreen, buttons: [], backgroundColor: UIColor.clear)
                    
                    utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: true, timeLag: 2.0)
                    
                    
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
                                              }}}
                
        //        updates the user default 'name'
                UserDefaults.standard.set(updateNameField.text!, forKey: "name")
                
                print("users user default name updated")
//                    check if the user upload a photo and add it to the database is they did
  
                    if personImageView.image != nil{
                        // Get a reference to the storage service using the default Firebase App
                        let storage = Storage.storage()

                        // Create a storage reference from our storage service
                        let storageRef = storage.reference()
                        
                        // Create a child reference
                        // imagesRef now points to "images"
                        let imagesRef = storageRef.child("profileImages")
                        
//                        the image chosen by the user
                        let image = personImageView.image
                        
//                        we resize the image down to 200 by 100 pxls to save space
                        let resizedImage = resizeImage(image: image!, newWidth: 200)
                        
//                        we have to convert the image to png in order to save it
                        let resizeImagePNG = resizedImage!.pngData()
                        
//                        check if the user is authenticated, if not we do nothing further
                        if user != nil{
                        let userImageRef = imagesRef.child(user!)
                            
                            let uploadTask = userImageRef.putData(resizeImagePNG!, metadata: nil) { (metadata, error) in
                              guard let metadata = metadata else {
                                // Uh-oh, an error occurred!
                                return
                              }
                                print("users new photo uploaded")
                                
//                                delete the photo that was previously saved
                                DataBaseHelper.shareInstance.deleteImage(userID: user!)
                                
//                                we add the users image to their data store
                                DataBaseHelper.shareInstance.saveImage(image: resizedImage!, userID: user!)
                                
//                                post notification to reload user photo
                                NotificationCenter.default.post(name: .userPhotoUploaded, object: nil)

                            }
                            
                        }
                    }
         
            }
            }
    
    
    
    //    create the views for the page
               lazy var inputTopView: UIView = {
                   print("setting up the inputTopView")
           //        set the variables for the setup
            let imageBubbleSize = CGFloat(100)
            let titleHeight = CGFloat(30)
            let inputHeight = CGFloat(50)
            let sideInset = CGFloat(16)
            let separatorHeight = CGFloat(1)
            let spacer = CGFloat(5)
                
                   //   setup the view for holding the progress bar and title
                   let containerView = UIView()
                   containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight)
                   containerView.backgroundColor = UIColor.white
                   containerView.translatesAutoresizingMaskIntoConstraints = false
                   
           //        trying to add a top view
                   let topView = UIView()
                   topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight)
                   topView.backgroundColor = UIColor.white
                   topView.translatesAutoresizingMaskIntoConstraints = false
                   containerView.addSubview(topView)
                   topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
                   topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
                   topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
                topView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
                   
//             create the image of the user
                topView.addSubview(personImageView)
                personImageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
                personImageView.backgroundColor = MyVariables.colourBackground
                //        make the imageView round
                personImageView.layer.borderWidth = 1.0
                personImageView.layer.masksToBounds = true
                
                //        create the circle
                personImageView.layer.cornerRadius = CGFloat(imageBubbleSize) / 2
                personImageView.layer.borderColor = UIColor.white.cgColor
                personImageView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
                personImageView.widthAnchor.constraint(equalToConstant: CGFloat(imageBubbleSize)).isActive = true
                personImageView.heightAnchor.constraint(equalToConstant: CGFloat(imageBubbleSize)).isActive = true
                personImageView.translatesAutoresizingMaskIntoConstraints = false
                
//                add an edit button beneath the users image
                
                topView.addSubview(lblEditBtn)
                lblEditBtn.setTitle("Edit", for: .normal)
                lblEditBtn.titleLabel?.textAlignment = .center
                lblEditBtn.setTitleColor(MyVariables.colourPlanrGreen, for: .normal)
                lblEditBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                lblEditBtn.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
                lblEditBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
                lblEditBtn.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
                lblEditBtn.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20).isActive = true
                lblEditBtn.translatesAutoresizingMaskIntoConstraints = false
                lblEditBtn.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)

                
//                add name label
                
                let lblName = UILabel()
                topView.addSubview(lblName)
                lblName.text = "Name"
                lblName.textColor = MyVariables.colourLight
                lblName.font = UIFont.systemFont(ofSize: 15)
                lblName.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
                lblName.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
                lblName.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
                lblName.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20 + titleHeight).isActive = true
                lblName.translatesAutoresizingMaskIntoConstraints = false
                
                topView.addSubview(updateNameField)
                updateNameField.font = UIFont.systemFont(ofSize: 15)
                updateNameField.textColor = .black
                updateNameField.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
                updateNameField.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
                updateNameField.heightAnchor.constraint(equalToConstant: inputHeight).isActive = true
                updateNameField.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 25 + titleHeight*2).isActive = true
                updateNameField.translatesAutoresizingMaskIntoConstraints = false
                

                //        create a separator line
                let separatorLine = UIView()
                separatorLine.backgroundColor = MyVariables.colourPlanrGreen
                separatorLine.translatesAutoresizingMaskIntoConstraints = false
                topView.addSubview(separatorLine)
                separatorLine.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
                separatorLine.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth - sideInset - sideInset)).isActive = true
                separatorLine.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20 + titleHeight*2 + inputHeight).isActive = true
                separatorLine.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
                
                let lblEmail = UILabel()
                topView.addSubview(lblEmail)
                lblEmail.text = "Email"
                lblEmail.textColor = MyVariables.colourLight
                lblEmail.font = UIFont.systemFont(ofSize: 15)
                lblEmail.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
                lblEmail.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
                lblEmail.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
                lblEmail.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20 + titleHeight*2 + inputHeight + separatorHeight + spacer).isActive = true
                lblEmail.translatesAutoresizingMaskIntoConstraints = false
                
                
                topView.addSubview(updateEmailField)
                updateEmailField.font = UIFont.systemFont(ofSize: 15)
                updateEmailField.textColor = .black
                updateEmailField.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
                updateEmailField.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
                updateEmailField.heightAnchor.constraint(equalToConstant: inputHeight).isActive = true
                updateEmailField.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20 + titleHeight*3 + inputHeight + separatorHeight + spacer).isActive = true
                updateEmailField.translatesAutoresizingMaskIntoConstraints = false
                
                //        create a separator line
                let separatorLine2 = UIView()
                separatorLine2.backgroundColor = MyVariables.colourPlanrGreen
                separatorLine2.translatesAutoresizingMaskIntoConstraints = false
                topView.addSubview(separatorLine2)
                separatorLine2.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
                separatorLine2.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth - sideInset - sideInset)).isActive = true
                separatorLine2.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20 + titleHeight*3 + inputHeight*2 + separatorHeight + spacer).isActive = true
                separatorLine2.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
                
//                primary phone number title
                let lblPrimaryPN = UILabel()
                topView.addSubview(lblPrimaryPN)
                lblPrimaryPN.text = "Primary Phone Number"
                lblPrimaryPN.textColor = MyVariables.colourLight
                lblPrimaryPN.font = UIFont.systemFont(ofSize: 15)
                lblPrimaryPN.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
                lblPrimaryPN.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
                lblPrimaryPN.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
                lblPrimaryPN.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20 + titleHeight*3 + inputHeight*2 + separatorHeight*2 + spacer*2).isActive = true
                lblPrimaryPN.translatesAutoresizingMaskIntoConstraints = false
                
                
//                add the primary phone number
                topView.addSubview(primaryPhoneNumber)
//        code for the setup of the country picker
                primaryPhoneNumber.borderStyle = .none
//                set the view as the delegate
                primaryPhoneNumber.delegate = self
                primaryPhoneNumber.font = UIFont.systemFont(ofSize: 15)
                // Custom the size/edgeInsets of the flag button
                primaryPhoneNumber.flagButtonSize = CGSize(width: 35, height: 35)
                primaryPhoneNumber.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
                primaryPhoneNumber.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
                primaryPhoneNumber.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
                primaryPhoneNumber.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20 + titleHeight*4 + inputHeight*2 + separatorHeight*2 + spacer*2).isActive = true
                primaryPhoneNumber.translatesAutoresizingMaskIntoConstraints = false
                
                
                //        create a separator line
                let separatorLine3 = UIView()
                separatorLine3.backgroundColor = MyVariables.colourPlanrGreen
                separatorLine3.translatesAutoresizingMaskIntoConstraints = false
                topView.addSubview(separatorLine3)
                separatorLine3.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
                separatorLine3.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth - sideInset - sideInset)).isActive = true
                separatorLine3.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20 + titleHeight*5 + inputHeight*2 + separatorHeight*2 + spacer*3).isActive = true
                separatorLine3.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
                
                
  //                secondary phone number title
                let lblSecondaryPN = UILabel()
                topView.addSubview(lblSecondaryPN)
                lblSecondaryPN.text = "Secondary Phone Number"
                lblSecondaryPN.textColor = MyVariables.colourLight
                lblSecondaryPN.font = UIFont.systemFont(ofSize: 15)
                lblSecondaryPN.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
                lblSecondaryPN.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
                lblSecondaryPN.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
                lblSecondaryPN.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20 + titleHeight*5 + inputHeight*2 + separatorHeight*3 + spacer*4).isActive = true
                lblSecondaryPN.translatesAutoresizingMaskIntoConstraints = false
                
                
                //                add the secondary phone number
                topView.addSubview(secondaryPhoneNumber)
                //        code for the setup of the country picker
                secondaryPhoneNumber.borderStyle = .none
                //                set the view as the delegate
                secondaryPhoneNumber.delegate = self
                secondaryPhoneNumber.font = UIFont.systemFont(ofSize: 15)
                                // Custom the size/edgeInsets of the flag button
                secondaryPhoneNumber.flagButtonSize = CGSize(width: 35, height: 35)
                secondaryPhoneNumber.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: sideInset).isActive = true
                secondaryPhoneNumber.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
                secondaryPhoneNumber.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
                secondaryPhoneNumber.topAnchor.constraint(equalTo: topView.topAnchor, constant: imageBubbleSize + 20 + titleHeight*6 + inputHeight*2 + separatorHeight*3 + spacer*4).isActive = true
                secondaryPhoneNumber.translatesAutoresizingMaskIntoConstraints = false
                
                
                   return containerView
               }()
    
    
    @objc func showImagePicker(){
        print("user selected to see image picker")
        self.imagePicker.present(from: personImageView)
    }
    

    //    function to pull down the current email and name of the user
        func getCurrentDetails(){
            
            print("Getting current user settings")
            if user == nil{
             print("user ID isnt available")
    //        send the user back to the home screen
            let sampleStoryBoard : UIStoryboard = UIStoryboard(name: "NL_HomePage", bundle:nil)
            let homeView  = sampleStoryBoard.instantiateViewController(withIdentifier: "NL_HomePage") as! NL_HomePage
            self.navigationController?.pushViewController(homeView, animated: true)
                
                showProgressHUD(notificationMessage: "We are having an issue contacting the server, please try again later", imageName: "Refresh-100", delay: 1.0)
                
            }
            else{
                dbStore.collection("users").whereField("uid", isEqualTo: user).getDocuments { (querySnapshot, error) in
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
                    }}}}}

}

extension NL_AccountSettings: FPNTextFieldDelegate {
    
    /// The place to present/push the listController if you choosen displayMode = .list
    func fpnDisplayCountryList() {
//       let navigationViewController = UINavigationController(rootViewController: listController)
//
//       present(navigationViewController, animated: true, completion: nil)
    }

    /// Lets you know when a country is selected
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
       print(name, dialCode, code) // Output "France", "+33", "FR"
    }

    /// Lets you know when the phone number is valid or not. Once a phone number is valid, you can get it in severals formats (E164, International, National, RFC3966)
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "greenTickCode") : #imageLiteral(resourceName: "Unavailable"))
        textField.rightView?.widthAnchor.constraint(equalToConstant: 17).isActive = true
        textField.rightView?.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        print(
            isValid,
            textField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil",
            textField.getFormattedPhoneNumber(format: .International) ?? "International: nil",
            textField.getFormattedPhoneNumber(format: .National) ?? "National: nil",
            textField.getFormattedPhoneNumber(format: .RFC3966) ?? "RFC3966: nil",
            textField.getRawPhoneNumber() ?? "Raw: nil"
        )
    }
    

}

extension NL_AccountSettings: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.personImageView.image = image
    }
}

