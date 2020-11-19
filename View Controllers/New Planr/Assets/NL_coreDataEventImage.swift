//
//  NL_coreDataEventImage.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 11/18/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

class eventImageHelper {
static let shareInstance = eventImageHelper()
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveImage(image: UIImage, eventID: String) {
        let imageInstance = CoreDataEventImage(context: context)
        imageInstance.eventImage = image.pngData()
        imageInstance.eventID = eventID
do {
try context.save()
print("Image is saved")
} catch {
print(error.localizedDescription)
      }
   }
    
    func deleteImage(eventID: String){
        
        print("running func deleteImage")
    
//        variable to hold the filtered request
        let request : NSFetchRequest<CoreDataEventImage> = CoreDataEventImage.fetchRequest()
//        variable to hold all users
        var allUsers = [CoreDataEventImage]()
        
//      get all the users from the database
        do{
            allUsers = try context.fetch(request)
            print("deleteImage - allUsers - event count: \(allUsers.count)")
        } catch{
            print("deleteImage - error fetching the data from core data \(error)")
        }
        
//        find how many instance are saved of the user details
        let filter = allUsers.filter {$0.eventID == eventID}
        let filterCount = filter.count
        print("delete filterCount \(filterCount)")
        
//        loop through each item for this user and delete each reference
        for i in filter{
        
//        find the iundex of the users
        if let index = allUsers.index(where: {$0.eventID == eventID}){
            context.delete(allUsers[index])
            allUsers.remove(at: index)
            print("deleteImage - index: \(index)")
//            save down the  new list of users
            do {
            try context.save()
            print("deleteImage - Image is saved")
            } catch {
            print(error.localizedDescription)
                  }
        }
        }
        
    }
    
    
    func pushEventImage(image: UIImage, eventID: String){
        print("running func pushEventImage eventID \(eventID)")
        
            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()

            // Create a storage reference from our storage service
            let storageRef = storage.reference()
            
            // Create a child reference
            // imagesRef now points to "images"
            let imagesRef = storageRef.child("eventImage")
            
//                        we resize the image down to 200 by 100 pxls to save space
            let resizedImage = resizeImage(image: image, newWidth: 200)
            
//                        we have to convert the image to png in order to save it
            let resizeImagePNG = resizedImage!.pngData()
            
//                        check if the user is authenticated, if not we do nothing further
            if user != nil{
            let userImageRef = imagesRef.child(eventID)
                
                let uploadTask = userImageRef.putData(resizeImagePNG!, metadata: nil) { (metadata, error) in
                    if let metadata = metadata{
                        print("pushEventImage - event image pushed")
                        
                        AutoRespondHelper.postEventPicNotification(eventID: eventID)
                        
//                                delete the photo that was previously saved
                        eventImageHelper.shareInstance.deleteImage(eventID: eventID)
                                            
//                                we add the users image to their data store
                        eventImageHelper.shareInstance.saveImage(image: resizedImage!, eventID: eventID)
                        
                        NotificationCenter.default.post(name: .newDataLoaded, object: nil)
                        
                    } else {
                    // Uh-oh, an error occurred!
                    return
                  }
                    
    }
    }
    }
                
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
}
