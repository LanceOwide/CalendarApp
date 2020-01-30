//
//  EditTableViewCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 12/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

protocol CellSubclassDelegate: class {
    func buttonTapped(cell: EditTableViewCell)
}

class EditTableViewCell: UITableViewCell {

    weak var delegate: CellSubclassDelegate?

    @IBOutlet var cellLabel: UILabel!
    
    
    @IBOutlet var deleteUserButton: UIButton!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    @IBAction func deleteUserButtonTapped(_ sender: Any) {
        
        self.delegate?.buttonTapped(cell: self)
        
    }
    
    
}
