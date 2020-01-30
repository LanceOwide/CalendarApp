//
//  PlanrTableViewCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 13/12/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

class PlanrTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblTop: UILabel!
    
    
    @IBOutlet weak var planrEventsTableView: UITableView!
    
    func setPlanrTableViewDelegate(dataSourceDelegate: UITableViewDelegate & UITableViewDataSource, forRow row: Int, forSection section: Int) {
          
          print("tableView section: \(section)")

          planrEventsTableView.delegate = dataSourceDelegate
          planrEventsTableView.dataSource = dataSourceDelegate
          planrEventsTableView.tag = row
          planrEventsTableView.reloadData()
          
      }
    

}
