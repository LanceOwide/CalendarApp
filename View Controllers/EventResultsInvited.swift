//
//  CreateEventViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 24/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit


var myArray = [[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]]
var vc = ViewController()
var eventIDChosen = ""


class EventResultsInvited: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var arrayForEventResultsPage = [[Any]]()
    

    

    
    @IBOutlet weak var gridCollectionView: UICollectionView! {
        didSet {
            
            //            not sure what this setting does
            gridCollectionView.bounces = true
            
        }
    }
    
    //    sets the number of columns and rows that do not move with the table
    @IBOutlet weak var gridLayout: StickyGridCollectionViewLayout! {
        didSet {
            gridLayout.stickyRowsCount = 2
            gridLayout.stickyColumnsCount = 1
        }
    }
    
    
    
    
    // MARK: - Collection view data source and delegate methods
    
    
    //    number of rows
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let rows = anyArray.count
        print(anyArray)
        print(rows)
        return rows
    }
    
    //    number of columns
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let columns = anyArray
        let columnsCount = (columns[0] as AnyObject).count! - 1
        
        print(columnsCount)
        
        return columnsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseID, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if type(of: anyArray[indexPath.section][indexPath.row]) == Int.self {
            if anyArray[indexPath.section][indexPath.row] as! Int == 10{
                
                cell.titleLabel.text = "?"
                cell.backgroundColor = UIColor.lightGray
                
            }
            if anyArray[indexPath.section][indexPath.row] as! Int == 1{
                
                cell.titleLabel.text = "OK"
                cell.backgroundColor = UIColor.green
                
            }
            if anyArray[indexPath.section][indexPath.row] as! Int == 0{
                
                cell.titleLabel.text = "NO"
                cell.backgroundColor = UIColor.red
                
            }
        }
        else{
            
            cell.backgroundColor = UIColor.white
            cell.titleLabel.text = "\(anyArray[indexPath.section][indexPath.row])"}
        cell.titleLabel.font = UIFont(name: "Helvetica Neue", size: 10)
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //        on selecting the second section of the collectionview the corresponding event gets created
        let eventDetailArray =  UserDefaults.standard.array(forKey: "eventResultsArrayDetails") as? [[Any]]
        let array = UserDefaults.standard.array(forKey: "eventResultsArray") as? [[Any]]
        
        if indexPath.section == 1 {
            print(array![1][indexPath.row])
            
            if array?[1][indexPath.row] as? String ?? "" == "Select Date" {
                
                //            Adds the chosen date to the event in the eventRequsts table
                dbStore.collection("eventRequests").document(eventDetailArray![3][indexPath.row] as! String).setData(["chosenDate" : eventDetailArray![0][indexPath.row]], merge: true)
                
                //            Adds the chosen date to each individuals user event store
                dbStore.collection("userEventStore").whereField("eventID", isEqualTo: eventDetailArray![3][indexPath.row] as! String).getDocuments { (querySnapshot, error) in
                    if error != nil {
                        print("Error getting documents: \(error!)")
                    }
                    else {
                        
                        for document in querySnapshot!.documents {
                            //                    print("\(document.documentID) => \(document.data())")
                            
                            var documentIdentifier : String
                            
                            documentIdentifier = document.documentID
                            
                            dbStore.collection("userEventStore").document(documentIdentifier).setData(["chosenDate" : eventDetailArray![0][indexPath.row]], merge: true)
                            
                            
                            
                        }}}
                
                print(eventDetailArray![0][indexPath.row])
                print(eventDetailArray![3][indexPath.row])
                
                performSegue(withIdentifier: "eventCreated", sender: self)
                
                
            }
            
            
            
            
            
        }
        else {
            
        }
        
        
    }
    
    //    MARK: Functions for deleting a crated event
    func deleteEventRequest(eventID: String){
        let docRefEventRequest = dbStore.collection("eventRequests")
        
        docRefEventRequest.document(eventID).delete()
    }
    
    func deleteEventStore(eventID: String){
        
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    let documentID = document.documentID
                    
                    docRefUserEventStore.document(documentID).delete()
                }
            }
        }
        
        
    }
    
}

