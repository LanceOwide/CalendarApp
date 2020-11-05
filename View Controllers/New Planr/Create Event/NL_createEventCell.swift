//
//  NL_createEventCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/18/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit


class createEventCell: UICollectionViewCell {

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
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    
//    setup the views
    override init(frame: CGRect) {
      super.init(frame: frame)
        
//        add the views to the content view
        self.contentView.addSubview(cellView)
        self.contentView.addSubview(eventImageView)
        self.contentView.addSubview(textView)
        textView.addSubview(cellText)
        
        //x,y,w,h
        bubbleViewRightAnchor = cellView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = cellView.leftAnchor.constraint(equalTo: self.rightAnchor, constant: 8)
        cellView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = cellView.widthAnchor.constraint(equalToConstant: 100)
        bubbleWidthAnchor = cellView.heightAnchor.constraint(equalToConstant: 100)
        bubbleWidthAnchor?.isActive = true
        cellView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

//        setup the event image view constraints
//        center the image
        eventImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        eventImageView.backgroundColor = MyVariables.colourBackground
        eventImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        
//        add the textView beneatht the image
        textView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        textView.backgroundColor = .white
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        
//        add the text into the textView
        cellText.centerXAnchor.constraint(equalTo: textView.centerXAnchor).isActive = true
        cellText.backgroundColor = .white
        cellText.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        cellText.widthAnchor.constraint(equalToConstant: 75).isActive = true
        cellText.heightAnchor.constraint(equalToConstant: 25).isActive = true
        cellText.translatesAutoresizingMaskIntoConstraints = false
    
    }
    
//    this is needed for the reuse of each cell
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
//    not sure what this does
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
}
