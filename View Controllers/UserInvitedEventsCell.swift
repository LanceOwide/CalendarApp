//
//  UserInvitedEventsCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 02/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

class UserInvitedEventsCell: UITableViewCell {

    
    @IBOutlet var userInvitedCellImage: UIImageView!
    
    @IBOutlet var userInvitedCellLabel1: UILabel!
    @IBOutlet var userInvitedCellLabel2: UILabel!
    @IBOutlet var userInvitedCellLabel3: UILabel!
    
    
    @IBOutlet weak var imgChatNotification: UIImageView!
    
    
    @IBOutlet weak var userInvitedCellLabel4: UILabel!
    
    
    
    @IBOutlet weak var inviteeCircledCollectionView: UICollectionView!
    
    
    
    
    func setCircledCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int, forSection section: Int) {
        
        print("tableView section: \(section)")
        
        let primes = [1,100,10000]

        inviteeCircledCollectionView.delegate = dataSourceDelegate
        inviteeCircledCollectionView.dataSource = dataSourceDelegate
        inviteeCircledCollectionView.tag = (row + 1) * primes[section]
        inviteeCircledCollectionView.reloadData()
        
    }
    
    
}
