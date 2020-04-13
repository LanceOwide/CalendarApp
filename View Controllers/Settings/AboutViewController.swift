//
//  AboutViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 07/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    
    var aboutList = ["Privacy Policy"]
    
    var aboutDetailsList = ["View our privacy and data policy"]
    
    var segueList = ["privacyPolicySegue","",""]


    
    @IBOutlet var aboutTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    
        self.title = "About Planr"
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
//        setup tableview
        aboutTableView.delegate = self
        
        aboutTableView.dataSource = self
        aboutTableView.rowHeight = 100
        
        
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = aboutList.count
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = aboutTableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath)
        
        
        cell.textLabel?.text = aboutList[indexPath.row]
        
        cell.detailTextLabel?.text =  "View our privacy and data policy"
        
        

        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if segueList[indexPath.row] == ""{
            
            print("The select row has no segue \(indexPath.row)")
            
            aboutTableView.deselectRow(at: indexPath, animated: true)
            
        }
        else{
        
            performSegue(withIdentifier: segueList[indexPath.row], sender: Any.self)
            aboutTableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    

    
}
