//
//  NL_eventCollectionView.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/28/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class NL_eventCollectionViewCell: UICollectionViewCell {
    
  let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    
    //    setup the image for each event type
        let eventImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Planr")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
         }()
    
    
    //    setup the text for the view
    let lbleventTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 0
        label.layer.masksToBounds = true
        label.textAlignment = .right
        label.contentMode = .scaleAspectFill
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let lbleventDate: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 0
        label.layer.masksToBounds = true
        label.textAlignment = .right
        label.contentMode = .scaleAspectFill
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    //    setup the text for the view
    let lbleventLocation: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 0
        label.layer.masksToBounds = true
        label.textAlignment = .right
        label.contentMode = .scaleAspectFill
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    //    setup the text for the view
    let lbleventTime: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.textAlignment = .right
        label.contentMode = .scaleAspectFill
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    //    setup the text for the view
       let lblstatus: UILabel = {
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.layer.cornerRadius = 3
           label.layer.masksToBounds = true
           label.textAlignment = .center
           label.adjustsFontSizeToFitWidth = true
           label.contentMode = .scaleAspectFill
//           label.adjustsFontSizeToFitWidth = true
           label.font = UIFont.systemFont(ofSize: 14)
           return label
       }()
    
    
    var collectionView: UICollectionView!
    
//    function for allowing the delegation of the collectionView
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
            collectionView.delegate = dataSourceDelegate
            collectionView.dataSource = dataSourceDelegate
            collectionView.tag = row
            collectionView.reloadData()
    }
        
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleHeightAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    //    setup the views
    override init(frame: CGRect) {
      super.init(frame: frame)
        
        layer.shadowColor = MyVariables.colourBackground.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = true
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        layer.cornerRadius = 10
        
//        add the views to the content view
        self.contentView.addSubview(cellView)
        
        
        cellView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
        cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
        cellView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4).isActive = true
        cellView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4).isActive = true
        cellView.translatesAutoresizingMaskIntoConstraints = false
        
//        variables
        let sideInset = CGFloat(16)
        let totalSize = screenWidth - sideInset*2
        let segments = CGFloat(totalSize / 10)
        let labelHeight = CGFloat(25)
        let labelHeightTime = CGFloat(20)
        let statusWidth = CGFloat(60)
        let statusHeight = CGFloat(60)
        let cellId2 = "cellId2"
        
        
//        add the event image
        cellView.addSubview(eventImage)
        eventImage.image = UIImage(named: "conferenceColoredCode")
        eventImage.leftAnchor.constraint(equalTo: cellView.leftAnchor,constant: sideInset).isActive = true
        eventImage.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset).isActive = true
        eventImage.heightAnchor.constraint(equalToConstant: segments*1.25).isActive = true
        eventImage.widthAnchor.constraint(equalToConstant: segments*1.25).isActive = true
        eventImage.translatesAutoresizingMaskIntoConstraints = false
        
        
//        add the title
        cellView.addSubview(lbleventTitle)
        lbleventTitle.text = "Sample event title"
        lbleventTitle.textAlignment = .left
        lbleventTitle.font = UIFont.boldSystemFont(ofSize: 18)
        lbleventTitle.leftAnchor.constraint(equalTo: cellView.leftAnchor,constant: sideInset + segments*2).isActive = true
        lbleventTitle.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset/2).isActive = true
        lbleventTitle.heightAnchor.constraint(equalToConstant: segments).isActive = true
        lbleventTitle.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -sideInset - statusWidth).isActive = true
        lbleventTitle.translatesAutoresizingMaskIntoConstraints = false
        
        //        add the status
        cellView.addSubview(lblstatus)
        lblstatus.text = "Pending"
        lblstatus.textAlignment = .center
        lblstatus.font = UIFont.systemFont(ofSize: 11)
        lblstatus.textColor = MyVariables.colourPendingText
        lblstatus.adjustsFontSizeToFitWidth = true
        lblstatus.numberOfLines = 2
        lblstatus.backgroundColor = MyVariables.colourPendingBackground
        lblstatus.widthAnchor.constraint(equalToConstant: statusWidth).isActive = true
        lblstatus.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset).isActive = true
        lblstatus.heightAnchor.constraint(equalToConstant: statusHeight).isActive = true
        lblstatus.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -sideInset).isActive = true
        lblstatus.translatesAutoresizingMaskIntoConstraints = false
        
        
        //        add the title
        cellView.addSubview(lbleventLocation)
        lbleventLocation.text = "Sample Location"
        lbleventLocation.textAlignment = .left
        lbleventLocation.textColor = MyVariables.colourLight
        lbleventLocation.font = UIFont.systemFont(ofSize: 12)
        lbleventLocation.leftAnchor.constraint(equalTo: cellView.leftAnchor,constant: sideInset + segments*2).isActive = true
        lbleventLocation.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset/2 + labelHeight).isActive = true
        lbleventLocation.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
        lbleventLocation.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -sideInset - statusWidth).isActive = true
        lbleventLocation.translatesAutoresizingMaskIntoConstraints = false
        
        //        add the location
        cellView.addSubview(lbleventTime)
        lbleventTime.text = "12:00 - 13:00"
        lbleventTime.textAlignment = .left
        lbleventTime.font = UIFont.boldSystemFont(ofSize: 14)
        lbleventTime.textColor = .white
        lbleventTime.backgroundColor = MyVariables.colourPlanrGreen
        lbleventTime.textAlignment = .center
        lbleventTime.layer.cornerRadius = 3
        lbleventTime.layer.masksToBounds = true
        lbleventTime.leftAnchor.constraint(equalTo: cellView.leftAnchor,constant: sideInset + segments*2).isActive = true
        lbleventTime.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset/2 + labelHeight*2).isActive = true
        lbleventTime.heightAnchor.constraint(equalToConstant: labelHeightTime).isActive = true
        lbleventTime.widthAnchor.constraint(equalToConstant: 120).isActive = true
        lbleventTime.translatesAutoresizingMaskIntoConstraints = false
        
        
        cellView.addSubview(lbleventDate)
        lbleventDate.text = "Date"
        lbleventDate.font = UIFont.boldSystemFont(ofSize: 14)
        lbleventDate.textColor = MyVariables.colourPlanrGreen
        lbleventDate.backgroundColor = MyVariables.colourSelected
        lbleventDate.textAlignment = .center
        lbleventDate.numberOfLines = 3
        lbleventDate.lineBreakMode = .byWordWrapping
        lbleventDate.layer.cornerRadius = 3
        lbleventDate.layer.masksToBounds = true
        lbleventDate.leftAnchor.constraint(equalTo: cellView.leftAnchor,constant: sideInset).isActive = true
        lbleventDate.topAnchor.constraint(equalTo: cellView.topAnchor,constant: segments*1.25 + 10 + sideInset).isActive = true
        lbleventDate.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -sideInset).isActive = true
        lbleventDate.widthAnchor.constraint(equalToConstant: segments*1.25 ).isActive = true
        lbleventDate.translatesAutoresizingMaskIntoConstraints = false
        lbleventDate.isHidden = true
        
        
//        setup the collectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width - sideInset + segments*2, height: 70), collectionViewLayout: layout)
        collectionView.register(NL_inviteesCell.self, forCellWithReuseIdentifier: cellId2)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = true
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
       cellView.addSubview(collectionView)
       collectionView.leftAnchor.constraint(equalTo: cellView.leftAnchor,constant: sideInset + segments*2).isActive = true
       collectionView.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset/2 + labelHeight*2 + labelHeightTime + 5).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: cellView.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -sideInset).isActive = true
       collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



