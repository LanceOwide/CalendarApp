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

class eventImageHelper {
static let shareInstance = DataBaseHelper()
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveImage(image: UIImage, userID: String) {
        let imageInstance = CoreDataEventImage(context: context)
        imageInstance.eventImage = image.pngData()
        imageInstance.eventID = userID
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
    
}
