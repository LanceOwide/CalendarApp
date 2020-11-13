//
//  NL_inviteesCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/28/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class NL_inviteesCell: UICollectionViewCell {
    
    
    
    //    setup the image for each event type
    let inviteePicture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Planr")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //    setup the image for each event type
        let eventImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 16
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
    
    let inviteeStatus: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Planr")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        return imageView
    }()
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    //    setup the text for the view
    let lblInviteeName: UILabel = {
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
    let lblHost: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 0
        label.layer.masksToBounds = true
        label.textAlignment = .right
        label.contentMode = .scaleAspectFill
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    
    //    setup the image for each event type
        let respondedTickView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 16
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
    
    
    //    setup the views
    override init(frame: CGRect) {
      super.init(frame: frame)

        let imageBubbleSize = 50.0
        let imgSpacer = CGFloat(2)
        let responseImgSize = 10.0
        
        //        add the views to the content view
        self.contentView.addSubview(cellView)
        cellView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        cellView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        cellView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        cellView.translatesAutoresizingMaskIntoConstraints = false
    
    //        setup the event image view constraints
    //        center the image
            cellView.addSubview(inviteePicture)
            inviteePicture.backgroundColor = MyVariables.colourBackground
    //        make the imageView round
            inviteePicture.layer.borderWidth = 1.0
            inviteePicture.layer.masksToBounds = true
    //        create the circle
            inviteePicture.layer.cornerRadius = CGFloat(imageBubbleSize) / 2
            inviteePicture.layer.borderColor = UIColor.white.cgColor
            inviteePicture.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
            inviteePicture.topAnchor.constraint(equalTo: cellView.topAnchor, constant: imgSpacer).isActive = true
            inviteePicture.widthAnchor.constraint(equalToConstant: CGFloat(imageBubbleSize)).isActive = true
            inviteePicture.heightAnchor.constraint(equalToConstant: CGFloat(imageBubbleSize)).isActive = true
            inviteePicture.translatesAutoresizingMaskIntoConstraints = false
        
        
        cellView.addSubview(inviteeStatus)
        inviteeStatus.backgroundColor = UIColor.clear
//        make the imageView round
        inviteeStatus.layer.borderWidth = 1.0
        inviteeStatus.layer.masksToBounds = true
//        create the circle
        inviteeStatus.layer.cornerRadius = CGFloat(imageBubbleSize) / 2
        inviteeStatus.layer.borderColor = UIColor.clear.cgColor
        inviteeStatus.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
        inviteeStatus.topAnchor.constraint(equalTo: cellView.topAnchor, constant: imgSpacer).isActive = true
        inviteeStatus.widthAnchor.constraint(equalToConstant: CGFloat(imageBubbleSize)).isActive = true
        inviteeStatus.heightAnchor.constraint(equalToConstant: CGFloat(imageBubbleSize)).isActive = true
        inviteeStatus.translatesAutoresizingMaskIntoConstraints = false
        
        
//        add the invitee name below the picture
        
        cellView.addSubview(lblInviteeName)
        lblInviteeName.text = "Sample Name"
        lblInviteeName.textAlignment = .center
        lblInviteeName.lineBreakMode = .byWordWrapping
        lblInviteeName.numberOfLines = 2
        lblInviteeName.font = UIFont.systemFont(ofSize: 8)
        lblInviteeName.textColor = MyVariables.colourLight
        lblInviteeName.adjustsFontSizeToFitWidth = true
        lblInviteeName.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -1).isActive = true
        lblInviteeName.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 1).isActive = true
        lblInviteeName.heightAnchor.constraint(equalToConstant: 20).isActive = true
        lblInviteeName.bottomAnchor.constraint(equalTo: cellView.bottomAnchor).isActive = true
        
        
        cellView.addSubview(lblHost)
        lblHost.text = "Host"
        lblHost.textAlignment = .center
        lblHost.backgroundColor = .white
        lblHost.lineBreakMode = .byWordWrapping
        lblHost.numberOfLines = 2
        lblHost.font = UIFont.boldSystemFont(ofSize: 8)
        lblHost.textColor = MyVariables.colourLight
        lblHost.adjustsFontSizeToFitWidth = true
        lblHost.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -1).isActive = true
        lblHost.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 1).isActive = true
        lblHost.heightAnchor.constraint(equalToConstant: 20).isActive = true
        lblHost.topAnchor.constraint(equalTo: cellView.topAnchor).isActive = true
        
        //        setup the event image view constraints
        //        center the image
        cellView.addSubview(eventImageView)
        eventImageView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -12).isActive = true
        eventImageView.backgroundColor = UIColor.clear
        //        make the imageView round
        eventImageView.layer.borderWidth = 1.0
        eventImageView.layer.masksToBounds = true
        //       create the circle
        eventImageView.layer.cornerRadius = 1
        eventImageView.layer.borderColor = UIColor.clear.cgColor
        eventImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(imageBubbleSize) - 5).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: CGFloat(responseImgSize)).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: CGFloat(responseImgSize)).isActive = true
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        eventImageView.isHidden = true
        eventImageView.image = UIImage(named: "greenTickCode")
        
        
        cellView.addSubview(respondedTickView)
        respondedTickView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -6).isActive = true
        respondedTickView.backgroundColor = UIColor.clear
        //        make the imageView round
        respondedTickView.layer.borderWidth = 1.0
        respondedTickView.layer.masksToBounds = true
        //       create the circle
        respondedTickView.layer.cornerRadius = 1
        respondedTickView.layer.borderColor = UIColor.clear.cgColor
        respondedTickView.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(imageBubbleSize) - 5).isActive = true
        respondedTickView.widthAnchor.constraint(equalToConstant: CGFloat(responseImgSize)).isActive = true
        respondedTickView.heightAnchor.constraint(equalToConstant: CGFloat(responseImgSize)).isActive = true
        respondedTickView.translatesAutoresizingMaskIntoConstraints = false
        respondedTickView.isHidden = true
        respondedTickView.image = UIImage(named: "greenTickCode")
        
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
