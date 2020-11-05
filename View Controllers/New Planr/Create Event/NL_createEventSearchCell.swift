//
//  NL_createEventCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/18/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit


class createEventSearchCell: UICollectionViewCell {
    
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
    var bubbleHeightAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    
//    setup the views
    override init(frame: CGRect) {
      super.init(frame: frame)
        
//        add the views to the content view
        self.contentView.addSubview(cellView)
        self.contentView.addSubview(textView)
        textView.addSubview(cellText)
        
        //x,y,w,h
        bubbleViewRightAnchor = cellView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = cellView.leftAnchor.constraint(equalTo: self.rightAnchor, constant: 8)
        cellView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = cellView.widthAnchor.constraint(equalToConstant: 70)
        bubbleHeightAnchor = cellView.heightAnchor.constraint(equalToConstant: 30)
        bubbleWidthAnchor?.isActive = true
        bubbleHeightAnchor?.isActive = true
        cellView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
//        add the textView beneatht the image
        textView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        textView.backgroundColor = .white
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        
//        add the text into the textView
        cellText.centerXAnchor.constraint(equalTo: textView.centerXAnchor).isActive = true
        cellText.backgroundColor = .white
        cellText.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        cellText.widthAnchor.constraint(equalToConstant: 70).isActive = true
        cellText.heightAnchor.constraint(equalToConstant: 30).isActive = true
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

