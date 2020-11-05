
//
//  NL_collectionCollectionViewDateCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/27/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class NL_eventResultsCell: UICollectionViewCell {
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 11)
        label.backgroundColor = MyVariables.colourPlanrGreen
        label.textColor = .white
        label.layer.masksToBounds = true
        return label
    }()
    
    let label2: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .black
        label.layer.masksToBounds = true
        return label
    }()
    
    let label3: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.textColor = MyVariables.colourPlanrGreen
        label.layer.masksToBounds = true
        return label
    }()
    

    
    //    setup the views
        override init(frame: CGRect) {
          super.init(frame: frame)
            
    //        add the views to the content view
            self.contentView.addSubview(cellView)
            let sideInset = CGFloat(6)
            
            //x,y,w,h
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            cellView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            cellView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            cellView.translatesAutoresizingMaskIntoConstraints = false
            
//            add the date label number in the middle for everyone is avaialble
            cellView.addSubview(label)
            label.topAnchor.constraint(equalTo: cellView.topAnchor).isActive = true
            label.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
            label.widthAnchor.constraint(equalTo: cellView.widthAnchor).isActive = true
            label.heightAnchor.constraint(equalTo: cellView.heightAnchor).isActive = true
            label.translatesAutoresizingMaskIntoConstraints = false
            
            
            //            add a top label for the number of people available
            cellView.addSubview(label2)
            label2.topAnchor.constraint(equalTo: cellView.topAnchor).isActive = true
            label2.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
            label2.widthAnchor.constraint(equalTo: cellView.widthAnchor, constant:  -sideInset).isActive = true
            label2.heightAnchor.constraint(equalTo: cellView.heightAnchor, multiplier: 0.5).isActive = true
            label2.translatesAutoresizingMaskIntoConstraints = false
            
            //            add a bottom label for the date
            cellView.addSubview(label3)
            label3.bottomAnchor.constraint(equalTo: cellView.bottomAnchor).isActive = true
            label3.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
            label3.widthAnchor.constraint(equalTo: cellView.widthAnchor, constant:  -sideInset).isActive = true
            label3.heightAnchor.constraint(equalTo: cellView.heightAnchor, multiplier: 0.5).isActive = true
            label3.translatesAutoresizingMaskIntoConstraints = false
            
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
