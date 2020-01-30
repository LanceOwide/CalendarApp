//
//  EventRequestViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 09/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit



class EventRequestViewController: UIViewController {
    
    

    
    var startDate = NSDate()
    var endDate = NSDate()
    let dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    

        
    }
    
    
    @IBAction func runTheCode2(_ sender: UIButton) {
        
        test()
    }
    
    func test(){
    dateFormatter.dateFormat = "dd-mmm-yyyy"
        startDate = dateFormatter.date(from: "01-01-2018")! as NSDate
        
        endDate = dateFormatter.date(from: "01-01-2020")! as NSDate
    
        
        print(startDate)
        
    }


}
