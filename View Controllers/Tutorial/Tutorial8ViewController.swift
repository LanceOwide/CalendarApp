//
//  TutorialImageViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 11/2/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

//Analytics.logEvent("share_image", parameters: [
//  "name": name as NSObject,
//  "full_text": text as NSObject
//  ])



class Tutorial8ViewController: UIViewController {
    
    var imagePicker: ImagePicker!
    
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


@IBOutlet weak var uiView: UIView!
    
@IBOutlet weak var imgView: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiView.backgroundColor = .clear

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

//        set the delegate of the image picker, allowing the current page to show the image picker
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)

        
//        setup the image view
        let inviteImage = imageWith(name: "Upload your profile picture", width: 300, height: 300, fontSize: 30, textColor: MyVariables.colourPlanrGreen)
        imgView.image = inviteImage
        imgView.layer.cornerRadius = CGFloat(50)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(tapGesture)

        
//        set view constraints
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
            let verticalConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0 + 15)
        
            let widthConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenWidth - screenWidth/4)
        
            let heightConstraint = NSLayoutConstraint(item: uiView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenHeight - topDistance - 100)
        
            view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
    }
    
    
    
   @objc func imageTapped() {
        // if the tapped view is a UIImageView then set it to imageview
    print("image tapped")
    
    self.imagePicker.present(from: imgView)
    
//    show the user a photo to upload
        }
}


extension Tutorial8ViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        if image == nil{
            let inviteImage = imageWith(name: "Upload your profile picture", width: 300, height: 300, fontSize: 30, textColor: MyVariables.colourPlanrGreen)
            imgView.image = inviteImage
        }
        else{
        self.imgView.image = image
        
            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()

            // Create a storage reference from our storage service
            let storageRef = storage.reference()
            
            // Create a child reference
            // imagesRef now points to "images"
            let imagesRef = storageRef.child("profileImages")
            
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
                    
                }
                
            }
            
            
        }
    }
}


