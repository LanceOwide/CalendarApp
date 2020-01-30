//
//  CollectionViewCellAddFriends.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 17/09/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

protocol CellSubclassDelegate2: class {
    func buttonTapped2(cell: CollectionViewCellAddFriends)
}

class CollectionViewCellAddFriends: UITableViewCell {
    
    weak var delegate: CellSubclassDelegate2?
    
    @IBOutlet weak var addFriendsImage: UIImageView!
    
    @IBOutlet weak var addFriendsLabel: UILabel!
    
    
    @IBOutlet weak var deleteUserButton: UIButton!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        self.delegate?.buttonTapped2(cell: self)
        
    }
    
    
    
    
}
