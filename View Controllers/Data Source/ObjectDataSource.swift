//
//  ObjectDataSource.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 13/11/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

class ObjectDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var dateChosen = ""
    var dateChosenPosition = Int()
    
    
    let redColour = UIColor.init(red: 255, green: 235, blue: 230)
    let greenColour = UIColor.init(red: 191, green: 241, blue: 160)
    let yellowColour = UIColor.init(red: 250, green: 219, blue: 135)
    let orangeColour = UIColor.init(red: 250, green: 200, blue: 135)
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = datesToChooseFrom.count - 1
        
        return numberOfRows
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let appGreen = UIColor(red: 0, green: 176, blue: 156)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chooseDateCell", for: indexPath)
        
        
        cell.textLabel?.text = ("\(datesToChooseFrom[indexPath.row + 1] as! String) (Availability: \(availabilitySummaryArray[0][indexPath.row + 1]))")
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.clipsToBounds = true
        
        let fraction = fractionResults[0][indexPath.row] as! Float
        
        if fraction <= 0.25{
            
            cell.backgroundColor = redColour
            
        }
        else if fraction <= 0.5{
            cell.backgroundColor = orangeColour
            
        }
        else if fraction <= 0.75{
            cell.backgroundColor = yellowColour
            
        }
        else{
            cell.backgroundColor = greenColour
            cell.layer.borderColor = appGreen.cgColor
            cell.layer.borderWidth = 4
            cell.layer.cornerRadius = 5
            
        }
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        dateChosen = eventResultsArrayDetails[0][indexPath.row + 1] as! String
        
        dateChosenPosition = indexPath.row
        
        print(eventResultsArrayDetails[0][indexPath.row + 1])
        
    }
    

}
