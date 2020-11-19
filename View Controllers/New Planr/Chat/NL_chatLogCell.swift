//
//  NL_chatLogCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 9/14/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class NL_chatLogCell: UICollectionViewCell {

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
       let lblstatus: UILabel = {
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.layer.cornerRadius = 3
           label.layer.masksToBounds = true
           label.textAlignment = .center
           label.contentMode = .scaleAspectFill
           label.font = UIFont.systemFont(ofSize: 14)
           return label
       }()
    
    let lblchatNotification: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 8)
        lbl.backgroundColor = MyVariables.notificationOrange
        lbl.textColor = MyVariables.colourLight
       return lbl
    }()
        

        

        
            
        var bubbleWidthAnchor: NSLayoutConstraint?
        var bubbleHeightAnchor: NSLayoutConstraint?
        var bubbleViewRightAnchor: NSLayoutConstraint?
        var bubbleViewLeftAnchor: NSLayoutConstraint?
        
        //    setup the views
        override init(frame: CGRect) {
          super.init(frame: frame)
            
//            layer.shadowColor = MyVariables.colourBackground.cgColor
//            layer.shadowOffset = CGSize(width: 0, height: 2.0)
//            layer.shadowRadius = 2.0
//            layer.shadowOpacity = 1.0
//            layer.masksToBounds = true
//            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
//            layer.backgroundColor = UIColor.clear.cgColor
//            contentView.layer.masksToBounds = true
//            layer.cornerRadius = 10
            
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
            let titleHeight = CGFloat(40)
            let labelHeight = CGFloat(40)
            let statusWidth = CGFloat(50)
            let statusHeight = CGFloat(15)
            let notificationSize = CGFloat(20)
            
            
    //        add the event image
            cellView.addSubview(eventImage)
            eventImage.image = UIImage(named: "conferenceColoredCode")
            eventImage.leftAnchor.constraint(equalTo: cellView.leftAnchor,constant: sideInset).isActive = true
            eventImage.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset).isActive = true
            eventImage.heightAnchor.constraint(equalToConstant: segments*1.5).isActive = true
            eventImage.widthAnchor.constraint(equalToConstant: segments*1.5).isActive = true
            eventImage.translatesAutoresizingMaskIntoConstraints = false
            
            
    //        add the title
            cellView.addSubview(lbleventTitle)
            lbleventTitle.text = "Sample event title"
            lbleventTitle.textAlignment = .left
            lbleventTitle.font = UIFont.boldSystemFont(ofSize: 15)
            lbleventTitle.leftAnchor.constraint(equalTo: cellView.leftAnchor,constant: sideInset + segments*2).isActive = true
            lbleventTitle.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset/2).isActive = true
            lbleventTitle.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
            lbleventTitle.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -sideInset - statusWidth).isActive = true
            lbleventTitle.translatesAutoresizingMaskIntoConstraints = false
            
            //        add the status
            cellView.addSubview(lblstatus)
            lblstatus.text = ""
            lblstatus.textAlignment = .center
            lblstatus.font = UIFont.systemFont(ofSize: 12)
            lblstatus.textColor = MyVariables.colourPendingText
            lblstatus.adjustsFontSizeToFitWidth = true
            lblstatus.backgroundColor = .white
            lblstatus.widthAnchor.constraint(equalToConstant: statusWidth).isActive = true
            lblstatus.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset).isActive = true
            lblstatus.heightAnchor.constraint(equalToConstant: statusHeight).isActive = true
            lblstatus.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -sideInset).isActive = true
            lblstatus.translatesAutoresizingMaskIntoConstraints = false
            
            
            //        add the title
            cellView.addSubview(lbleventLocation)
            lbleventLocation.text = "The last chat"
            lbleventLocation.textAlignment = .left
            lbleventLocation.textColor = MyVariables.colourLight
            lbleventLocation.font = UIFont.systemFont(ofSize: 12)
            lbleventLocation.leftAnchor.constraint(equalTo: cellView.leftAnchor,constant: sideInset + segments*2).isActive = true
            lbleventLocation.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset/2 + 25).isActive = true
            lbleventLocation.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
            lbleventLocation.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -sideInset - statusWidth).isActive = true
            lbleventLocation.translatesAutoresizingMaskIntoConstraints = false
            
            let separatorLine = UIView()
            separatorLine.backgroundColor = MyVariables.colourLight
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            cellView.addSubview(separatorLine)
            separatorLine.bottomAnchor.constraint(equalTo: cellView.bottomAnchor).isActive = true
            separatorLine.rightAnchor.constraint(equalTo: cellView.rightAnchor).isActive = true
            separatorLine.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2 - segments*2).isActive = true
            separatorLine.heightAnchor.constraint(equalToConstant: CGFloat(0.5)).isActive = true
            
            
            //        add the chat notifications
            cellView.addSubview(lblchatNotification)
            lblchatNotification.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -sideInset).isActive = true
            lblchatNotification.heightAnchor.constraint(equalToConstant: notificationSize).isActive = true
            lblchatNotification.widthAnchor.constraint(equalToConstant: notificationSize).isActive = true
            lblchatNotification.topAnchor.constraint(equalTo: cellView.topAnchor,constant: sideInset/2 + 25).isActive = true
            lblchatNotification.translatesAutoresizingMaskIntoConstraints = false
            lblchatNotification.layer.borderWidth = 1.0
            lblchatNotification.layer.masksToBounds = true
            lblchatNotification.layer.cornerRadius = CGFloat(notificationSize) / 2
            lblchatNotification.layer.borderColor = UIColor.white.cgColor
            lblchatNotification.isHidden = true
            
            
        }
        
        
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        

}
