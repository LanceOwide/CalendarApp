//
//  NL_settingTableViewCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/26/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class NL_settingTableViewCell: UITableViewCell {

       //    setup the image for each event type
           let eventImageView: UIImageView = {
               let imageView = UIImageView()
               imageView.image = UIImage(named: "Planr")
               imageView.translatesAutoresizingMaskIntoConstraints = false
               imageView.layer.cornerRadius = 16
               imageView.layer.masksToBounds = true
               imageView.contentMode = .scaleAspectFill
               return imageView
           }()
           
       //    setup the text for the view
           let cellText: UILabel = {
               let label = UILabel()
               label.translatesAutoresizingMaskIntoConstraints = false
               label.layer.cornerRadius = 16
               label.layer.masksToBounds = true
               label.textAlignment = .center
               label.contentMode = .scaleAspectFill
               label.font = UIFont.systemFont(ofSize: 14)
               return label
           }()
           
       //    setup a container view for the label, since we can't puyt this directly into the view
           let textView: UIView = {
               let view = UIView()
               view.backgroundColor = .white
               view.translatesAutoresizingMaskIntoConstraints = false
               view.layer.cornerRadius = 16
               view.layer.masksToBounds = true
               return view
           }()
           
           
           let cellView: UIView = {
               let view = UIView()
               view.backgroundColor = .white
               view.translatesAutoresizingMaskIntoConstraints = false
               view.layer.cornerRadius = 16
               view.layer.masksToBounds = true
               return view
           }()
       
       
       //    setup the image for each event type
           let addImageView: UIImageView = {
               let imageView = UIImageView()
               imageView.image = UIImage(named: "Planr")
               imageView.translatesAutoresizingMaskIntoConstraints = false
               imageView.layer.cornerRadius = 16
               imageView.layer.masksToBounds = true
               imageView.contentMode = .scaleAspectFill
               return imageView
           }()
           
           var bubbleWidthAnchor: NSLayoutConstraint?
           var bubbleViewRightAnchor: NSLayoutConstraint?
           var bubbleViewLeftAnchor: NSLayoutConstraint?
       
       
       //    setup the views
       override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       super.init(style: style, reuseIdentifier: reuseIdentifier)
           
           
   //        add the views to the content view
           self.contentView.addSubview(cellView)
           self.contentView.addSubview(eventImageView)
           self.contentView.addSubview(textView)
           self.contentView.addSubview(addImageView)
           textView.addSubview(cellText)
           
           let imageBubbleSize = 70.0
           let selectSize = 30.0
           let inset = 16.0
           let textSize = (Double(screenWidth) - imageBubbleSize - inset)/1.5
           
           //x,y,w,h
           bubbleViewRightAnchor = cellView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
           bubbleViewRightAnchor?.isActive = true
           bubbleViewLeftAnchor = cellView.leftAnchor.constraint(equalTo: self.rightAnchor, constant: 8)
           cellView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
           bubbleWidthAnchor = cellView.heightAnchor.constraint(equalToConstant: 70)
           bubbleWidthAnchor?.isActive = true
   //        cellView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
           
   //        add the textView beneatht the image
           textView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CGFloat(imageBubbleSize) + CGFloat(inset)).isActive = true
           textView.backgroundColor = .white
           textView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
           textView.widthAnchor.constraint(equalToConstant: CGFloat(textSize)).isActive = true
           textView.heightAnchor.constraint(equalToConstant: 50).isActive = true
           textView.translatesAutoresizingMaskIntoConstraints = false
                   
           //        add the text into the textView
           cellText.leftAnchor.constraint(equalTo: textView.leftAnchor, constant: 10).isActive = true
           cellText.backgroundColor = .white
           cellText.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
           cellText.widthAnchor.constraint(equalToConstant: CGFloat(textSize) - 10).isActive = true
           cellText.heightAnchor.constraint(equalToConstant: 50).isActive = true
           cellText.translatesAutoresizingMaskIntoConstraints = false
           cellText.textAlignment = .left
           
   //        add image for selecting the user
           addImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant:  CGFloat(inset)).isActive = true
           addImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        addImageView.backgroundColor = .white
           addImageView.layer.borderColor = UIColor.white.cgColor
           addImageView.widthAnchor.constraint(equalToConstant: CGFloat(selectSize)).isActive = true
           addImageView.heightAnchor.constraint(equalToConstant: CGFloat(selectSize)).isActive = true
           addImageView.translatesAutoresizingMaskIntoConstraints = false
           addImageView.layer.masksToBounds = true
           addImageView.layer.cornerRadius = 0
           
           
           
       }
       
       
       //    not sure what this does
       required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
       }
       
   }
