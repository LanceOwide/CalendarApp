//
//  UserCreatedEventsCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 02/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit


class UserCreatedEventsCell: UITableViewCell {


    @IBOutlet var userCreatedCellImage: UIImageView!
    

    @IBOutlet weak var userCreatedCollectionViewDates: UICollectionView!
    
    
    @IBOutlet weak var userCreatedCollectionViewNames: UICollectionView!
    
    
    
    @IBOutlet weak var imgChatNotification: UIImageView!
    
    
    
    
    @IBOutlet var userCreatedCellLabel1: UILabel!
    
    @IBOutlet var userCreatedCellLabel2: UILabel!
    
    @IBOutlet var userCreatedCellLabel3: UILabel!
    
    
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int, forSection section: Int) {
        
        print("tableView section: \(section)")
        
        let primes = [1,100,10000]

        userCreatedCollectionViewDates.delegate = dataSourceDelegate
        userCreatedCollectionViewDates.dataSource = dataSourceDelegate
        userCreatedCollectionViewDates.tag = (row + 1) * primes[section]
        userCreatedCollectionViewDates.reloadData()
        
    }
    
    
    func setCollectionViewDataSourceDelegateNames(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int, forSection section: Int) {
        
        print("tableView section: \(section)")
        
        let primes = [1000000,100000000,10000000000]

        userCreatedCollectionViewNames.delegate = dataSourceDelegate
        userCreatedCollectionViewNames.dataSource = dataSourceDelegate
        userCreatedCollectionViewNames.tag = (row + 1) * primes[section]
        userCreatedCollectionViewNames.reloadData()
        
    }
    
}
