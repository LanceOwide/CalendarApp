//
//  NL_useCoreDataStore.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 9/29/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataBaseHelper {
static let shareInstance = DataBaseHelper()
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveImage(image: UIImage, userID: String) {
        let imageInstance = CoreDataUser(context: context)
        imageInstance.userImage = image.pngData()
        imageInstance.uid = userID
do {
try context.save()
print("Image is saved")
} catch {
print(error.localizedDescription)
      }
   }
    
    func deleteImage(userID: String){
        
        print("running func deleteImage")
    
//        variable to hold the filtered request
        let request : NSFetchRequest<CoreDataUser> = CoreDataUser.fetchRequest()
//        variable to hold all users
        var allUsers = [CoreDataUser]()
        
//      get all the users from the database
        do{
            allUsers = try context.fetch(request)
            print("deleteImage - allUsers - event count: \(allUsers.count)")
        } catch{
            print("deleteImage - error fetching the data from core data \(error)")
        }
        
//        find how many instance are saved of the user details
        let filter = allUsers.filter {$0.uid == user!}
        let filterCount = filter.count
        print("delete filterCount \(filterCount)")
        
//        loop through each item for this user and delete each reference
        for i in filter{
        
//        find the iundex of the users
        if let index = allUsers.index(where: {$0.uid == userID}){
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
