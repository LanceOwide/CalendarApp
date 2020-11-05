//
//  NL_collectionCollectionViewDateCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/27/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class NL_collectionCollectionViewDateCell: UICollectionViewCell {
    
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
        label.layer.masksToBounds = true
        return label
    }()
    
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    let indicatorView1: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    let indicatorView21: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    let indicatorView22: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    //    setup the views
        override init(frame: CGRect) {
          super.init(frame: frame)
            
    //        add the views to the content view
            self.contentView.addSubview(cellView)
            let indicatorSize = CGFloat(4)
            
            //x,y,w,h
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            cellView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            cellView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            cellView.translatesAutoresizingMaskIntoConstraints = false
            
//            add the date number label
            cellView.addSubview(label)
            label.topAnchor.constraint(equalTo: cellView.topAnchor).isActive = true
            label.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
            label.widthAnchor.constraint(equalTo: cellView.widthAnchor, constant:  -6).isActive = true
//            we set the height to 5 less to
            label.heightAnchor.constraint(equalTo: cellView.heightAnchor,constant: -6).isActive = true
            label.translatesAutoresizingMaskIntoConstraints = false
            
//            add a view to house the indicator symbols
            
            cellView.addSubview(indicatorView)
            indicatorView.rightAnchor.constraint(equalTo: cellView.rightAnchor).isActive = true
            indicatorView.leftAnchor.constraint(equalTo: cellView.leftAnchor).isActive = true
            indicatorView.bottomAnchor.constraint(equalTo: cellView.bottomAnchor).isActive = true
            indicatorView.heightAnchor.constraint(equalToConstant: 5).isActive = true
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            
            
//            setup the indicatorviews
            indicatorView.addSubview(indicatorView1)
            indicatorView.addSubview(indicatorView21)
            indicatorView.addSubview(indicatorView22)

//            view 1 is in the center, used when only one type of event is available for that day
            indicatorView1.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor).isActive = true
            indicatorView1.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor).isActive = true
            indicatorView1.layer.cornerRadius = CGFloat(indicatorSize) / 2
            indicatorView1.layer.borderColor = UIColor.white.cgColor
            indicatorView1.widthAnchor.constraint(equalToConstant: indicatorSize).isActive = true
            indicatorView1.heightAnchor.constraint(equalToConstant: indicatorSize).isActive = true


//            view 2.1 is in the center, used when there are two indidcators
            indicatorView21.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor).isActive = true
            indicatorView21.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor, constant: -5).isActive = true
            indicatorView21.layer.cornerRadius = CGFloat(indicatorSize) / 2
            indicatorView21.layer.borderColor = UIColor.white.cgColor
            indicatorView21.widthAnchor.constraint(equalToConstant: indicatorSize).isActive = true
            indicatorView21.heightAnchor.constraint(equalToConstant: indicatorSize).isActive = true

//            view 2.2 is in the center, used when there are two indidcators
            indicatorView22.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor).isActive = true
            indicatorView22.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor, constant: 5).isActive = true
            indicatorView22.layer.cornerRadius = CGFloat(indicatorSize) / 2
            indicatorView22.layer.borderColor = UIColor.white.cgColor
            indicatorView22.widthAnchor.constraint(equalToConstant: indicatorSize).isActive = true
            indicatorView22.heightAnchor.constraint(equalToConstant: indicatorSize).isActive = true
            
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
