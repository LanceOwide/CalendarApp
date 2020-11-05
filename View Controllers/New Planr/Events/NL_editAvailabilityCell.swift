
//
//  NL_collectionCollectionViewDateCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/27/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class NL_editAvailabilityCell: UICollectionViewCell {
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 5
        label.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
        label.layer.borderWidth = 1
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.clipsToBounds = true
        label.layer.masksToBounds = true
        return label
    }()
    

    
    //    setup the views
        override init(frame: CGRect) {
          super.init(frame: frame)
            
    //        add the views to the content view
            self.contentView.addSubview(cellView)
            
            //x,y,w,h
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            cellView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            cellView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            cellView.translatesAutoresizingMaskIntoConstraints = false
            
//            add the date label number in the middle for everyone is avaialble
            cellView.addSubview(label)
            label.textAlignment = .center
            label.topAnchor.constraint(equalTo: cellView.topAnchor).isActive = true
            label.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
            label.widthAnchor.constraint(equalTo: cellView.widthAnchor).isActive = true
            label.heightAnchor.constraint(equalTo: cellView.heightAnchor).isActive = true
            label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

